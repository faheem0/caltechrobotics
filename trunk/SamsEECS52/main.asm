        NAME    main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                   Main                                     ;
;                            Test      		      	    ;
;                                  EE/CS  52                          	    ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program 
;
; Input:            Keypad
; Output:           Display
;
; User Interface:   No real user interface.  
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Known Bugs:       None.
; Limitations:      
;
; Revision History:
;    5/3/08 Samuel Yang


CGROUP  GROUP   CODE
DGROUP  GROUP   DATA , STACK


CODE    SEGMENT PUBLIC 'CODE'


        ASSUME  CS:CGROUP, DS:DGROUP, SS:DGROUP


EXTRN getkey:Near				
EXTRN key_available:Near     				

EXTRN display_time:near                  
EXTRN display_title:near

EXTRN display_artist:near
EXTRN display_status:near

EXTRN disp:near

MAIN2 PROC NEAR
		PUBLIC MAIN2
        MOV     AX, DGROUP;STACK               ;initialize the stack pointer
        MOV     SS, AX
        MOV     SP, OFFSET(DGROUP:TopOfStack);TopOfStack)

        MOV     AX, DGROUP;DATA                ;initialize the data segment
        MOV     DS, AX

testkd:		
		CALL disp
		
		JMP testkd
		RET
MAIN2 ENDP 

CODE    ENDS


;the data segment

DATA    SEGMENT PUBLIC  'DATA'

    
DATA    ENDS

;the stack
STACK   SEGMENT STACK  'STACK'

                DB      80 DUP ('Stack ')       ;240 words

TopOfStack      LABEL   WORD

STACK   ENDS

END
