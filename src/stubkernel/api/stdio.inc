;===================================================================================================
; stdio.inc
;
;   This file contains all the macros of the stdio API.
;===================================================================================================

%macro putuint 1        ;Prints an unsigned integer (0 - 65535).
  pusha                 ;save all registers

  mov ax, %1
  call putuint16

  popa      ;restore all registers
  %endmacro




%macro printstr 1        ;Prints a ASCII string to screen.
  pusha

  mov si, %1	           ;put string's base addr into SI
  call prints16	         ;call our string-printing routine

  popa
%endmacro


;====================================================================================================


%macro putb 1            ;Prints a byte (char) from AL
     push ax
     
     mov al, %1
     call putb16
     
     pop ax
%endmacro


;====================================================================================================


%macro printcrlf 0      ;prints carriage-return then line-feed
     push ax
     
     call printcrlf16
     
     pop ax
%endmacro


;====================================================================================================


%macro clrscr 0         ;clears screen
     push ax
     
     call clrscr16

     pop ax
%endmacro


;====================================================================================================


%macro printint 1       ;prints a signed integer
    pusha

    mov ax, %1
    call printint16

    popa
%endmacro


;====================================================================================================
