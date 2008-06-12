        NAME    BOOT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                   Boot Code                                ;
;                               For booting from ROM                         ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;EECS 52 MP3 Player Boot Code
;Samuel Yang
;April 26, 2008
; June 11, 2008 debugged

$INCLUDE(bootcode.INC)


;segment register assumptions (only CS for this code)
ASSUME CS:BOOT

EXTRN Start:FAR ;declare the starup code, must be FAR

;the actual boot code-should be located at FFFF:0000
BOOT SEGMENT WORD PUBLIC 'BOOT'



BootUp:
MOV DX, UCSCtrl ;need to setup UCS control register to match ROM size
MOV AX,UCSCtrlVal
OUT DX,AL 		

JMP Start		;UCS setup, jump (FAR) to startup code

BOOT ENDS

END