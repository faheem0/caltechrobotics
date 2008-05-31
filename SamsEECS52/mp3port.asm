       NAME  mp3port

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    MP3Port               	     ;
;                           MP3Port Event Handler                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program an event handler (interrupt service routine).
;                   It handles sending data to the mp3 board.
;
; Input:            None.
; Output:           MP3 board
; User Interface:   None.
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Revision History:

;     5/5/08  Samuel Yang     
;     5/9/08 update() added

; local include files
$INCLUDE(mp3port.INC)
$INCLUDE(boolean.INC)
$INCLUDE(regAddrs.INC)

CGROUP GROUP CODE
DGROUP GROUP DATA


CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS:CGROUP, DS:DGROUP


; audio_halt
;
; Description:       Immediately halts audio play
;
; Operation:         Disables mp3 board interrupt
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.
; Input:            None.
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
; Last Modified:     5-9-2008

audio_halt       PROC    NEAR
					PUBLIC audio_halt
		PUSH AX
		PUSH DX
		
		MOV DX, INT1Ctrlr			;disable mp3 board interrupt
		MOV AX, INT1CtrlrValDisable
		OUT DX, AL
		
		POP DX
		POP AX
		RET

audio_halt       ENDP

; audio_play
;
; Description:       Begins playing audio from passed buffer
;
; Operation:         Copies buffer information, enables interrupts
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.
; Input:            None.
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
; Last Modified:     5-9-2008

audio_play       PROC    NEAR
					PUBLIC audio_play
		PUSH BP
		MOV BP, SP
		PUSH SI
		PUSH DI
		PUSH AX
		PUSH BX
		MOV BX, [BP+4]
		MOV SI, [BP+6]
		MOV ES, [BP+8]

	
		MOV mp3buffsegment[mp3buff0], ES	;store buffer information
		MOV mp3buffindex[mp3buff0], SI
		MOV mp3bufflength[mp3buff0], BX


		MOV bufferRequired, TRUE			;flag buffer1 required
		MOV bufferInUse, mp3buff0
	
		MOV DX, INT1Ctrlr					;enable mp3 board interrupt
		MOV AX, INT1CtrlrVal
		OUT DX, AL
		
		POP BX
		POP AX
		POP DI
		POP SI
		POP BP

		RET
		
		
		
	

audio_play       ENDP

; update
;
; Description:       This procedure updates the mp3 bvffers if necessary.
;
; Operation:         Reads data in, updates status of pressed key.
;
; Arguments:         address of new buffer in ES:SI, length in BX
; Return Value:      True if the new buffer was used, False otherwise
;
; Local Variables:   None.
; Shared Variables:  mp3buff1segment
;			    mp3buff2segment
;			    mp3buff1index
;			    mp3buff2index
;			    mp3buff1length
;			    mp3buff2length
; Input:            None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None
; Stack Depth:       5 words
;
; Last Modified:     5-9-2008

update       PROC    NEAR
					PUBLIC update
		PUSH BP
		MOV BP, SP
		PUSH SI
		PUSH DI
		PUSH AX
		PUSH BX
		MOV BX, [BP+4]
		MOV SI, [BP+6]
		MOV ES, [BP+8]

		
		CMP bufferRequired, TRUE
		JNE endUpdateFalse
		
		MOV bufferRequired, FALSE	;reset bufferRequired flag
		
		CMP bufferInUse, mp3buff0	;save location and length of new buffer
		JNE replaceBuff1
replaceBuff0:	
		MOV mp3buffsegment[mp3buff0], ES
		MOV mp3buffindex[mp3buff0], SI
		MOV mp3bufflength[mp3buff0], BX
		JMP endUpdateTrue
replaceBuff1:
		MOV mp3buffsegment[mp3buff1], ES
		MOV mp3buffindex[mp3buff1], SI
		MOV mp3bufflength[mp3buff1], BX
		;JMP endUpdateTrue
endUpdateTrue:	
		MOV AX, TRUE
		JMP endUpdate
endUpdateFalse:
		MOV AX, FALSE
endUpdate:	
		POP BX
		POP AX
		POP DI
		POP SI
		POP BP

		RET

update       ENDP



; Int1EventHandler
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
; Last Modified:     5-5-2008

Int1EventHandler       PROC    NEAR
					PUBLIC Int1EventHandler
		PUSH AX                         ;save register values
		PUSH BX
		PUSH CX
		PUSH DX
		
		MOV BX, mp3index
		INC BX
		INC BX
		;do wrap here
		AND BX, mp3testbufflength-1
		MOV mp3index, BX
		MOV AX, mp3buff[BX]
	
dataReady:
		MOV DX, mp3portAddress
		ROL AL, 1
		ROL AH, 1
		
outputBits:		
		OUT DX, AL
		ROL AL, 1
		OUT DX, AL
		ROL AL, 1
		OUT DX, AL
		ROL AL, 1
		OUT DX, AL
		ROL AL, 1
		OUT DX, AL
		ROL AL, 1
		OUT DX, AL
		ROL AL, 1
		OUT DX, AL
		ROL AL, 1
		OUT DX, AL
		ROL AL, 1
		XCHG AH, AL
		OUT DX, AL
		ROL AL, 1
		OUT DX, AL
		ROL AL, 1
		OUT DX, AL
		ROL AL, 1
		OUT DX, AL
		ROL AL, 1
		OUT DX, AL
		ROL AL, 1
		OUT DX, AL
		ROL AL, 1
		OUT DX, AL
		ROL AL, 1
		OUT DX, AL
		ROL AL, 1
		
		MOV     DX, INTCtrlrEOI         ;send the EOI to the interrupt controller
        MOV     AX, Int1Vec
        OUT     DX, AL
		
		POP DX							;restore register values
		POP CX
		POP BX
		POP AX
        IRET                            ;and return (Event Handlers end with IRET not RET)


Int1EventHandler       ENDP

Int1EventHandlerREAL       PROC    NEAR
					PUBLIC Int1EventHandlerREAL
		PUSH AX                         ;save register values
		PUSH BX
		PUSH CX
		PUSH DX
		
		MOV BX, bufferInUse				;get byte to output
		MOV ES, mp3buffsegment[BX]
		MOV SI, mp3buffIndex[BX]		
		MOV AL, ES:[SI]
		
		MOV DX, mp3portAddress
		ROL AL, 1
		MOV CX, 8
outputBitsr:		
		OUT DX, AL
		ROL AL, 1
		LOOP outputBitsr
		
		;increment buffer index
		DEC mp3bufflength[BX]
		CMP mp3bufflength, lengthZero
		JNE doneInc
		;JE switch buffers
		MOV bufferRequired, TRUE				;new buffer required
		INC bufferInUse							;switches buffers between 0 and 1
		AND bufferInUse, mp3buffRequiredMask
		;JMP doneInc
doneInc:		
		MOV     DX, INTCtrlrEOI         ;send the EOI to the interrupt controller
        MOV     AX, Int1Vec
        OUT     DX, AL
		
		POP DX							;restore register values
		POP CX
		POP BX
		POP AX
        IRET                            ;and return (Event Handlers end with IRET not RET)


Int1EventHandlerREAL       ENDP

; InitMP3Port
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
InitMP3Port   PROC    NEAR
			PUBLIC InitMP3Port
		;do nothing yet
		PUSH BX
		PUSH CX
		MOV mp3index, 0
		
		POP CX
		POP BX
		RET
InitMP3Port   ENDP








; InstallHandlerInt1
;
; Description:       Install the event handler for the int1 interrupt.
;
; Operation:         Writes the address of the int 1 event handler to the
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
; Registers Changed: flags, AX, ES, DX
; Stack Depth:       0 words
;
; Author:            Samuel Yang
; Last Modified:     5-5-2008

InstallHandlerInt1  PROC    NEAR
			PUBLIC InstallHandlerInt1


        XOR     AX, AX          ;clear ES (interrupt vectors are in segment 0)
        MOV     ES, AX
                                ;store the vector
        MOV     ES: WORD PTR (4 * Int1Vec), OFFSET(Int1EventHandler)
        MOV     ES: WORD PTR (4 * Int1Vec + 2), SEG(Int1EventHandler)

		MOV DX, INT1Ctrlr
		MOV AL, INT1CtrlrVal
		OUT DX, AL
		
		MOV     DX, INTCtrlrEOI         ;send the EOI to the interrupt controller
        MOV     AX, Int1Vec
        OUT     DX, AL
		;STI ;enable interrupts
		
        RET                     ;all done, return


InstallHandlerInt1  ENDP





CODE ENDS

;the data segment

DATA    SEGMENT PUBLIC  'DATA'
mp3index DW 0


mp3buffsegment DW 2 DUP(?)
mp3buffindex  DW 2 DUP(?) 
mp3bufflength DW 2 DUP(?)
bufferRequired DB ?
bufferInUse    DW ?

mp3buff DW (mp3testbufflength/2)	DUP(?)
DATA    ENDS




        END     
