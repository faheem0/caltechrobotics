; EECS 52 INCLUDE file for bootcode.asm
;Samuel Yang
;April 26, 2008

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