CPU x86-64

USE16

BITS 16


%INCLUDE "src/stubkernel/api/stdio.inc"
%INCLUDE "src/stubkernel/api/sysapi.inc"


start:

cli				; Clear interrupts
mov ax, cs
mov ds, ax			; Set stack segment and pointer
mov es, ax


cld				; The default direction for string operations
                ; will be 'up' - incrementing address in RAM

mov ax, 0x0500
mov bp, ax			    ; Set all segments to match where kernel is loaded
mov ss, ax			    ; After this, we don't need to bother with
mov sp, 0x14FF			; segments ever again, as MikeOS and its programs
sti

printstr msg

shell:
    printstr prompt

    system_pause

     jmp shell  ;re-show the prompt after RET

hlt


%INCLUDE "src/stubkernel/api/stdio.asm"
%INCLUDE "src/stubkernel/api/sysapi.asm"

;CRLF
dbg_str db 'RECHABLE', 10, 13, 0
msg db 'KERNEL', 10, 13, 0
prompt db 10,13, 35, 0


;END
times 26368 - ($ - $$) db 0     ;kernel image size: 26368 Bytes
