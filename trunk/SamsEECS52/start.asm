        NAME    STARTUP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                   STARTUP                                  ;
;                               Startup code for mp3 player                  ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Description:      This program contains the startup code for the 80188 mp3 
;				player.  It sets up the groups and segments, initializes all
;				of the peripherals, then calls the main() function (C code).
;
; Input:            None.
; Output:           None.
; User Interface:   None.
; Error Handling:   None.
; Algorithms:       None.
; Data Structures:  None.
;
; Revision History:
;   04/26/08 Samuel Yang	    modified version of c0smrom.asm
;   05/30/08 Samuel Yang	    DRAM, IDE, elapsed_time added, unnested EXTRN's
;   06/11/08 Samuel Yang	    initialization of touchkey added

$INCLUDE(boolean.INC)
$INCLUDE(regAddrs.INC)
$INCLUDE(bootcode.INC)

; setup code and data groups
CGROUP  GROUP   CODE
DGROUP  GROUP   DATA, STACK

EXTRN InitCS:NEAR
EXTRN ClrIRQVectors:NEAR
EXTRN InstallHandlerInt0:NEAR
EXTRN InstallHandlerInt1:NEAR
EXTRN InitKeypad:NEAR
EXTRN InitMP3Port:NEAR
EXTRN InitDisplay:NEAR
EXTRN InitElapsedTimer:NEAR
EXTRN main:NEAR               ;declare the main function

; segment register assumptions
ASSUME  CS:CGROUP, DS:DGROUP, ES:NOTHING, SS:DGROUP

; the data segment - used for static and global variables
DATA    SEGMENT  WORD  PUBLIC  'DATA'


DATA    ENDS




; the stack segment - used for subroutine linkage, argument passing, and
; local variables
STACK   SEGMENT  WORD  STACK  'STACK'

        DB      80 DUP ('Stack   ')             ;320 words

TopOfStack      LABEL   WORD


STACK   ENDS




; the actual startup code - should be executed (jumped to) after reset
CODE    SEGMENT   PUBLIC  'CODE'
       
START LABEL FAR				;start the program
PUBLIC START				;public so can jump to from power on code
mainStart:                                  

		MOV DX, LCSCtrl		;need to setup LCS control register to match RAM size
		MOV AX, LCSCtrlVal
		OUT DX,AL 		
		
        MOV     AX, DGROUP  ;initialize the stack pointer
        MOV     SS, AX
        MOV     SP, OFFSET(DGROUP:TopOfStack)

        MOV     AX, DGROUP  ;initialize the data segment
        MOV     DS, AX
	
        CALL InitCS			;initialize chip selects, timers, interrupts, etc.
		CALL ClrIRQVectors
		CALL InitKeypad
		CALL InitDisplay	
		CALL InitMP3Port		
		CALL InitElapsedTimer
		CALL InstallHandlerInt1		
		CALL InstallHandlerInt0		;interrupts enabled here
                   
		CALL main			;run the main function (no arguments)
        JMP     mainStart   ;if return - reinitialize and try again

CODE    ENDS

END
