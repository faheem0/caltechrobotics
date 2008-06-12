;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  dma.INC                               	 ;
;                              DMA constants	                             ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the definitions for the DMA functions(dma.ASM).
; 
;
; Revision History:

;     5/30/2008 Samuel Yang     
IDEoffset	  EQU 	  0000H			 ;for samsung IDE


IDE_BLOCK_SIZE EQU 256               ;words, must NOT change




										;Register addresses, masks, and values
D0DSTHaddr	  EQU 	  0ffc6H		 ;address of dest address pointer (high)
D0DSTLaddr	  EQU 	  0ffc4H		 ;address of dest address pointer (low)

D0SRCHaddr	  EQU 	  0ffc2H		 ;address of src address pointer (high)
D0SRCLaddr	  EQU 	  0ffc0H		 ;address of src address pointer (low)

D0SRCHvalue	  EQU 	  0008H			 ;fixed address of IDE data
D0SRCLvalue	  EQU	  0000H			 ;fixed address of IDE data

D0CONaddr	  EQU 	  0ffcaH		 ;address of DMA0 control register

D0TCaddr	  EQU 	  0ffc8H		 ;address of DMA0 terminal count register

D0SRCHmask    EQU     000fH          ;DMA0 Source Address Pointer (high)
										;mask off reserved bits
                                        ;000000000000----  reserved
                                        ;------------1111  address bits 19:16
D0SRCLmask    EQU     0ffffH         ;DMA0 Source Address Pointer (high)
										;mask off reserved bits
                                        ;1111111111111111  address bits 15:0                                      
D0DSTHmask    EQU     000fH          ;DMA0 Destination Address Pointer (high)
										;mask off reserved bits
                                        ;000000000000----  reserved
                                        ;------------1111  address bits 19:16
D0DSTLmask    EQU     0ffffH         ;DMA0 Destination Address Pointer (high)
										;mask off reserved bits
                                        ;1111111111111111  address bits 15:0                                      

D0CONvalue    EQU     0b606H         ;DMA0 Control Register-p270
										;1---------------  dest. memory space   
										;-01-------------  dest increment
										;---1------------  source memory space
										;----01----------  src increment
										;------1---------  terminate on TC
										;-------0--------  clear interrupt
										;--------00------  unsynchronized
										;----------0-----  set low priority
										;-----------0----  internal DMA disable
										;------------0---  reserved
										;-------------1--  enable modifying STRT
										;--------------1-  start DMA channel
										;---------------0  byte transfer
										
D0TCvalue     EQU	IDE_BLOCK_SIZE*2  ;convert # words to # bytes										
										
;IDE addresses-p28		
IDEsegment			 EQU 	 8000H		   ;IDE on MCS0
								
IDEaddrFeatures  	 EQU     2000H         ;address of features register
IDEaddrSectorcount   EQU     4000H         ;address of Sector Count register
IDEaddrSectornumber  EQU     6000H         ;address of Sector Number register
IDEaddrCylinderlow   EQU     8000H         ;address of Cylinder Low register
IDEaddrCylinderhigh  EQU    0A000H         ;address of Cylinder High register
IDEaddrDevicehead    EQU    0C000H         ;address of Device/Head register
IDEaddrCommand   	 EQU    0E000H         ;address of Command register
IDEaddrStatus   	 EQU    0E000H         ;address of Status register										
										
										
DeviceheadValue	    EQU       0e0H    ;set IDEaddrDevicehead to LBA mode
										;1-1-----  reserved
										;-1------  LBS addressing mode
										;---0----  device 0?
										;----0000  LBA bits 27:24
CylinderHighValue   EQU        00H    ;set LBA bits
										;00000000  LBA bits 23:16
CylinderLowValue    EQU        00H    ;set LBA bits
										;00000000  LBA bits 15:8
SectorNumberValue   EQU        00H    ;set LBA bits
										;00000000  LBA bits 7:0	

IDECommandReadSectors  EQU     21H    ;read sectors without retries

IDEBusyFlagMask		EQU 	  080H	   ;from status register		
										;1-------  BSY-busy	
IDEBusyState		EQU 	  080H	   ;from status register		
										;1-------  BSY-busy										
IDEDrdyFlagMask		EQU 	  0C0H	   ;from status register		
										;1-------  BSY-busy	
										;-1------  DRDY-device ready										
IDEDrdyState		EQU		  040H	   ;from status register		
										;0-------  BSY-busy cleared	
										;-1------  DRDY-device ready							