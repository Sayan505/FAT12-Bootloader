;===================================================================================================
;This file contains all the routines for the implementation of the system API.
;===================================================================================================
;debug16 dbg_str        ;outputs a verbose string to verify reachable code

system_pause16:         ;halts exec until kbhit
     push ax
     mov ah, 00h
     int 16h
     pop ax
     ret

;===================================================================================================
