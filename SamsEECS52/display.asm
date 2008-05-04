       NAME  display

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    Display                              ;
;                           Display Functions                         ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program contains the functions to
; 			display 
;
; Input:            None.
; Output:           40 Character LCD
; User Interface:   call functions:
;				display_time(word)
;				display_status(word)
;				display_title(byte)
;				display_artist(byte)
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Revision History:

;     5/2/08  Samuel Yang     


; local include files
$INCLUDE(display.INC)
$INCLUDE(boolean.INC)


CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS:CODE, DS:DATA





; InitDisplay
;
; Description:       This procedure initializes everything for display
;
; Operation:        Initializes shared variables
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  

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
InitDisplay   PROC    NEAR
			PUBLIC InitDisplay
			PUSH AX
			PUSH DX
			
			MOV DX, displayAddressCMD
			MOV AL, functionSet
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, clearScreen
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, entryModeSet
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, displayOnOffCtrl
			OUT DX, AL
			CALL readBusyFlag
			
			POP DX
			POP AX
			RET
InitDisplay   ENDP


; display_title
;
; Description:       This procedure displays title in the dedicated spot on the LCD
;
; Operation:        	
;			Uses DisplayStr
; Arguments:         
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.

; Input:            None.
; Output:            Displays title on LCD.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None
; Stack Depth:       7 words
;
; Last Modified:     5-2-2008
display_title   PROC    NEAR
			PUBLIC display_title
		
		PUSH BP
		MOV BP, SP
		PUSH SI
		PUSH DI
		PUSH AX
		PUSH BX
		MOV ES, [BP+4]
		MOV SI, [BP+6]
		
		MOV AX, titleLength
		MOV BX, titleOffset
		
		CALL DisplayStr
		
		POP BX
		POP AX
		POP DI
		POP SI
		POP BP
		
		
		RET
display_title   ENDP

; display_status
;
; Description:       This procedure displays status in the dedicated spot on the LCD
;
; Operation:       Looks up predefined status strings from "statuses" table 	
;			Uses DisplayStr to display the looked up status string.
; Arguments:   Status code (byte) in CX      
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.

; Input:            None.
; Output:            Displays status on LCD.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None
; Stack Depth:       7 words
;
; Last Modified:     5-2-2008
display_status   PROC    NEAR
			PUBLIC display_status
		
		PUSH BP
		MOV BP, SP
		PUSH SI
		PUSH DI
		PUSH AX
		PUSH BX
		MOV CX, [BP+4]
		
		MOV AL, statusStringLength
		MUL CL
		PUSH SEG(statuses)
		POP ES
		MOV BX, OFFSET(statuses)
		ADD BX, AX
		MOV SI, AX	
		
		
		MOV AX, statusLength
		MOV BX, statusOffset
		
		CALL DisplayStr
		
		POP BX
		POP AX
		POP DI
		POP SI
		POP BP
		
		
		RET
display_status   ENDP

; display_time
;
; Description:       This procedure displays time in the dedicated spot on the LCD
;
; Operation:        	
;			Uses DisplayStr
; Arguments:         
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.

; Input:            None.
; Output:            Displays time on LCD.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None
; Stack Depth:       8 words
;
; Last Modified:     5-2-2008
display_time   PROC    NEAR
			PUBLIC display_time
		PUSH BP
		MOV BP, SP
		PUSH SI
		PUSH DI
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		
		MOV CX, [BP+4]
		CMP CX, TIME_NONE
		JE timeNone
		
		MOV AX, tenthsOfSecPerMin
		XOR DX, DX
		DIV CX
		MOV CX, DX ;store remainder in CX
		
		;write AX using dec2string
		MOV BX, AX
		MOV AX, ten
		XOR DX, DX
		DIV BX
		ADD AX, ASCIIDecCons  ;convert to ASCII
		ADD DX, ASCIIDecCons
		MOV BX, timeStringBufferMinutesOffset
		MOV timeStringBuffer[BX], AL
		INC BX
		;write colon
		MOV timeStringBuffer[BX], ASCIIcolon
		
		
		MOV AX, tenthsOfSecPerSec
		XOR DX, DX
		DIV CX ;remainder should be in CX
		
		;write ax using dec2string
		MOV BX, AX
		MOV AX, ten
		XOR DX, DX
		DIV BX
		ADD AX, ASCIIDecCons  ;convert to ASCII
		ADD DX, ASCIIDecCons
		MOV BX, timeStringBufferSecondsOffset
		MOV timeStringBuffer[BX], AL
		INC BX		
		;write point
		MOV timeStringBuffer[BX], ASCIIperiod
		INC BX
		
		;write dx using dec2string
		MOV timeStringBuffer[BX], DL
		
		;now call DisplayStr
		MOV AX, timeLength
		MOV BX, timeOffset
		PUSH SEG(timeStringBuffer)
		POP ES
		MOV SI, OFFSET(timeStringBuffer)
		JMP callGenericDisplay
timeNone:		
		MOV BX, 0
		MOV timeStringBuffer[BX], null
callGenericDisplay:		
		CALL DisplayStr
		
		POP DX
		POP CX
		POP BX
		POP AX
		POP DI
		POP SI
		POP BP
		RET
display_time   ENDP

; DisplayStr
;
; Description:       This procedure is a generic display function. 
;
; Operation:        Displays string stored at ES:[SI] for specified length,
; 				offset		
;
; Arguments:         string located at ES:[SI], length in AL, offset in BL
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.

; Input:            None.
; Output:            Displays string on LCD.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None
; Stack Depth:       5 words
;
; Last Modified:     5-2-2008
DisplayStr   PROC    NEAR
			PUBLIC DisplayStr
		PUSH SI
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		
		MOV CL, BL			;offset in CL
		MOV BL, AL			;length in BL
		
		MOV DX, displayAddressCMD	;return cursor home
		MOV AL, returnHome
		OUT DX, AL
		CALL readBusyFlag
		
		CMP BL, position0					;shift cursor to desired offset
		JE offsetDone
		MOV CL, BL
		XOR CH, CH
		MOV AL, cursorRight
getToOffset:
		OUT DX, AL
		CALL readBusyFlag
		LOOP getToOffset

offsetDone:							;cursor is now at desired offset
		MOV CL, BL					;length in CL
		MOV DX, displayAddressDAT
		
displayLoop:						;print a character, decrement length count
		MOV AL, ES:[SI]
		OUT DX, AL
		CALL readBusyFlag
		CMP AL, STRINGNULL
		JE doneIncrementingSI		;don't increment SI if at string null (pads blanks)
		INC SI
doneIncrementingSI:		
		LOOP displayLoop
		
		POP DX
		POP CX
		POP BX
		POP AX
		POP SI
		RET
DisplayStr   ENDP


readBusyFlag   PROC    NEAR
			PUBLIC readBusyFlag
		
		PUSH AX
		PUSH DX
		
checkBusy:		
		MOV DX, displayAddressCMD
		IN AL, DX
		AND AL, busyFlagMask
		CMP AL, LCDbusy
		JE checkBusy
		
		POP DX
		POP AX
		
		RET
readBusyFlag   ENDP
CODE ENDS

;array of status strings
statuses  LABEL BYTE
		PUBLIC statuses
		DB 'PLAY l>',0
		DB 'FFWD >>',0
		DB 'RWD  <<',0
		DB 'IDLE ..',0
		DB 'ILLEGAL',0



;the data segment

DATA    SEGMENT PUBLIC  'DATA'
timeStringBuffer DB timeLength DUP(?)
DATA    ENDS




        END     