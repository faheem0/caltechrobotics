       NAME  keypad

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    keypad                                ;
;                           Keypad Event Handler                             ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program an event handler (interrupt service routine).
;                   It reads from the keypad.
;
; Input:            Keypad
; Output:           None.
; User Interface:   call functions getkey() , key_available()
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Revision History:

;     5/2/08  Samuel Yang     
;	  6/11/08 Samuel Yang touch key support added (INT2, PCS3)


; local include files
$INCLUDE(keypad.INC)
$INCLUDE(boolean.INC)
$INCLUDE(regAddrs.INC)

CGROUP GROUP CODE
DGROUP GROUP DATA


CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS:CGROUP, DS:DGROUP



; Int0EventHandler
;
; Description:       This procedure is the event handler for when the
;                       keypad debouncing chip signals a pressed key.
;
; Operation:         Reads data in, updates status of pressed key.
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  keyCode, keyReady

; Input:            From keypad debouncing chip.
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
; Last Modified:     5-2-2008

Int0EventHandler       PROC    NEAR
					PUBLIC Int0EventHandler
		PUSH AX                         ;save register values
		PUSH DX
		XOR AX, AX
		XOR DX, DX
		MOV DX, keypadAddress
		IN AL, DX
		AND AX, KEYPADDATAMASK
		MOV keyCode, AX
		MOV keyReady, TRUE
		
		
        MOV     DX, INTCtrlrEOI         ;send the EOI to the interrupt controller
        MOV     AX, Int0Vec
        OUT     DX, AL
		
		
		POP DX							;restore register values
		POP AX
        IRET                            ;and return (Event Handlers end with IRET not RET)


Int0EventHandler       ENDP

; Int2EventHandler
;
; Description:       This procedure is the event handler for when the
;                       keypad debouncing chip signals a pressed key.
;
; Operation:         Reads data in, updates status of pressed key.
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  keyCode, keyReady

; Input:            From keypad debouncing chip.
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
; Last Modified:     6-11-2008

Int2EventHandler       PROC    NEAR
					PUBLIC Int2EventHandler
		PUSH AX                         ;save register values
		PUSH DX
		XOR AX, AX
		XOR DX, DX
		MOV DX, touchkeyAddress
		IN AL, DX
		AND AX, TOUCHKEYDATAMASK
		;MOV keyCode, AX
		;MOV keyReady, TRUE
		;DO STUFF HERE
        MOV     DX, INTCtrlrEOI         ;send the EOI to the interrupt controller
        MOV     AX, Int2Vec
        OUT     DX, AL
		
		
		POP DX							;restore register values
		POP AX
        IRET                            ;and return (Event Handlers end with IRET not RET)


Int2EventHandler       ENDP


; InitKeypad
;
; Description:       This procedure initializes everything for keypad
;
; Operation:        Initializes shared variables
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  keyCode, keyReady

; Input:            None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None
; Stack Depth:       1 words
;
; Last Modified:     5-2-2008
InitKeypad   PROC    NEAR
			PUBLIC InitKeypad
		MOV keyReady, FALSE	
		MOV keyCode, 0 					;this doesn't really have to be initialized since keyReady is FALSE
		
		RET
InitKeypad   ENDP

; key_available
;
; Description:       Returns true if a key has been pressed
;
; Operation:        Returns shared variable
;
; Arguments:         None.
; Return Value:     keyReady in AL
;
; Local Variables:   None.
; Shared Variables:  keyReady

; Input:            None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: AL
; Stack Depth:       1 words
;
; Last Modified:     5-2-2008
key_available   PROC    NEAR
			PUBLIC key_available
		MOV AL, keyReady	
		RET
key_available   ENDP

; getkey
;
; Description:       Returns keycode of pressed key
;
; Operation:        Returns shared variable
;
; Arguments:         None.
; Return Value:     keyCode in AX
;
; Local Variables:   None.
; Shared Variables:  keyCode, keyReady

; Input:            None.
; Output:            None.
;
; Error Handling:    getkey should only be called if key_available returns TRUE
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: AX
; Stack Depth:       1 words
;
; Last Modified:     5-2-2008
getkey   PROC    NEAR
			PUBLIC getkey
		MOV AX, keyCode
		MOV keyReady, FALSE       	 ;reset keyReady flag since no new pressed keys to report
		RET
getkey   ENDP


; InitCS
;
; Description:       Initialize the Peripheral Chip Selects on the 80188.
;
; Operation:         Write the initial values to the PACS and MPCS registers.
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
; Registers Changed: AX, DX
; Stack Depth:       0 words
;
; Author:            Glen George
; Last Modified:     Oct. 29, 1997

InitCS  PROC    NEAR
		PUBLIC InitCS

		
		
        MOV     DX, PACSreg     ;setup to write to PACS register
        MOV     AX, PACSval
        OUT     DX, AL          ;write PACSval to PACS (base at 0, 3 wait states)

        MOV     DX, MPCSreg     ;setup to write to MPCS register
        MOV     AX, MPCSval
        OUT     DX, AL          ;write MPCSval to MPCS (I/O space, 3 wait states)

		MOV DX, MMCSaddr	;init MMCS
		MOV AX, MMCSvalue
		OUT DX, AX
		
        RET                     ;done so return


InitCS  ENDP








; InstallHandlerInt0
;
; Description:       Install the event handler for the int0 interrupt.
;
; Operation:         Writes the address of the int 0 event handler to the
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
; Author:            Samuel Yang
; Last Modified:     5-2-2008

InstallHandlerInt0  PROC    NEAR
			PUBLIC InstallHandlerInt0


        XOR     AX, AX          ;clear ES (interrupt vectors are in segment 0)
        MOV     ES, AX
                                ;store the vector
        MOV     ES: WORD PTR (4 * Int0Vec), OFFSET(Int0EventHandler)
        MOV     ES: WORD PTR (4 * Int0Vec + 2), SEG(Int0EventHandler)

		MOV DX, INT0Ctrlr
		MOV AL, INT0CtrlrVal
		OUT DX, AL
		STI ;enable interrupts
		
        RET                     ;all done, return


InstallHandlerInt0  ENDP

; InstallHandlerInt2
;
; Description:       Install the event handler for the int2 interrupt.
;
; Operation:         Writes the address of the int 2 event handler to the
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
; Author:            Samuel Yang
; Last Modified:     6-11-2008

InstallHandlerInt2  PROC    NEAR
			PUBLIC InstallHandlerInt2


        XOR     AX, AX          ;clear ES (interrupt vectors are in segment 0)
        MOV     ES, AX
                                ;store the vector
        MOV     ES: WORD PTR (4 * Int2Vec), OFFSET(Int2EventHandler)
        MOV     ES: WORD PTR (4 * Int2Vec + 2), SEG(Int2EventHandler)

		MOV DX, INT2Ctrlr
		MOV AL, INT2CtrlrVal
		OUT DX, AL
		;STI ;enable interrupts
		
        RET                     ;all done, return


InstallHandlerInt2  ENDP


; ClrIRQVectors
;
; Description:      This functions installs the IllegalEventHandler for all
;                   interrupt vectors in the interrupt vector table.  Note
;                   that all 256 vectors are initialized so the code must be
;                   located above 400H.  The initialization skips  (does not
;                   initialize vectors) from vectors FIRST_RESERVED_VEC to
;                   LAST_RESERVED_VEC.
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  CX    - vector counter.
;                   ES:SI - pointer to vector table.
; Shared Variables: None.
; Global Variables: None.
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   flags, AX, CX, SI, ES
; Stack Depth:      1 word
;
; Author:           Glen George
; Last Modified:    Feb. 8, 2002

ClrIRQVectors   PROC    NEAR
			PUBLIC ClrIRQVectors


InitClrVectorLoop:              ;setup to store the same handler 256 times

        XOR     AX, AX          ;clear ES (interrupt vectors are in segment 0)
        MOV     ES, AX
        MOV     SI, 0           ;initialize SI to skip RESERVED_VECS (4 bytes each)

        MOV     CX, 256         ;up to 256 vectors to initialize


ClrVectorLoop:                  ;loop clearing each vector
				;check if should store the vector
	CMP     SI, 4 * FIRST_RESERVED_VEC
	JB	DoStore		;if before start of reserved field - store it
	CMP	SI, 4 * LAST_RESERVED_VEC
	JBE	DoneStore	;if in the reserved vectors - don't store it
	

DoStore:                        ;store the vector
        MOV     ES: WORD PTR [SI], OFFSET(IllegalEventHandler)
        MOV     ES: WORD PTR [SI + 2], SEG(IllegalEventHandler)

DoneStore:			;done storing the vector
        ADD     SI, 4           ;update pointer to next vector

        LOOP    ClrVectorLoop   ;loop until have cleared all vectors
    


EndClrIRQVectors:               ;all done, return
        RET


ClrIRQVectors   ENDP



; IllegalEventHandler
;
; Description:       This procedure is the event handler for illegal
;                    (uninitialized) interrupts.  It does nothing - it just
;                    returns after sending a non-specific EOI.
;
; Operation:         Send a non-specific EOI and return.
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
; Registers Changed: None
; Stack Depth:       2 words
;
; Author:            Glen George
; Last Modified:     Dec. 25, 2000

IllegalEventHandler     PROC    NEAR

        NOP                             ;do nothing (can set breakpoint here)

        PUSH    AX                      ;save the registers
        PUSH    DX

        MOV     DX, INTCtrlrEOI         ;send a non-sepecific EOI to the
        MOV     AX, NonSpecEOI          ;   interrupt controller to clear out
        OUT     DX, AL                  ;   the interrupt that got us here

        POP     DX                      ;restore the registers
        POP     AX

        IRET                            ;and return


IllegalEventHandler     ENDP


CODE ENDS

;the data segment

DATA    SEGMENT PUBLIC  'DATA'
keyCode  DW ?
keyReady DB ?
DATA    ENDS




        END     
