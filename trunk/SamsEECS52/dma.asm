       NAME  dma

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    DMA                                 ;
;                           DMA Functions                            ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program contains the functions to
; 			DMA
;
; Input:            data from IDE harddrive
; Output:           data to DRAM
; User Interface:   call functions:
;				get_blocks(start, num, dest)
;				
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Revision History:
;     5/30/08  Samuel Yang     file started
CGROUP GROUP CODE
DGROUP GROUP DATA

; local include files
$INCLUDE(dma.INC)
$INCLUDE(boolean.INC)


CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS:CGROUP, DS:DGROUP





; InitDMA
;
; Description:       This procedure initializes everything for DMA
;
; Operation:        Sends initialization bytes to DMA
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.

; Input:            None.
; Output:            Initializes DMA.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None
; Stack Depth:       2 words
;
; Last Modified:     5-30-2008
InitDMA   PROC    NEAR
			PUBLIC InitDMA
			PUSH AX
			PUSH DX
			
			MOV DX, DMAAddressCMD
			MOV AL, functionSet
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, clearScreen
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, entryModeSet
			OUT DX, AL
			CALL readBusyFlag
			MOV AL, DMAOnOffCtrl
			OUT DX, AL
			CALL readBusyFlag
			
			POP DX
			POP AX
			RET
InitDMA   ENDP


; get_blocks
;
; Description:       This procedure DMAs title in the dedicated spot on the DMA
;
; Operation:        Uses DMAStr
; Arguments:         segment and offset of string on stack, stored in ES, SI
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.

; Input:            None.
; Output:            DMAs title on DMA.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None
; Stack Depth:       7 words
;
; Last Modified:     5-30-2008
get_blocks   PROC    NEAR
			PUBLIC get_blocks
		
		PUSH BP
		MOV BP, SP
		PUSH SI
		PUSH DI
		PUSH AX
		PUSH BX
		
		;get arguments off the stack
		MOV AX, [BP+4]		;offset of destination adddress
		MOV BX, [BP+6]		;segment of destination adddress
		MOV CX, [BP+8]		;number of blocks to be received
		MOV numBlocks, CX
		MOV CX, [BP+10]		;low word of start of blocks
		MOV startOfBlocksLow, CX
		MOV CX, [BP+12]		;high nibble of start of blocks
		MOV startOfBlocksHigh, CX
		
		;convert segment, offset into 20 bit address
		MOV CX, BX  ;save highest nibble of segment   
		SHR CX, 12  
		SHL BX, 4	;prepare to add offset to lower part of segment
		ADD BX, AX	;lower 16 bits of 20-bit address now in BX
		ADC CX, 0	;higher 4 bits of 20-bit address now in CX
		
		;set DMA dest 20-bit address
		MOV DX, D0DSTHaddr
		MOV AX, CX
		OUT DX, AX
		MOV DX, D0DSTLaddr
		MOV AX, BX
		OUT DX, AX
		
		;set DMA source 20-bit address (fixed IDE address)
		MOV DX, D0SRCHaddr
		MOV AX, D0SRCHvalue
		OUT DX, AX
		MOV DX, D0SRCLaddr
		MOV AX, D0SRCLvalue
		OUT DX, AX
		
		;set DMA terminal counter
		MOV DX, D0TCaddr
		MOV AX, D0TCvalue
		OUT DX, AX
		
		
		;INIT IDE HERE
		
		;start DMA tranfer
		MOV DX, D0CONaddr
		MOV AX, D0CONvalue
		OUT DX, AX
		
		POP BX
		POP AX
		POP DI
		POP SI
		POP BP
		
		
		RET
get_blocks   ENDP

CODE ENDS


DATA    SEGMENT PUBLIC  'DATA'
numBlocks DW ?
startOfBlocksHigh DW ?
startOfBlocksLow DW ?
DATA    ENDS




        END     
