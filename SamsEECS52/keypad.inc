;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  keypad.INC                                ;
;                              Keypad Event Handler                          ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the definitions for the Keypad Event Handler
; program (keypad.ASM).
;
; Revision History:

;     5/2/2008 Samuel Yang 
;	  6/11/2008 Samuel Yang touchkey support added    


KeypadAddress   EQU     0080H           ;keypad address

KEYPADDATAMASK  EQU 	000fh           ;only use 4 bits

TouchkeyAddress EQU     0200H			;touchkey address

TOUCHKEYDATAMASK EQU 00fh				;comment here