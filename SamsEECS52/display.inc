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


displayAddressCMD   EQU     00100H           ;display address for commands
displayAddressDAT   EQU     00101H           ;display address for data

;LCD commands-send to displayAddressCMD
functionSet          EQU 3CH					;8 bit, 2 line, 5x7 dots
clearScreen			EQU 01H						;clears screen
entryModeSet 		EQU 06H						;shift cursor right
displayOnOffCtrl 	EQU 0CH						;display on, cursor off

cursorLeft			EQU 10H						;shifts cursor left one
cursorRight			EQU 14H						;shifts cursor right one
returnHome			EQU 02H						;

;display format constants
statusOffset EQU 0
statusLength EQU 4
timeOffset EQU 5
timeLength EQU 8
titleOffset EQU 14
titleLength EQU 26
artistOffset EQU 40
artistLength EQU 40






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