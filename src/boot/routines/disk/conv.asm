;===================================================================================================
; conv.asm
;
;   This file contains routines to carry out conversion between various types of disk adresses.
;===================================================================================================

lba2chs:          ;Calculates the Cylinder-Head-Sector from a Logical Block Address.
  ;INPUT:  LBA in AX.
  ;OUTPUT: CHS in variables on memory for INT 0x13.

  ;Cylinder  =  LBA  / (sectors_per_track * heads_per_cylinder)
  ;Head      = (LBA  / sectors_per_track) % heads_per_cylinder
  ;Sector    = (LBA  % sectors_per_track) + 1

  ;calc sector:
  xor dx, dx                        ;clear out the remainder field
  div word [bpbSectorsPerTrack]     ;calc
  ;AX = AX / sectors_per_track
  ;DX = AX % sectors_per_track
  inc dl
  ;(logical_sector % sectors_per_track)  + 1
  mov byte [sector], dl             ;save sector to memory

  ;calc head & cylinder:
  xor dx, dx                        ;clear out remainder field
  div word [bpbHeadsPerCylinder]    ;calc
  ;AX = (LBA / sectors_per_track) * heads_per_cylinder
  ;DX = (LBA / sectors_per_track) % heads_per_cylinder
  mov byte [cylinder], al           ;save cylinder
  mov byte [head],     dl           ;save head

  ret                               ;done




cluster2lba:      ;Calculates LBA from cluster# and adjust with root_dir_lba.
  ;INPUT:  cluster# in AX.
  ;OUTPUT: LBA in AX.

  ;First data cluster is #2, so we adjust 2 before proceeding.
  ;Absolute LBA = ((cluster# - 2) * sectors_per_cluster)                            :LBA
  ;                + (root_dir_starting_sector + root_dir_size)                     ;adjustment

  ;Specific: LBA get calculated through cluster2lba only during loading KERNEL.BIN off the disk,
  ;          hence the adjustment, otherwise, just pass the LBA through AX to lba2chs for read_disk.

  sub ax, 2                         ;AX = cluster# - 2

  xor cx, cx                        ;clear out cx before mov & mul
  mov cl, byte [bpbSectorsPerCluster]
  mul cx       ;AX = AX * sectors_per_cluster also conv. to 2-byte value

  add ax, word [data_area_lba]      ;adjust with starting data_area_lba

  ret                               ;done

;===================================================================================================