;===================================================================================================
; fat12_2880_BPB.inc
;
;   This file contains the BIOS Parameter Block (BPB),
;   along with the Extended BIOS Parameter Block (EBPB).
;===================================================================================================

;DOS 4.0 EBPB + FAT12

%macro install_bpb 0

;Disk Label:
OEMLabel db 'OEM_0000'

;BPB start:
bpbBytesPerSector       dw 512  ;0x0B
bpbSectorsPerCluster    db 2
bpbReservedForBoot      dw 1                ;number of Reserved sectors for the boot sector
bpbNumberOfFATs         db 2
bpbRootDirEntries       dw 224              ;244 entries (max) in the root directory
bpbLogicalSectors       dw 5760             ;number of sectors in our disk
bpbMediaDescriptor      db 0xF0
bpbSectorsPerFAT        dw 9                ;FAT1: 9 sectors, FAT2: 9 sectors
bpbSectorsPerTrack      dw 36
bpbHeadsPerCylinder     dw 2                ;number of heads
bpbHiddenSectors        dd 0
bpbLargeSectors         dd 0
;Extended BPB:
ebpbDriveNumber         resb 0              ;0 = first Floppy drive. DL is set by BIOS.
ebpbDirtyBit            resb 0
ebpbVolumeSignature     db 0x0029           ;DOS 4.0 EBPB signature
ebpbVolumeSerialNumber  dd 0xB16B00B5
ebpbVolumeLabel         db 'VOLUMELABEL'    ;11 Bytes exact
ebpbFileSystem          db 'FAT12   '       ;8 Bytes exact
;BPB end                        ;0x36

%endmacro

;===================================================================================================