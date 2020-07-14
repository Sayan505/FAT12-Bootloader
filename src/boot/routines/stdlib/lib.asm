;===================================================================================================
; lib.asm
;
;   This file contains all the general routines for the bootloader.
;===================================================================================================

bsystem_pause16:          ;Pauses execution until a key is pressed.
  ;INPUT:  N/A.
  ;OUTPUT: Halts exec until kbhit.
  
  push ax                 ;save AX before use

  xor  ah, ah             ;select subfunction: "Read key press"
  int  0x16               ;read

  pop  ax                 ;restore AX

  ret




bputb16:                  ;Prints a byte (char) from AL.
  ;INPUT:  byte (char) in AL.
  ;OUTPUT: Print char on screen.

  lodsb                   ;load one byte from SI to AL

  mov ah, 0x000E          ;select subfunction: "Write Character in TTY Mode"
  int 0x10                ;write

  ret                     ;done




bclrscr16:                ;Clears screen.
  ;INPUT:  N/A.
  ;OUTPUT: Clears screen.

  push ax

  xor  ah, ah
  mov  al, 0x0003         ;CGA Color text of 80X25

  int  0x10

  pop  ax

  ret




;bdebug16 bdbg_b          ;Outputs a verbose char (byte) bdbg_str to verify reachable code.
  ;INPUT:  bdbg_b on SI.
  ;OUTPUT: Char in bdbg_b on screen + disable Interrupts + halt CPU.

;===================================================================================================