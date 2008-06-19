       NAME  timer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    timer               	    	    	 ;
;                           Timer Event Handler                  			 ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program an event handler (interrupt service routine).
;                   It handles the timer overflow interrupt, keeping track of 
;					elapsed time for the 80188 mp3 player.
;
; Input:            None.
; Output:           None.
; User Interface:   call function: 
;						elapsed_time()
;						InitElapsedTimer()
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Revision History:

;     5/30/08 copied from EE/CS 51 code
;	  6/11/08 interrupts only every 10ms

; local include files
$INCLUDE(boolean.INC)
$INCLUDE(timer.INC)

CGROUP GROUP CODE
DGROUP GROUP DATA


CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS:CGROUP, DS:DGROUP

; elapsed_time
;
; Description:       This procedure returns the elapsed time in ms since the last function call
;
; Operation:         returns msElapsed, resets it to 0
;
; Arguments:         None.
; Return Value:      ms elapsed since last call
;
; Local Variables:   None.
; Shared Variables:  msElapsed
;
; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None
; Stack Depth:       0 words
;
; Last Modified:     5-30-2008

elapsed_time       PROC    NEAR
					PUBLIC elapsed_time
		
		MOV AX, msElapsed
		
		MOV msElapsed, 0	;reset counter
	
		RET

elapsed_time ENDP

; InitElapsedTimer
;
; Description:       This procedure inits everything for keeping track of elapsed time
;
; Operation:         Initializes counter, timer0
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  msElapsed
;
; Input:            None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None
; Stack Depth:       0 words
;
; Last Modified:     5-30-2008

InitElapsedTimer       PROC    NEAR
					PUBLIC InitElapsedTimer
				
		CALL InstallHandlerT0	;initialize event handler
		CALL InitTimer0			;initialize timer
		MOV msElapsed, 0		;reset timer	

		RET

InitElapsedTimer ENDP

; Timer0EventHandler
;
; Description:       This procedure is the event handler for the timer 0
;                    interrupt.   It keeps track of the elapsed time
;
; Operation:         increments msElapsed
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  msElapsed.

; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None
; Stack Depth:       3 words
;
; Author:            Samuel Yang
; Last Modified:     6-11-2008

Timer0EventHandler       PROC    NEAR
					PUBLIC Timer0EventHandler
		PUSH AX                         
		PUSH DX
		
		ADD msElapsed, MS_PER_INT		;update counter

EndTimerEventHandler:                   ;done taking care of the timer

        MOV     DX, INTCtrlrEOI         ;send the EOI to the interrupt controller
        MOV     AX, TimerEOI
        OUT     DX, AL
 
		POP DX						
		POP AX
        IRET                  

Timer0EventHandler       ENDP

; InitTimer0
;
; Description:       Initializes timer 0 to interrupt every so often to 
;				keep track of elapsed time	
;
; Operation:         Sets up timer control registers and resets counter.
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.
;
; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: AX, DX
; Stack Depth:       0 words
;
; Author:            Samuel Yang
; Last Modified:     6-11-2008

InitTimer0       PROC    NEAR
			PUBLIC InitTimer0
			
        MOV     DX, Tmr0Count  
        XOR     AX, AX
        OUT     DX, AL

        MOV     DX, Tmr0MaxCntA ;initialize for MS_PER_INT*COUNTS_PER_MS ms interrupts
        MOV     AX, MS_PER_INT*COUNTS_PER_MS
        OUT     DX, AL

        MOV     DX, Tmr0Ctrl    
        MOV     AX, Tmr0CtrlVal
        OUT     DX, AL

                                ;initialize interrupt controller for timers
        MOV     DX, INTCtrlrCtrl;setup the interrupt control register
        MOV     AX, INTCtrlrCVal
        OUT     DX, AL

        MOV     DX, INTCtrlrEOI ;send a timer EOI (to clear out controller)
        MOV     AX, TimerEOI
        OUT     DX, AL

        RET                  


InitTimer0       ENDP

; InstallHandlerT0
;
; Description:       Install the event handler for the timer interrupt.
;
; Operation:         Writes the address of the timer event handler to the
;                    appropriate interrupt vector.
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: flags, AX, ES
; Stack Depth:       0 words
;
; Author:            Glen George
; Last Modified:     Jan. 28, 2002

InstallHandlerT0  PROC    NEAR
			PUBLIC InstallHandlerT0


        XOR     AX, AX          ;clear ES (interrupt vectors are in segment 0)
        MOV     ES, AX
                                ;store the vector
        MOV     ES: WORD PTR (4 * Tmr0Vec), OFFSET(Timer0EventHandler)
        MOV     ES: WORD PTR (4 * Tmr0Vec + 2), SEG(Timer0EventHandler)

        RET                   

InstallHandlerT0  ENDP

CODE ENDS

;the data segment

DATA    SEGMENT PUBLIC  'DATA'
msElapsed DW ?					;ms elapsed since last function call

DATA    ENDS
        END     
