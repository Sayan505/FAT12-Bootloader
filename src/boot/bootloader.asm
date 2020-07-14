;===================================================================================================
; bootloader.asm
;
;   In-house bootloader to bootstrap my tiny OS.
;===================================================================================================

CPU x86-64                      ;use x86_64 instruction set

USE16                           ;generate 16-bit code

ORG 0                           ;offset 0


;===================================================================================================

%INCLUDE "src/boot/routines/stdlib/lib.inc"
%INCLUDE "src/boot/constants/boot_consts.inc"
%INCLUDE "src/boot/bpb/fat12_2880_BPB.inc"

;===================================================================================================

start:
  jmp short bootloader_entry    ;near jump over BPB, to the entry point.

  times 3 - ($ - $$) db 0       ;PADDING
                                ;Need to make it 3 bytes before BPB.


install_bpb


;real entry point:
bootloader_entry:
  ;save boot device set by BIOS
  mov [bootdev], dl
  cld               ;Clear Direction Flag
                    ;When the DF flag is cleared, string operations increment DI & SI (forward).



  ;init segments to the location of this bootloader in memory
  mov ax, bootloader_addr_seg ;use AX, no direct write.
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax

  ;set up stack
  ;0x0500 to 0x14FF, 4096 Bytes of stack.
  cli               ;Clear Interrupt Flag while setting up stack.
  mov ax, 0x0500
  mov bp, ax        ;Base Pointer points to the base of the stack.
  mov ss, ax        ;Set up stack segment.
  mov sp, 0x14FF    ;Set stack pointer. Points to the end of the stack,
                    ;which is 4096 Bytes from 0x0500.
                    ;In x86, PUSH decrements the stack pointer and POP increments it.
                    ;Hence, we initially point to the end of the stack as it grows downwards.

  sti               ;Re-enable Interrupts

  ;set video mode
  mov ax, 0x0003    ;CGA Color text of 80X25
  int 0x10


;...................................................................................................

;                                        BOOTLOADER READY!

;...................................................................................................


REAL_START:

xor eax, eax

bputb msg_boot                            ;put message- attempt boot

;read root directory to memory
load_root:
  ;size of root_dir = sizeof_one_entry * total_entries in root_dir.
  calc_root_dir_size:                     ;and store in CX
    xor cx, cx
    xor dx, dx                            ;clear CX & DX for MUL

    mov ax, 0x0020                        ;FAT12: 32 bytes each entry
    mul word [bpbRootDirEntries]          ;AX = AX * num_of_root_entries

    ;root_dir size in sectors = sizeof_root_dir / bytes_per_sector
    div word [bpbBytesPerSector]          ;AX = AX / [bytes_per_sector]
    mov cx, ax                            ;transfer value in CX
    ;Now CX has the size of root dir in sectors,
    ;which is the number of sectors to read for INT 13h.

  ;calc starting lba of root dir
  calc_root_dir_lba:                      ;and store in AX
  ;starting_root_dir_lba = boot_reserved_sect + size_of_FATs

    ;size_of_FATs in sectors = num_of_fats * sectors_used_in_each_FAT
    xor ax, ax                            ;clear out AX for MUL

    mov al, byte [bpbNumberOfFATs]        ;which is 2
    mul word [bpbSectorsPerFAT]           ;AX = AX * sectors_used_in_each_FAT
    mov [fats_size], ax                   ;save to memory for later use

    ;AX = AX + boot_reserved_sect
    add ax, word [bpbReservedForBoot]
    ;AX now has root dir starting sector

  ;Calculate the starting LBA of the Data Area
  calc_data_area_lba:                     ;and store in memory
    ;data_area_lba = root_dir_first_lba + root_dir_size
    mov [data_area_lba], ax
    add [data_area_lba], cx

  mov  bx, disk_buffer        ;set Buffer Address Pointer (location to read the root_dir into)
  ;That's enough information. Time to read the root directory off the disk.
  call read_disk              ;READ root_dir from disk into 0x07C0:0200 (0x7E00),
                              ;just after this 512 Byte loader.

;search root dir for KERNEL.BIN
parse_root:
;Load number of entries in root dir in CX.
;Loop CX times max and parse all entries till we find the file we're looking for.
mov cx, word [bpbRootDirEntries]          ;224
;set location of first dir entry for cmpsb (b/w DI & SI)
mov di, disk_buffer                       ;@ start of root_dir loaded in memory
  .looper:
        push  cx                   ;save CX on stack and pop it later for loop iteration
        mov   cx, 11               ;set string size for rep (cmpsb)
        mov   si, kernel_filename  ;pass kernel filename to SI to check from
        push  di                   ;save DI to queue next directory 'cause it'll be changed by cmpsb
   rep  cmpsb                      ;comapare DI with SI, pointing to each byte, CX times
        pop   di                   ;restore DI for next iteration (if any)
        je    image_found          ;found KERNEL.BIN?
        pop   cx                   ;restore CX to loop CX times (224)
        add   di, 0x0020           ;queue next dir entry, each of 32 bytes
        loop  .looper              ;loop through all the 224 entries

        bputb msg_kernel_missin    ;put message- KERNEL.BIN NOT FOUND
        bsystem_pause
        int 0x19                   ;reboot


image_found:                        ;time to load it's details on FAT
  bputb msg_kernel_found            ;put message- KERNEL.BIN FOUND

;parse the FATs for file details (for first cluster of the kernel image)
load_FAT:                   ;@ Cluster 2 which is the first cluster from where FAT1 starts.
;FOUND KERNEL.BIN!
;Now DI points to the directory entry of KERNEL.BIN.
;Bytes 26-27 contains the first Cluster of a file.
;First cluster of said file @ offset 26 of a directory entry struct.
  mov dx, word [di + 0x001A]              ;adjust DI to point to it's first cluster, i.e. 26th_byte.
  mov word [cluster], dx                  ;save it

  get_size_of_FATs:                       ;and store in CX
    mov cx, word [fats_size]              ;now CX have the total size of FATs

  get_starting_lba_of_FAT1:               ;get starting LBA of FAT1 and store in AX
    mov ax, word [bpbReservedForBoot]     ;for lba2chs in read_disk

  ;fetch kernel
  read_FAT: ;into RAM (0x7C00:0200) i.e. after the bootloader
    mov  bx, disk_buffer                   ;set destination location on RAM for INT 13h
    call read_disk

    ;FAT LOADED

    ;set kernel location on RAM
    ;We want to load our kernel into 0x0150:0000 (0x1500).

    ;setting up "Buffer Address Pointer"
    mov  ax, 0x0150
    mov  es, ax                           ;segment:
    mov  bx, 0x0000                       ;offset
    push bx                               ;save on stack

load_kernel:
  mov  ax, word [cluster]                 ;set first cluster of the image to conv. for cluster2lba
  pop  bx                                 ;restore BX for this iteration

  call cluster2lba      ;conv. our cluster# to LBA for read_disk which convs. LBA to CHS
  xor  cx, cx
  mov  cl, byte [bpbSectorsPerCluster]    ;read one cluster/sector (1 sector per cluster)
  call read_disk                          ;READ.  (Cluster to LBA to CHS, then read)
  push bx                                 ;Save Buffer Address pointer for next iteration (ES:BX),
                                          ;'cause we'll overwrite it later to calc next cluster.

  calc_next_cluster12:
    mov  ax, word [cluster]               ;load cluster
                                          ;In FAT12, clusters are of 12 bits.
                                          ;So, our only option to read 12 bits is to read 16
                                          ;and adjust it accordingly.

    ;A FAT entry is of 12 bits, so, multiply the 2-byte entry by 1.5 to get byte it's offset.
    ;next_cluster = [cluster] + ([cluster] * 1.5)
    mov  cx, ax
    mov  dx, ax                           ;1
    shr  dx, 0x0001                       ;div by 2
    add  cx, dx                           ;1 + 0.5

    add  bx, cx                           ;offset into FAT for the subsequent entry
    mov  dx, word [bx]
    test ax, 0x0001                       ;check even odd in the original cluster
    ;zero if even cluster
    ;one if odd cluster

    jnz odd

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;    _________________________________________________________________________________________     ;
;   |                |                |                |                |                |         ;
;   | 01011101   0111 0101   01110101 | 00111101   0011 1010   11101001 | 00111101   0011 1101     ;
;   |                |                |                |                |                |         ;
;   |                |---cluster #3---|                |---cluster #5---|                |         ;
;   |---cluster #2---|                |---cluster #4---|                |---cluster #6---|         ;
;   |________________|________________|________________|________________|________________|____     ;
;                                                                                                  ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;

    even:           ;if cluster is even, mask out high 4 bits belonging to the next cluster.
      and dx, 0000111111111111b           ;take lower 12 bits
      jmp short check_EOF

    odd:            ;if cluster is odd, drop the lower 4 bits which belongs to the previous cluster.
      shr dx, 0x0004                      ;adjust to take higher 12 bits

    check_EOF:
    	mov word [cluster], dx              ;queue next cluster (adjusted)
      cmp dx, 0x0FF0			            ;0x0FF0 = EOF

  	jl load_kernel                        	;next


DONE:					                            ;READY
  pop bx				                          ;release stack
	mov dl, byte [bootdev]		              ;restore dl with boot device

;===================================================================================================
;READY:

    bputb msg_ready                        ;put message- ready
    bsystem_pause
    bclrscr

    jmp kernel_main_addr_seg:kernel_main_addr_offset    ;far jmp to 0x0150:0000 (0x1500)

;===================================================================================================
;data section:
msg_boot                db 'B'

msg_sect_read_err       db 'R'
msg_sect_reading        db '_'
msg_sect_read_ok        db '^'

msg_kernel_found        dw 'K'
msg_kernel_missin       db 'X'

msg_ready               db '>'


data_area_lba           dw 0            ;Data Area starting LBA

cluster                 dw 0            ;pointer to the current cluster of KERNEL.BIN

cylinder                db 0
head                    db 0
sector                  db 0

bootdev                 db 0

fats_size               dw 0             ;size of FAT1 + FAT2

kernel_filename         db 'KERNEL  BIN' ;11 chars,  8 : 3, padded with spaces.

;===================================================================================================

%INCLUDE "src/boot/routines/stdlib/lib.asm"
%INCLUDE "src/boot/routines/disk/conv.asm"
%INCLUDE "src/boot/routines/disk/reader.asm"

;===================================================================================================
;Padding + MBR signature + I/O buffer start:

times 510 - ($ - $$) db 0 ;Pad out the rest of the file with 0s until 510 bytes
dw    0xAA55              ;MBR signature

disk_buffer:              ;@ 0x7E00

;===================================================================================================

;                                 END OF BOOTLOADER
;                     DATA ABOVE THIS LINE IS LOST FROM THIS STAGE

;===================================================================================================
