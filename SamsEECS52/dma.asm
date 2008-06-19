       NAME  dma

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    DMA                                     ;
;                              DMA Functions                   			     ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program contains the functions to interface the IDE
; 				harddrive with the mp3 player by using the 80188's built in 
;				DMA to transfer data to DRAM.
; Input:            data read IDE harddrive
; Output:           data written to DRAM
; User Interface:   call functions:
;				InitDMA()
;				get_blocks(startAddr, numBlocks, destAddr)
;				
; Error Handling:   None.
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
; Description:       This procedure initializes everything required for DMA transfer of
;				data from the IDE to DRAM.
;
; Operation:         Initializes variables
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   numBlocks, startOfBlocksHigh, startOfBlocksLow
; Shared Variables:  None.

; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None.
; Stack Depth:       0
;
; Last Modified:     6-6-2008
InitDMA PROC NEAR
	PUBLIC InitDMA
		MOV numBlocks, 0
		MOV startOfBlocksHigh, 0
		MOV startOfBlocksLow, 0
	RET
InitDMA ENDP

; get_blocks
;
; Description:       This procedure gets data from the IDE and moves it into DRAM.
;
; Operation:         The 80188's built in DMA transfer is used to transfer one block at
;				a time.  First, IDE registers are set up and the data read into the IDE buffer;
;				then the DMA transfer is initiated, repeating until all blocks have been read.
; Arguments:         start address of blocks (2 words)
;					 number of blocks (1 word)
;'					 destination address (2 words)
; Return Value:      number of blocks read in AX
;
; Local Variables:   numBlocks, startOfBlocksHigh, startOfBlocksLow
; Shared Variables:  None.

; Input:             Data read from IDE
; Output:            Data written to DRAM
;
; Error Handling:    blocks until IDE isn't busy and data is ready
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: AX
; Stack Depth:       10 words
;
; Last Modified:     5-31-2008
get_blocks   PROC    NEAR
			PUBLIC get_blocks
		
		PUSH BP
		MOV BP, SP
		PUSH SI
		PUSH DI
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH ES
		
		;get arguments off the stack
		MOV AX, [BP+10]		;offset of destination address
		MOV BX, [BP+12]		;segment of destination address
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
				
		
		;write LBA to IDE registers
		PUSH IDEsegment		;use ES to reference IDE segment
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
    	MOV ES:[SI], AX 		;LBA 7:0, don't care about contents in AH, but word write is required
		
		MOV SI, IDEaddrCylinderlow
		MOV AL, AH
		CALL checkIDEBusy
    	MOV ES:[SI], AX 		;LBA 15:8
		
		MOV SI, IDEaddrCylinderhigh
		MOV AX, startOfBlocksHigh
		CALL checkIDEBusy
        MOV ES:[SI], AX			;LBA 23:16
		
		MOV SI, IDEaddrDevicehead
		MOV AL, DeviceheadValue	;get control values
		AND AH, 0FH				;mask off upper nibble
		OR AL, AH				;set LBA 27:24 bits
		CALL checkIDEBusy
    	MOV ES:[SI], AX 		;LBA 27:24
		
		;set IDE sector count
		MOV SI, IDEaddrSectorcount	
		MOV AX, numBlocks
		CALL checkIDEBusy
        MOV ES:[SI], AX 	;writes byte only although value is a word

readSectors:		
		;command IDE to read sectors
		MOV SI, IDEaddrCommand
		MOV AL, IDECommandReadSectors
		CALL checkIDEBusy
        MOV ES:[SI], AX 
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
		POP DI
		POP SI
		POP BP
		
		RET
get_blocks   ENDP

; checkIDEBusy
;
; Description:       This procedure checks if the IDE is busy
;
; Operation:         Blocks until busy flag is clear and device ready is set
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.

; Input:             IDE busy, device ready flag
; Output:            None.
;
; Error Handling:    Blocking function
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None
; Stack Depth:       5 words
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
; Description:       This procedure checks if IDE device ready flag is set
;
; Operation:         Blocks until device is ready
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.

; Input:            IDE device ready flag
; Output:            None.
;
; Error Handling:    Blocking function
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: None
; Stack Depth:       5 words
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
numBlocks 			DW 	?			;stores number of blocks to read from IDE
startOfBlocksHigh 	DW 	?			;stores IDE LBA high word
startOfBlocksLow 	DW 	?			;stores IDE LBA low word
DATA    ENDS




        END     
