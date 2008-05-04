        NAME    CONVERTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                   CONVERTS                                 ;
;                             Conversion Functions                           ;
;                                   EE/CS 51                                 ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; file description including table of contents
;
; Revision History:
;     1/26/06  Glen George      initial revision
;     1/29/08 Samuel Yang       started programming
;     1/30/08 Samuel Yang       written, compiles, untested
;     1/31/08 Samuel Yang	      works
;     2/17/08 Samuel Yang       PUSH/POP added so registers unchanged

; Known bugs: None


CGROUP  GROUP   CODE


CODE	SEGMENT PUBLIC 'CODE'


        ASSUME  CS:CGROUP




; Dec2String
;
; Description: Receives a 16-bit signed value to be converted to decimal and stored as a 
;			string (pads 0's for 5 digits, and '-' sign, if negative)
; Operation:
;
; Arguments: AX, a 16-bit unsigned number
; Return Value: writes a string containing dec representation of AX in ASCII starting at DS:SI
; Local Variables: None
; Shared Variables: None
; Global Variables: None
;
; Input: AX
; Output: memory written
;
; Error Handling: if AX=0, returns NULL string
;
; Algorithms: None
; Data Structures: None
;
; Registers Changed: AX, BX, CX, DX, SI, DI
; Stack Depth: None
;
; Author: Samuel Yang
; Last Modified: 2-17-2008


Dec2String      PROC        NEAR
                PUBLIC      Dec2String
                PUSH AX
				PUSH BX
				PUSH CX
				PUSH DX
				PUSH SI
				PUSH DI
;--------------------------------------------------------------------------------------------
               ; JMP allTestsGood
                MOV DI, SI                    ;saves SI in DI
                              
              ;addSign                
                CMP AX, 0                     ;IF AX >=0 THEN no need to add sign
                JGE padZero
                                              ;ELSE, add '-' and convert AX to unsigned
                MOV DX, 45                             
                MOV DS:[SI], DL                  ;ASCII value for '-'
                INC SI
               
                            
                NEG AX                        ;AX is now UNSIGNED    
                JMP signDone
                
padZero:                            
                MOV DX, 48               
                ;MOV DS:[SI], DL                  ;ASCII value for '0'
                ;INC SI
signDone:               
                MOV CX, 5
                
forLoop1:         ;loops 5 times, pads 0's
                
                
                
                MOV BX, 10
				XOR DX, DX                     ;AX=AX/10
                DIV BX                        ;AX=quotient, DX= remainder
                      
                ADD DX, 48                  ;convert DX to ASCII digit
                
                MOV BX, CX   ;write to [SI+CX-1]
                ADD BX, SI
                DEC BX
                MOV DS:[BX], DL                  ;WRITE VALUE HERE             
                
                
                LOOP forLoop1     ;LOOP        
                

          
 
                MOV DX, 0
                MOV DS:[SI+5], DL                  ;terminate string with null
                
               
                MOV SI, DI                    ;put SI value back in
;--------------------------------------------------------------------------------------------

	
	POP DI
	POP SI
	POP DX
	POP CX
	POP BX
	POP AX

	RET
Dec2String	ENDP




; Hex2String
;
; Description: Receives a 16-bit unsigned value to be converted to hex 
;			and stored as a string (no 0 padding)
; Operation:
;
; Arguments: AX, a 16-bit unsigned number
; Return Value: writes a string starting at DS:SI
;
; Local Variables: None.
; Shared Variables: None.
; Global Variables: None.
;
; Input: AX
; Output: memory written
;
; Error Handling: If AX = 0, returns null string
;
; Algorithms: None
; Data Structures: None
;
; Registers Changed: AX, BX, CX, DX, SI, DI
; Stack Depth: None
;
; Author: Samuel Yang
; Last Modified: 2-17-2008


Hex2String      PROC        NEAR
                PUBLIC      Hex2String
		
;-------------------------------------------------------------------------------------------- 
                 ;SI is never modified
                
				PUSH AX
				PUSH BX
				PUSH CX
				PUSH DX
				PUSH SI
				PUSH DI
 
                MOV CX, 4
forLoop2:                
                
                
                MOV DX, AX                    ;DX=(AX & 000F)
                AND DX, 0Fh
                SHR AX, 4      
                                        ;convertToASCII
                CMP DX, 9
                JLE ASCIInum            ;if DX is a number    
                
                ADD DX, 55              ;DX is a letter
                JMP writeDigit                
 
ASCIInum:
                ADD DX, 48
writeDigit:       
                MOV BX, SI            ;write to [SI+CX-1]
                ADD BX, CX
                DEC BX 
                MOV DS:[BX], DL             ;WRITE VALUE HERE               
                
                               
               
                LOOP forLoop2   ;LOOP          
                                
              
                
 
                MOV DX, 0
                MOV DS:[SI+4], DL                 ;terminate string with null
                
                ;MOV SI, DI                    ;put back original SI value
				POP DI
				POP SI
				POP DX
				POP CX
				POP BX
				POP AX
	RET
;--------------------------------------------------------------------------------------------
Hex2String	ENDP



CODE    ENDS



        END
