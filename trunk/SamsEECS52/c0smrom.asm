        NAME    STARTUP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                   C0SMROM                                  ;
;                               Startup Template                             ;
;                    Intel C Small Memory Model, ROM Option                  ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains a template for the startup code used when interfacing to
; C code compiled with the Intel C compiler using the small memory model and
; ROM option.  It assumes nothing about the system hardware, it's main purpose
; is to setup the groups and segments correctly.  Note that most segments are
; empty, they are present only for the GROUP definitions.  The actual startup
; code for a system would include definitions for the global variables and all
; of the system initialization.  Note that the CONST segment does not exist
; for ROMmable code (it is automatically made part of the CODE segment by the
; compiler).
;
;
; Revision History:
;    3/7/94   Glen George       Initial revision.
;    2/28/95  Glen George       Fixed segment alignments.
;                               Fixed SP initialization.
;                               Removed CS:IP initialization (END Start -> END).
;                               Updated comments.
;    2/29/96  Glen George       Updated comments.
;    2/24/98  Glen George       Updated comments.
;   11/18/98  Glen George       Updated comments.
;   12/26/99  Glen George       Changed formatting.
;    1/30/02  Glen George       Added proper assume for ES.
;    1/27/03  Glen George       Changed to looping if main() returns instead
;                                  of halting.
;   12/31/03  Glen George       Made Start public so can be accessed from
;                                  power on segment.
;   04/26/08 Samuel Yang	    modified for his board

$INCLUDE(boolean.INC)
$INCLUDE(regAddrs.INC)
$INCLUDE(bootcode.INC)

; setup code and data groups
CGROUP  GROUP   CODE
DGROUP  GROUP   DATA, STACK

EXTRN InitCS:Near
EXTRN ClrIRQVectors:Near
EXTRN InstallHandlerInt0:Near
EXTRN InitKeypad:Near
EXTRN InitDisplay:Near
EXTRN   main:NEAR               ;declare the main function
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


       
START:

main0:                                  ;start the program
	;PUBLIC  Start			;public so can jump to from power on code

		MOV DX, LCSCtrl ;need to setup LCS control register to match RAM size
		MOV AX, LCSCtrlVal
		OUT DX,AL 		
		
        MOV     AX, DGROUP              ;initialize the stack pointer
        MOV     SS, AX
        MOV     SP, OFFSET(DGROUP:TopOfStack)

        MOV     AX, DGROUP              ;initialize the data segment
        MOV     DS, AX

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; user initialization code goes here ;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		CALL InitCS
		CALL ClrIRQVectors
		CALL InitKeypad
		CALL InitDisplay		
		CALL InstallHandlerInt0
		
        ;CALL    main2                    ;run the main function (no arguments)
		CALL main
        JMP     main0                   ;if return - reinitialize and try again



CODE    ENDS



        END START
