;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  mp3port.INC                              ;
;                              MP3Port Event Handler                	     ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the definitions for the MP3Port Event Handler
; program (mp3port.ASM).
;
; Revision History:

;     5/5/2008 Samuel Yang     


mp3Loc   EQU     00000H           ;location of mp3 file
mp3testbufflength EQU 8192
mp3portAddress EQU 0000H    	  ;location of mp3 port, uses PCS0

mp3buff0 EQU 0
mp3buff1 EQU 2
mp3buffRequiredMask EQU 02h
lengthZero EQU 0

IntREQSTAddr	 EQU 0ff2Eh			;address of Interrupt Request register
Int1REQSTMask    EQU 0020h 			;get condition of interrupt 1
Int1REQSTPending EQU 0020h			;value if a request is pending on int1