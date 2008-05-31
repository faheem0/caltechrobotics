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
;				get_blocks(startAddr, numBlocks, destAddr)
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
; Last Modified:     5-30-2008
get_blocks   PROC    NEAR
			PUBLIC get_blocks
		
		PUSH BP
		MOV BP, SP
		PUSH SI
		PUSH DI
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		
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
		;write LBA to IDE registers
		MOV AX, startOfBlocksLow	
		MOV DX, IDEaddrSectornumber
		CALL checkIDEBusy
		OUT DX, AL	;LBA 7:0
		
		MOV AL, AH
		MOV DX, IDEaddrCylinderlow
		CALL checkIDEBusy
		OUT DX, AL	;LBA 15:8
		
		MOV AX, startOfBlocksHigh	
		MOV DX, IDEaddrCylinderhigh
		CALL checkIDEBusy
		OUT DX, AL	;LBA 23:16
		
		MOV AL, DeviceheadValue	;get control values
		AND AH, 0FH			;mask off upper nibble
		ADD AL, AH				;set LBA 27:24 bits
		MOV DX, IDEaddrDevicehead
		CALL checkIDEBusy
		OUT DX, AL	;LBA 27:24
		
		;set IDE sector count
		MOV AX, numBlocks
		MOV DX, IDEaddrSectorcount	;write word or byte ???????????????
		CALL checkIDEBusy
		OUT DX, AL
		
		;command IDE to read sectors
		MOV AL, IDECommandReadSectors
		MOV DX, IDEaddrCommand
		CALL checkIDEBusy
		OUT DX, AL
		
		;wait for data ready
		CALL checkDataReady
		
		;start DMA tranfer
		MOV DX, D0CONaddr
		MOV AX, D0CONvalue
		OUT DX, AX
		
		POP DX
		POP CX
		POP BX
		POP AX
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

checkBusy:			
			MOV DX, IDEaddrStatus	;read busy flag
			IN AL, DX
			AND AL, IDEBusyFlagMask
			
			CMP AL, IDEBusyFlagMask	;if busy, then keep checking
			JE checkBusy
			
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

checkDataReady:			
			MOV DX, IDEaddrStatus	;read busy flag
			IN AL,DX
			AND AL, IDEDrdyFlagMask
			
			CMP AL, IDEDrdyFlagMask	;if data not ready, then keep checking
			JNE checkDataReady
			
			POP DX
			POP AX
			RET
checkIDEDrdy   ENDP

CODE ENDS


DATA    SEGMENT PUBLIC  'DATA'
numBlocks DW ?
startOfBlocksHigh DW ?
startOfBlocksLow DW ?
DATA    ENDS




        END     
