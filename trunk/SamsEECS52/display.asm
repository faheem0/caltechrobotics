       NAME  display

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    Display                           	     ;
;                           Display Functions                        		 ;
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
;     5/2/08  Samuel Yang     file started
;     5/3/08  Samuel Yang	functions tested, working, comments updated
;	  6/11/2008 Samuel Yang special characters added
CGROUP GROUP CODE
DGROUP GROUP DATA

; local include files
$INCLUDE(display.INC)
$INCLUDE(boolean.INC)


CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS:CGROUP, DS:DGROUP





; InitDisplay
;
; Description:       This procedure initializes everything for display
;
; Operation:        Sends initialization bytes to LCD
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.

; Input:            None.
; Output:            Initializes LCD.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None
; Stack Depth:       2 words
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
			
			;init special characters here
			MOV DX, displayAddressCMD
			MOV AL, LCDSpecialPlay
			OUT DX, AL
			CALL readBusyFlag
			MOV DX, displayAddressDAT
			MOV AL, LCDSpecialPlayLine0
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialPlayLine1
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialPlayLine2
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialPlayLine3
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialPlayLine4
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialPlayLine5
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialPlayLine6
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialPlayLine7
			OUT DX, AL
			CALL readBusyFlag
			
			MOV DX, displayAddressCMD
			MOV AL, LCDSpecialStop
			OUT DX, AL
			CALL readBusyFlag
			MOV DX, displayAddressDAT
			MOV AL, LCDSpecialStopLine0
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialStopLine1
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialStopLine2
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialStopLine3
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialStopLine4
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialStopLine5
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialStopLine6
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialStopLine7
			OUT DX, AL
			CALL readBusyFlag
			
			MOV DX, displayAddressCMD
			MOV AL, LCDSpecialFFW
			OUT DX, AL
			CALL readBusyFlag
			MOV DX, displayAddressDAT
			MOV AL, LCDSpecialFFWLine0
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialFFWLine1
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialFFWLine2
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialFFWLine3
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialFFWLine4
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialFFWLine5
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialFFWLine6
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialFFWLine7
			OUT DX, AL
			CALL readBusyFlag
			
			MOV DX, displayAddressCMD
			MOV AL, LCDSpecialRWD
			OUT DX, AL
			CALL readBusyFlag
			MOV DX, displayAddressDAT
			MOV AL, LCDSpecialRWDLine0
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialRWDLine1
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialRWDLine2
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialRWDLine3
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialRWDLine4
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialRWDLine5
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialRWDLine6
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialRWDLine7
			OUT DX, AL
			CALL readBusyFlag
			
			MOV DX, displayAddressCMD
			MOV AL, LCDSpecialPause
			OUT DX, AL
			CALL readBusyFlag
			MOV DX, displayAddressDAT
			MOV AL, LCDSpecialPauseLine0
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialPauseLine1
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialPauseLine2
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialPauseLine3
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialPauseLine4
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialPauseLine5
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialPauseLine6
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, LCDSpecialPauseLine7
			OUT DX, AL
			CALL readBusyFlag
			;end init special characters
			
			
			POP DX
			POP AX
			RET
InitDisplay   ENDP


; display_title
;
; Description:       This procedure displays title in the dedicated spot on the LCD
;
; Operation:        Uses DisplayStr
; Arguments:         segment and offset of string on stack, stored in ES, SI
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
		MOV SI, [BP+4]
		MOV ES, [BP+6]
		
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

; display_artist
;
; Description:       This procedure displays artist in the dedicated spot on the LCD
;
; Operation:        Uses DisplayStr
; Arguments:          segment and offset of string on stack, stored in ES, SI
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.

; Input:            None.
; Output:            Displays artist on LCD.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None
; Stack Depth:       7 words
;
; Last Modified:     5-3-2008
display_artist   PROC    NEAR
			PUBLIC display_artist
		
		PUSH BP
		MOV BP, SP
		PUSH SI
		PUSH DI
		PUSH AX
		PUSH BX
		MOV SI, [BP+4]
		MOV ES, [BP+6]
		
		MOV AX, artistLength
		MOV BX, artistOffset
		
		CALL DisplayStr
		
		POP BX
		POP AX
		POP DI
		POP SI
		POP BP
		
		
		RET
display_artist   ENDP

; display_status
;
; Description:       This procedure displays status in the dedicated spot on the LCD
;
; Operation:       Looks up predefined status strings from "statuses" table 	
;			Uses DisplayStr to display the looked up status string.
; Arguments:   Status code (byte) from stack, stored in CX   
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
		PUSH CX
		MOV CX, [BP+4]
	
		;offset = statusStringLength*status
		MOV AL, statusStringLength  ;calculate the offset of the desired predefined status message
		MUL CL
		
		PUSH SEG(statuses)	;Use ES:[SI] to point to the predefined status message
		POP ES
		MOV BX, OFFSET(statuses)
		ADD BX, AX
		MOV SI, BX	
		
		
		MOV AX, statusLength
		MOV BX, statusOffset
		
		CALL DisplayStr
		
		POP CX
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
; Operation:     Divides time into minutes, seconds, and tenths of seconds, writing each
;			to a temporary buffer, which is passed to DisplayStr.
; Arguments:         time in tenths of seconds on the stack, stored in CX
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
; Data Structures:   Uses timeStringBuffer[] to temporarily store time string
;
; Registers Changed: None
; Stack Depth:       8 words
;
; Last Modified:     5-3-2008
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
		
		MOV CX, [BP+4] ;retreive time given in tenths of seconds
		CMP CX, TIME_NONE
		JE timeNone
	
		;time/tenthsOfSecPerMin = minutes R(tenthsOfSeconds)
		MOV AX, CX
		MOV CX, tenthsOfSecPerMin
		XOR DX, DX
		DIV CX
		MOV CX, DX ;store remainder in CX
		;minutes in AX, remainder (in tenths of seconds) in CX
		
		;write minutes (in AX)
		;minutes/10= tensOfMinutes R(minutes)
		MOV BX, ten
		XOR DX, DX
		DIV BX
		ADD AX, ASCIIDecCons  ;convert to ASCII
		ADD DX, ASCIIDecCons
		MOV BX, timeStringBufferMinutesOffset ;get index of minutes
		MOV timeStringBuffer[BX], AL		;write minutes to buffer to be printed
		INC BX
		MOV timeStringBuffer[BX], DL
		INC BX
		;write colon
		MOV timeStringBuffer[BX], ASCIIcolon
		
		;previous remainder(in tenths of seconds) should be in CX
		MOV AX, CX
		MOV CX, tenthsOfSecPerSec
		XOR DX, DX
		DIV CX 
		MOV CX, DX ;store new remainder in CX
		;seconds in AX, tenths of seconds in CX
		
		;write seconds
		MOV BX, ten
		XOR DX, DX
		DIV BX
		ADD AX, ASCIIDecCons  ;convert to ASCII
		ADD DX, ASCIIDecCons
		MOV BX, timeStringBufferSecondsOffset ;get index of seconds
		MOV timeStringBuffer[BX], AL
		INC BX		
		MOV timeStringBuffer[BX], DL
		INC BX	
		;write period
		MOV timeStringBuffer[BX], ASCIIperiod
		INC BX
		
		;write tenths of seconds
		ADD CX, ASCIIDecCons
		MOV timeStringBuffer[BX], CL
		;write null at end
		INC BX
		MOV timeStringBuffer[BX], null
		
		;now call DisplayStr, passing it hte buffer
		MOV AX, timeLength
		MOV BX, timeOffset
		PUSH SEG(timeStringBuffer)
		POP ES
		MOV SI, OFFSET(timeStringBuffer)
		JMP callGenericDisplay
timeNone:		
		MOV BX, 0				;if TIME_NONE, then print blank spaces
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
; Error Handling:    If string is shorter than length, will display blank spaces afterwards.
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
		
		MOV CL, BL			;store offset in CL
		MOV BL, AL			;store length in BL
		
		CALL readBusyFlag
		MOV DX, displayAddressCMD	;return cursor home
		MOV AL, returnHome
		OUT DX, AL
		CALL readBusyFlag
		
		CMP CL, position0					;shift cursor to desired offset
		JE offsetDone
		XOR CH, CH
		MOV AL, cursorRight
getToOffset:
		OUT DX, AL
		CALL readBusyFlag
		LOOP getToOffset

offsetDone:							;cursor is now at desired offset
		MOV CL, BL					;store length in CL
		XOR CH, CH
		MOV DX, displayAddressDAT
		
displayLoop:						;print a character, decrement length count
		MOV AL, ES:[SI]
		CMP AL, STRINGNULL
		JE stringIsNull
		;JNE string not null
		INC SI					
		JMP endDisplayLoop
stringIsNull:				;if string is null,  don't increment SI, so string will
		MOV AL, blankSpace		;continue reading null and blank spaces will be added
endDisplayLoop:		
		OUT DX,AL
		CALL readBusyFlag
		LOOP displayLoop
		
		POP DX
		POP CX
		POP BX
		POP AX
		POP SI
		RET
DisplayStr   ENDP

; readBusyFlag
;
; Description:       This procedure blocks until LCD is no longer busy.
;
; Operation:       Keeps reading busy flag until LCD is not busy.		
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.

; Input:            From LCD busy flag
; Output:           None.
;
; Error Handling:    Blocking function.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None
; Stack Depth:       2 words
;
; Last Modified:     5-2-2008
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

contrast_up   PROC    NEAR
			PUBLIC contrast_up
		
		PUSH AX
		PUSH CX
		PUSH DX
		
		MOV CX, numContrastSteps
		MOV DX, digipotAddressUp
upContrastLoop:				
		OUT DX, AL					;doesn't matter what's outputted
		LOOP upContrastLoop
				
		POP DX
		POP CX
		POP AX
		
		RET
contrast_up   ENDP

contrast_down   PROC    NEAR
			PUBLIC contrast_down
		
		PUSH AX
		PUSH CX
		PUSH DX
		
		MOV CX, numContrastSteps
		MOV DX, digipotAddressDown
downContrastLoop:				
		OUT DX, AL					;doesn't matter what's outputted
		LOOP downContrastLoop
				
		POP DX
		POP CX
		POP AX
		
		RET
contrast_down   ENDP

;array of status strings (predefined constants)
statuses  LABEL BYTE
		
		DB '   ',1,'   ',0 ;play
		DB '   ',2,'   ',0 ;FFWD
		DB '   ',3,'   ',0 ;RWD
		DB '   ',4,'   ',0 ;IDLE/STOP
		DB '   ',5,'   ',0 ;PAUSE
		DB 'ILLEGAL',0
CODE ENDS


DATA    SEGMENT PUBLIC  'DATA'
timeStringBuffer DB timeLength DUP(?)
DATA    ENDS




        END     
