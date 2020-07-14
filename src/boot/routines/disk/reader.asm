;===================================================================================================
; reader.asm
;
;   This file contains the routine to read the FAT12 filesystem.
;===================================================================================================

read_disk:                                  ;Reads sectors from FAT12 disk.
  ;INPUT:  Sector count in CX (CL).
  ;        Destination in ES:BX (Buffer Address Pointer)
  ;OUTPUT: Data into the location pointed by ES:BX

  .loop_read_disk_main:
    push  ax                                ;save regs
    push  bx
    push  cx

    bputb msg_sect_reading                  ;put message- attempt read sector

    call lba2chs                            ;convert input LBA from AX and calc CHS for INT 13h

    mov   ax, 0x0201
    ;AH = 02h, select subfunction: "Read Sectors From Drive"
    ;AL = 01h, read one sector

    ;set outputs from lba2chs as inputs of INT 13h
    mov   ch, byte [cylinder]               ;set starting cylinder
    mov   cl, byte [sector]                 ;set starting sector
    mov   dh, byte [head]                   ;set head
    mov   dl, byte [bootdev]                ;set source volume

    int   0x13                              ;READ!!!
    jnc   .read_ok                          ;success if carry flag is not set. CF = 0

    ;if CF = 1
    bputb msg_sect_read_err                 ;put message- read error
    bsystem_pause
    int   0x19                              ;reboot

    .read_ok:                               ;read successful!
      ;pop regs from STACK in reverse order 'cause stack (restore)
      pop   cx
      pop   bx
      pop   ax

      ;queue next sector to read into so that we dont overwrite this and load it all
      add   bx, word [bpbBytesPerSector]    ;512 Bytes

      ;increment LBA address for lba2chs (lba2chs takes LBA in AX as input)
      inc   ax

      bputb msg_sect_read_ok                ;put msg- read OK

    loop  .loop_read_disk_main              ;loop CX times (read CX number of sectors)

  ret

;===================================================================================================
