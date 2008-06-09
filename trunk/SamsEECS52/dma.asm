       NAME  dma

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    DMA                                     ;
;                              DMA Functions                   			     ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program contains the functions to for DMA between
; 						the IDE and DRAM
;
; Input:            data from IDE harddrive
; Output:           data to DRAMi
; User Interface:   call functions:
;				get_blocks(startAddr, numBlocks, destAddr)
;				
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Revision History:
;     5/30/08  Samuel Yang     file started
;	  6/6/08   Samuel Yang		fixing stuff and comments updated, untested
CGROUP GROUP CODE
DGROUP GROUP DATA

; local include files
$INCLUDE(dma.INC)
$INCLUDE(boolean.INC)


CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS:CGROUP, DS:DGROUP





; InitDMA
;
; Description:       This procedure initializes everything for DMA between IDE and DRAM
;
; Operation:        
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
			
			;do nothing right now
			
			POP DX
			POP AX
			RET
InitDMA   ENDP


; get_blocks
;
; Description:       This procedure gets data from the IDE into the DRAM
;
; Operation:        Uses the 80188's built in DMA transfer.  Sets up IDE registers and
;				DMA transfer, and blocks until transfer is complete.
; Arguments:         start address of blocks (2 words) number of blocks (1 word), destination address (2 words)
; Return Value:      None.
;
; Local Variables:   numBlocks, startOfBlocksHigh, startOfBlocksLow
; Shared Variables:  None.

; Input:            Data from IDE
; Output:            Data to DRAM
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None
; Stack Depth:       10 words
;
; Last Modified:     5-31-2008
get_blocks   PROC    NEAR
			PUBLIC get_blocks
		
		PUSH BP
		MOV BP, SP
		PUSH SI
		PUSH DI
	;	PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH ES
		
		;get arguments off the stack
		MOV AX, [BP+10]		;offset of destination address
		MOV debug, AX
		MOV BX, [BP+12]		;segment of destination address
		MOV debug1, BX
		MOV CX, [BP+8]		;number of blocks to be received
		MOV numBlocks, CX
		PUSH numBlocks
		MOV CX, [BP+4]		;low word of start of blocks
		MOV startOfBlocksLow, CX
		MOV CX, [BP+6]		;high nibble of start of blocks
		MOV startOfBlocksHigh, CX
setDMAregs:	
				
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
				
		;INIT IDE HERE
		;write LBA to IDE registers
		PUSH IDEsegment	;use ES to reference IDE segment
		POP ES
		
		;add IDE address offset
setIDEregs:
		MOV BX, startOfBlocksLow
		MOV CX, startOfBlocksHigh
		ADD BX, IDEoffset		
		ADC CX, 0
		MOV startOfBlocksLow, BX
		MOV startOfBlocksHigh, CX
		
		MOV SI, IDEaddrSectornumber
		MOV AX, startOfBlocksLow	
		CALL checkIDEBusy
flag1:	MOV ES:[SI], AX ;LBA 7:0, don't care about contents in AH, but word write is required
		
		MOV SI, IDEaddrCylinderlow
		MOV AL, AH
		CALL checkIDEBusy
flag2:	MOV ES:[SI], AX ;LBA 15:8
		
		MOV SI, IDEaddrCylinderhigh
		MOV AX, startOfBlocksHigh
		CALL checkIDEBusy
flag3:	MOV ES:[SI], AX	;LBA 23:16
		
		MOV SI, IDEaddrDevicehead
		MOV AL, DeviceheadValue	;get control values
		AND AH, 0FH			;mask off upper nibble
		OR AL, AH				;set LBA 27:24 bits
		CALL checkIDEBusy
flag4:	MOV ES:[SI], AX 	;LBA 27:24
		
		;set IDE sector count
		MOV SI, IDEaddrSectorcount	
		MOV AX, numBlocks
		CALL checkIDEBusy
flag5:	MOV ES:[SI], AX 	;writes byte only although value is a word

readSectors:		
		;command IDE to read sectors
		MOV SI, IDEaddrCommand
		MOV AL, IDECommandReadSectors
		CALL checkIDEBusy
flag6:	MOV ES:[SI], AX 
transferDMA: ;LOOP starts here
		;reset DMA source 20-bit address (fixed IDE address)
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
		
		;wait for data ready
		CALL checkIDEDrdy

startDMAtransfer:		
		;start DMA tranfer
		MOV DX, D0CONaddr
		MOV AX, D0CONvalue
		OUT DX, AX
		
		;do polling
checkFinishedDMA:
		MOV DX, D0TCaddr		;check if terminal count has reached 0
		IN AX, DX
		CMP AX, 0
		JNE checkFinishedDMA
		
		MOV AX, numBlocks
		DEC AL
		XOR AH, AH				;ignore upper byte of numBlocks
		MOV numBlocks, AX
		
		CMP AX, 0
		JNE transferDMA
endGetBlocks:		

		POP AX
		POP ES
		POP DX
		POP CX
		POP BX
	;	POP AX
		POP DI
		POP SI
		POP BP
		
		
		RET
get_blocks   ENDP

; checkIDEBusy
;
; Description:       This procedure checks if IDE busy flag is set
;
; Operation:        Blocks until busy flag is clear
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.

; Input:            IDE busy flag
; Output:            None.
;
; Error Handling:    Blocking function
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None
; Stack Depth:       2 words
;
; Last Modified:     5-30-2008
checkIDEBusy   PROC    NEAR
			PUBLIC checkIDEBusy
			PUSH AX
			PUSH DX
			PUSH ES
			PUSH SI
checkBusy:			
			PUSH IDEsegment
			POP ES
			MOV SI, IDEaddrStatus	;read busy, device ready flag
			MOV AX, ES:[SI]
			AND AL, IDEBusyFlagMask
			
			CMP AL, IDEBusyState	;if busy, then keep checking
			JE checkBusy
			
			POP SI
			POP ES
			POP DX
			POP AX
			RET
checkIDEBusy   ENDP

; checkIDEDrdy
;
; Description:       This procedure checks if IDE data ready flag is set
;
; Operation:        Blocks until data is ready
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.

; Input:            IDE data ready flag
; Output:            None.
;
; Error Handling:    Blocking function
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None
; Stack Depth:       2 words
;
; Last Modified:     5-30-2008
checkIDEDrdy PROC    NEAR
			PUBLIC checkIDEDrdy
			PUSH AX
			PUSH DX
			PUSH ES
			PUSH SI

checkDataReady:			
			PUSH IDEsegment
			POP ES
			MOV SI, IDEaddrStatus	;read device ready flag
			MOV AX, ES:[SI]
			AND AL, IDEDrdyFlagMask
			
			CMP AL, IDEDrdyState	;if device not ready, then keep checking
			JNE checkDataReady
			
			POP SI
			POP ES
			POP DX
			POP AX
			RET
checkIDEDrdy   ENDP

CODE ENDS


DATA    SEGMENT PUBLIC  'DATA'
numBlocks DW ?
startOfBlocksHigh DW ?
startOfBlocksLow DW ?
debug DW ?
debug1 DW ?
DATA    ENDS




        END     
