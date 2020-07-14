;===================================================================================================
; stdio.asm
;
;   This file contains all the routines for the implementation of a stdio API.
;===================================================================================================

putuint16:              ;Prints unsigned integers to screen.
  ;INPUT:  16-bit unsigned integer in AX (0-65535).
  ;OUTPUT: Integer on screen.

  xor dx, dx
  xor cx, cx

  test ax, ax           ;is ax != 0?
  jne  .loop_div10      ;then, compute ASCII

  ;if ax = 0, then
  mov al, '0'
  mov ah, 0x000E        ;select subfunction: "Write Character in TTY Mode"
  int 0x10              ;print 0 directly

  jmp .doneuint16
  ;else:

  .loop_div10:
    test ax, ax         ;ax = dividend (input)
    je   .outuint16     ;when ax becomes 0, print integer

    ;else
    mov  bx, 10         ;divisor
    div  bx             ;ax/bx         ax = quotient      dx = remainder
    push dx             ;push dx in stack to get result in reverse order (LIFO)
    inc  cx             ;count digit extractions

    xor  dx, dx         ;reset remainder storage
    jmp  .loop_div10

  .outuint16:
    cmp  cx, 0
    je   .doneuint16

    pop  dx             ;start popping each digits
    add  dl, 48         ;48 = ASCII of zero.     (int to ASCII)

    ;print the number in ASCII
    mov  al, dl
    mov ah, 0x000E
    int 0x10            ;print

    dec  cx             ;decrease count, because of completed extractions.
    jmp  .outuint16

  .doneuint16:
    ret




prints16:               ;Prints a NULL terminated string on screen.
  ;INPUT:  NULL terminated string fromSI through AL.
  ;OUTPUT: ASCII string on screen.

  mov ah, 0x000E        ;SUBFUNCTION: "Write Character in TTY Mode"

  .prints16_repeat:
    lodsb               ;load successive bytes from si to al
    or al, al           ;al = 0?
    jz .prints16_return
    int 0x10             ;AL = input byte
    jmp .prints16_repeat

  .prints16_return:
    ;mov ah, 02h
    ;inc dh ;new line
    ;xor dl, dl
    ;int 10h

    ret




putb16:                   ;Prints a byte (char) from AL.
  ;INPUT:  Byte (char) in AL.
  ;OUTPUT: Print char on screen.

  lodsb                   ;load one byte from SI to AL

  mov ah, 0x000E          ;select subfunction: "Write Character in TTY Mode"
  int 0x10                ;write

  ret                     ;done




printcrlf16:              ;Prints CRLF
  ;INPUT:  N/A.
  ;OUTPUT: Prints carriage-return then line-feed.

  mov ah, 0x000E
  mov al, 13 ;CR
  int 0x10

  mov al, 10 ;LF
  int 0x10
  ret




clrscr16:                ;Clears scree.
  ;INPUT:  N/A.
  ;OUTPUT: Clears screen.

  push ax

  xor  ah, ah
  mov  al, 0x0003        ;CGA Color text of 80X25

  int  0x10

  pop  ax

  ret

;===================================================================================================
