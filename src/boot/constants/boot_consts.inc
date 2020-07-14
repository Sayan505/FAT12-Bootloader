;===================================================================================================
; boot_consts.inc
;
;   This file contains the constants used by the Bootloader.
;===================================================================================================

%define bootloader_addr_seg     0x07C0 ;The BIOS loads the bootsector @ addr 0x7c00 (0x07C0:0000).

%define kernel_main_addr_seg    0x0150 ;0x1500 to 0x7BFF, 26368 Bytes of kernel.
                                       ;This is where we want to load our kernel.
                                       ;Can be changed to any free region in the memory.

%define kernel_main_addr_offset 0x0000 ;kernel @ 0x1500:0000

;===================================================================================================