;===================================================================================================
;This file contains all the macros that are needed to invoke the system API.
;===================================================================================================

%macro system_pause 0       ;waits execution until kbhit
     call system_pause16
%endmacro




%macro debug16 0            ;outputs a verbose string: dbg_str
     printstr dbg_str
     cli
     hlt
%endmacro

;===================================================================================================
