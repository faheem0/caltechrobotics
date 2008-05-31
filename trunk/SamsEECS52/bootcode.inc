;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  bootcode.INC                              ;
;                              Boot Code Register Values                     ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the definitions for bootcode.asm
;
; Revision History:

;     4/26/2008 Samuel Yang     File started

UCSCtrl equ 0FFA0h 		;address of UCMS
UCSCtrlVal     EQU     3000H          ;value to write to UCS Ctrl Register
                                        ;--11000000------  starting address 0F0000h (64k)
                                        ;-------------0--  enable bus ready
                                        ;--------------00  0 wait states                                        ;----000000------  reserved
LCSCtrl equ 0FFA2h 		;address of LCMS                                        
LCSCtrlVal     EQU     07C0H          ;value to write to LCS Ctrl Register
                                        ;--00011111------  ending address 07FFFFh (32k)
                                        ;-------------0--  enable bus ready
                                        ;--------------00  0 wait states 