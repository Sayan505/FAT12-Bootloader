;===================================================================================================
; lib.inc
;
;   This file contains all the macros that are needed to invoke the general bootloader routines.
;===================================================================================================

%macro bsystem_pause 0        ;Pauses execution until a key is pressed.
  ;INPUT:  N/A.
  ;OUTPUT: Halts exec until kbhit.
  
  call  bsystem_pause16
%endmacro




%macro bputb 1                ;Prints a byte (char) from AL.
  ;INPUT:  N/A.
  ;OUTPUT: Clears screen.

  pusha                       ;save all regs to stack
  
  mov   si, %1                ;put first arg on AL
  call  bputb16
  
  popa                        ;restore all regs from stack
%endmacro




%macro bclrscr 0              ;clears screen.
  ;INPUT: N/A.
  ;OUTPUT: Clears screen.

  call  bclrscr16
%endmacro




%macro bdebug16 0             ;Outputs a verbose char (byte): bdbg_str,
                              ;Disables Interrupts and Halts CPU.
  ;INPUT:  bdbg_b in SI.
  ;OUTPUT: Char bdbg_str on screen.

  bputb bdbg_b
  cli
  hlt
%endmacro

;===================================================================================================