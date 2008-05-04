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


KeypadAddress   EQU     0080H           ;keypad address

KEYPADDATAMASK EQU 000fh                ;only use 4 bits

