       NAME  mp3port

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    MP3Port               	     			 ;
;                           MP3Port Event Handler               			 ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program is an event handler (interrupt service routine).
;                   It outputs data serially to the mp3 decoder board.
;
; Input:            None.
; Output:           MP3 board
; User Interface:   call functions:
;						audio_halt()
;						audio_play(buffAddr, len)
;						update(buffAddr, len)
;						InstallHandlerInt1()
;						InitMP3Port()
; Error Handling:   None.
;
; Algorithms:       Double buffers data going out to mp3 decoder board.
; Data Structures:  mp3buffsegment-stores segments of the two buffers
;					mp3buffindex-stores the index (offset) of the two buffers
;					mp3bufflength-stores the length of the two buffers
;
; Revision History:

;     5/5/08  Samuel Yang     
;     5/9/08 update() added
;	  6/6/08  fixing the code, commenting, still untested
;	  6/11/08  reading of IntREQST added in event handler
;	  6/11/08  updated event handler to use registers

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
; Operation:         Disables mp3 decoder board interrupt
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.
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
; Operation:         Copies buffer information, enables interrupt
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.
; Input:             None.
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

audio_play       PROC    NEAR
					PUBLIC audio_play
		PUSH BP
		MOV BP, SP
		PUSH SI
		PUSH DI
		PUSH AX
		PUSH BX
		MOV BX, [BP+8]
		MOV SI, [BP+4]
		MOV ES, [BP+6]

	
		MOV mp3buffsegment[mp3buff0], ES	;store buffer information
		MOV mp3buffindex[mp3buff0], SI
		MOV mp3bufflength[mp3buff0], BX


		MOV bufferRequired, TRUE			;flag new buffer1 required
		MOV bufferInUse, mp3buff0
	
		MOV DX, INT1Ctrlr					;enable mp3 board interrupt
		MOV AX, INT1CtrlrVal
		OUT DX, AL
		
		MOV DX, INTCtrlrEOI        			;send the EOI to the interrupt controller
        MOV AX, Int1Vec						; to kickstart
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
; Description:       This procedure updates the mp3 buffers if necessary.
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
; Data Structures:   mp3buffsegment/index/length
;
; Registers Changed: AX, flagging if a new buffer was used
; Stack Depth:       4 words
;
; Last Modified:     5-9-2008

update       PROC    NEAR
					PUBLIC update
		PUSH BP
		MOV BP, SP
		PUSH SI
		PUSH DI
		PUSH BX
		MOV BX, [BP+8]
		MOV SI, [BP+4]
		MOV ES, [BP+6]

		
		CMP bufferRequired, TRUE	;if no update required, jump to end
		JNE endUpdateFalse
		
		MOV bufferRequired, FALSE	;reset bufferRequired flag
		
		CMP bufferInUse, mp3buff0	;save location and length of new buffer
		JE replaceBuff1
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
endUpdateTrue:						;return TRUE or FALSE
		MOV AX, TRUE
		JMP endUpdate
endUpdateFalse:
		MOV AX, FALSE
endUpdate:	
		POP BX
		POP DI
		POP SI
		POP BP

		RET

update       ENDP



; Int1EventHandler
;
; Description:       This procedure is the event handler for the mp3 board
;				interrupt.  Upon interrupt, it will output data continuously
;				until the interrupt request is cleared.
;
; Operation:         Outputs data serially until the interrupt request is cleared
;				or a buffer switch is required.  
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  bufferInUse, buffInUse, mp3buffsegment/index/length
;				
; Input:             None.
; Output:            Data outputed serially to mp3 decoder board
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   mp3buffsegment/index/length
;
; Registers Changed: None
; Stack Depth:       7 words
;
; Last Modified:     6-11-2008

Int1EventHandler       PROC    NEAR
					PUBLIC Int1EventHandler
		PUSH AX                         ;save register values
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH ES
		PUSH SI
	
		MOV BX, bufferInUse				;get word to output
		MOV ES, mp3buffsegment[BX]
		MOV SI, mp3buffIndex[BX]
		MOV CX, mp3bufflength[BX]		
		
outputWord:	
		MOV DX, mp3portAddress			;prepare to output to address
		MOV AX, ES:[SI]
		
outputBits:								;actually outputs data, all 16 bits
		%REPEAT(8)(
		ROL AL, 1
		OUT DX, AL)
		XCHG AH, AL
		%REPEAT(8)(
		ROL AL, 1
		OUT DX, AL)

incIndex:		
		INC SI 	;increment buffer index
		INC SI
		DEC CX  ;decrement length
		CMP CX, lengthZero
		JNE checkStillInterrupting
		;JE switchBuffers
switchBuffers:		
		MOV bufferRequired, TRUE		;new buffer required
		INC bufferInUse					;switches between buffers 0 and 1
		INC bufferInUse
		AND bufferInUse, mp3buffRequiredMask
		JMP endInt1EventHandler
checkStillInterrupting:
		MOV DX, IntREQSTAddr
		IN AL, DX
		AND AL, Int1REQSTMask
		CMP AL, Int1REQSTPending		;if interrupt still pending, output another word
		JE outputWord
		;JNE writeRegistersBack
writeRegistersBack:
		MOV mp3buffindex[BX], SI
		MOV mp3bufflength[BX],CX
endInt1EventHandler:	
		
		MOV     DX, INTCtrlrEOI         ;send the EOI to the interrupt controller
        MOV     AX, Int1Vec
        OUT     DX, AL
		
		POP SI
		POP ES
		POP DX							
		POP CX
		POP BX
		POP AX
        IRET                            


Int1EventHandler       ENDP

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
; Shared Variables:  bufferRequired, bufferInUse

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
; Last Modified:     6-6-2008
InitMP3Port   PROC    NEAR
			PUBLIC InitMP3Port
		MOV bufferRequired, TRUE		;flag buffer required
		MOV bufferInUse, mp3buff0		;start off using buffer 0
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
		
		CALL audio_halt
		
        RET                    


InstallHandlerInt1  ENDP

CODE ENDS

;the data segment

DATA    SEGMENT PUBLIC  'DATA'
mp3buffsegment DW 2 DUP(?)				;stores segments of the two buffers
mp3buffindex  DW 2 DUP(?) 				;stores index (offset) of the two buffers
mp3bufflength DW 2 DUP(?)				;stores length of the two buffers
bufferRequired DB ?						;flags if a new buffer is required
bufferInUse    DW ?						;indicates which buffer is in use

DATA    ENDS
        END     
