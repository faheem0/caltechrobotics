;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  display.INC                               ;
;                                  Display                                   ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the definitions for the Display program (display.ASM).
;
; Revision History:

;     5/2/2008 Samuel Yang  
;	  6/11/2008 Samuel Yang special characters added   
;	  6/11/2008 Samuel Yang digipot added

displayAddressCMD   EQU     00100H           ;display address for commands
displayAddressDAT   EQU     00101H           ;display address for data

digipotAddressUp	EQU 	00180H			 ;address of digipot, contrast up
digipotAddressDown	EQU 	00182H			 ;address of digipot, contrast down

numContrastSteps    EQU 20					 ;number of steps to increment contrast by

;LCD commands-send to displayAddressCMD
functionSet          EQU 3CH					;8 bit, 2 line, 5x7 dots
clearScreen			EQU 01H						;clears screen
entryModeSet 		EQU 06H						;shift cursor right
displayOnOffCtrl 	EQU 0CH						;display on, cursor off

cursorLeft			EQU 10H						;shifts cursor left one
cursorRight			EQU 14H						;shifts cursor right one
returnHome			EQU 02H						;return cursor home



;display format constants
statusOffset EQU 0
statusLength EQU 8
timeOffset EQU 9
timeLength EQU 8
titleOffset EQU 40
titleLength EQU 40
artistOffset EQU 18
artistLength EQU 22






;time conversion constants
tenthsOfSecPerMin EQU 600
tenthsOfSecPerSec EQU 10
ten EQU 10
ASCIIDecCons EQU 48
ASCIIcolon EQU 58
ASCIIperiod EQU 46
timeStringBufferMinutesOffset EQU 0
timeStringBufferSecondsOffset EQU 3
null EQU 0
TIME_NONE EQU 65535 ;IS THIS RIGHT????


;other constants
CHARSPERROW    EQU 40							;40 character display
position0 	   EQU 0							;0 position on display
STRINGNULL 		EQU 0
busyFlagMask	EQU 80h
LCDbusy 	EQU 80h
statusStringLength EQU 8
blankSpace EQU 32

;special character table
LCDSpecialPlay 	 EQU 01000000b+00001000b
LCDSpecialFFW  	 EQU 01001000b+00001000b
LCDSpecialRWD    EQU 01010000b+00001000b
LCDSpecialStop   EQU 01011000b+00001000b
LCDSpecialPause  EQU 01100000b+00001000b
LCDSpecialStop2 EQU 01101000b+00001000b
;LCDSpecialUnused1 EQU 01110000b+00001000b
;LCDSpecialUnused2 EQU 01111000b 

LCDSpecialPlayLine0 EQU 00010000b
LCDSpecialPlayLine1 EQU 00011000b
LCDSpecialPlayLine2 EQU 00010100b
LCDSpecialPlayLine3 EQU 00010010b
LCDSpecialPlayLine4 EQU 00010001b
LCDSpecialPlayLine5 EQU 00010010b
LCDSpecialPlayLine6 EQU 00010100b
LCDSpecialPlayLine7 EQU 00011000b

LCDSpecialStopLine0 EQU 00011111b
LCDSpecialStopLine1 EQU 00010000b
LCDSpecialStopLine2 EQU 00010000b
LCDSpecialStopLine3 EQU 00010000b
LCDSpecialStopLine4 EQU 00010000b
LCDSpecialStopLine5 EQU 00010000b
LCDSpecialStopLine6 EQU 00010000b
LCDSpecialStopLine7 EQU 00011111b

LCDSpecialStop2Line0 EQU 00011111b
LCDSpecialStop2Line1 EQU 00000001b
LCDSpecialStop2Line2 EQU 00000001b
LCDSpecialStop2Line3 EQU 00000001b
LCDSpecialStop2Line4 EQU 00000001b
LCDSpecialStop2Line5 EQU 00000001b
LCDSpecialStop2Line6 EQU 00000001b
LCDSpecialStop2Line7 EQU 00011111b

LCDSpecialFFWLine0 EQU 00000000b
LCDSpecialFFWLine1 EQU 00000000b
LCDSpecialFFWLine2 EQU 00010100b
LCDSpecialFFWLine3 EQU 00001010b
LCDSpecialFFWLine4 EQU 00000101b
LCDSpecialFFWLine5 EQU 00001010b
LCDSpecialFFWLine6 EQU 00010100b
LCDSpecialFFWLine7 EQU 00000000b

LCDSpecialRWDLine0 EQU 00000000b
LCDSpecialRWDLine1 EQU 00000000b
LCDSpecialRWDLine2 EQU 00000101b
LCDSpecialRWDLine3 EQU 00001010b
LCDSpecialRWDLine4 EQU 00010100b
LCDSpecialRWDLine5 EQU 00001010b
LCDSpecialRWDLine6 EQU 00000101b
LCDSpecialRWDLine7 EQU 00000000b

LCDSpecialPauseLine0 EQU 00010001b
LCDSpecialPauseLine1 EQU 00010001b
LCDSpecialPauseLine2 EQU 00010001b
LCDSpecialPauseLine3 EQU 00010001b
LCDSpecialPauseLine4 EQU 00010001b
LCDSpecialPauseLine5 EQU 00010001b
LCDSpecialPauseLine6 EQU 00010001b
LCDSpecialPauseLine7 EQU 00010001b












