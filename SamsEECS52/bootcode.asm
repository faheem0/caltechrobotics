        NAME    BOOT
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                   Boot Code                                ;
;                       For booting mp3 player from ROM                      ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

; Description:      This program contains boot code to start the mp3 player
;				from ROM.
; Input:            None.
; Output:           None.
; User Interface:   None.
; Error Handling:   None.
; Algorithms:       None.
; Data Structures:  None.
;
; Revision History:
;     4/26/08  Samuel Yang  file started
;     6/11/08  Samuel Yang	code debugged, works

$INCLUDE(bootcode.INC)

;segment register assumptions (only CS for this code)
ASSUME CS:BOOT

EXTRN Start:FAR ;declare the startup code, must be FAR

;the actual boot code-should be located at FFFF:0000
BOOT SEGMENT WORD PUBLIC 'BOOT'

BootUp:
MOV DX, UCSCtrl ;setup UCS control register to match ROM size
MOV AX, UCSCtrlVal
OUT DX,AL 		

JMP Start		;UCS is setup, now jump (FAR) to startup code

BOOT ENDS

END