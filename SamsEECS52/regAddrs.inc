;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  regAddrs.INC                              ;
;                              Register Addresses and Values                 ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the definitions for the 801C88 MP3 Player.
;
;
; Revision History:

;     5/2/2008 Samuel Yang  
;	  6/11/2008 Samuel Yang only 1 wait state on PACS   





; Interrupt Vectors
Int0Vec         EQU     12               ;interrupt vector for INT 0
Int1Vec         EQU     13               ;interrupt vector for INT 1


; Interrupt Controller Definitions

; Addresses
INT0Ctrlr        EQU    0FF38H           ;address of interrupt 0 controller
INT1Ctrlr        EQU    0FF3AH           ;address of interrupt 1 controller
INTCtrlrCtrl    EQU     0FF32H          ;address of interrupt controller for timer
INTCtrlrEOI     EQU     0FF22H          ;address of interrupt controller EOI register

; Register Values
INTCtrlrCVal    EQU     00001H          ;set priority for timers to 1 and enable
                                        ;000000000000----  reserved
                                        ;------------0---  enable timer interrupt
                                        ;-------------001  timer priority
INT0CtrlrVal    EQU		00011H			;set to level triggering, priority 2, enable
                                        ;000000000-------  reserved
                                        ;---------0------  disable fully nested mode
                                        ;----------0-----  disable cascade mode
										;-----------1----  level triggering
                                        ;------------0---  enable interrupt
                                        ;-------------010  int priority							
INT1CtrlrVal    EQU		00012H			;set to level triggering, priority 2, enable
                                        ;000000000-------  reserved
                                        ;---------0------  disable fully nested mode
                                        ;----------0-----  disable cascade mode
										;-----------1----  level triggering
                                        ;------------0---  enable interrupt
                                        ;-------------010  int priority									
INT1CtrlrValDisable EQU	0001AH			;set to level triggering, priority 2, disable
                                        ;000000000-------  reserved
                                        ;---------0------  disable fully nested mode
                                        ;----------0-----  disable cascade mode
										;-----------1----  level triggering
                                        ;------------1---  disable interrupt
                                        ;-------------010  int priority	
										
TimerEOI        EQU     00008H          ;Timer EOI command (samNone for all timers)
NonSpecEOI      EQU     08000H          ;Non-specific EOI command


; Chip Select Unit Definitions

; Addresses
PACSreg         EQU     0FFA4H          ;address of PACS register
MPCSreg         EQU     0FFA8H          ;address of MPCS register
MMCSaddr		EQU 	0ffa6H			;address of MCS control register

; Control Register Values
MMCSvalue	    EQU	    8001H			;set to the following:
                                        ;1000000---------  start at 80000H
                                        ;-------000000---  reserved
                                        ;---------------1  1 wait state min
PACSval         EQU     00001H          ;PCS base at 0, 3 wait states
                                        ;0000000000------  starts at address 0
                                        ;----------000---  reserved
                                        ;-------------0--  wait for RDY inputs
                                        ;--------------11  3 wait states
MPCSval         EQU     04000H          ;copy pasted
                                        ;0---------000---  reserved
                                        ;-1000000--------  MCS is 512KB
                                        ;--------0-------  output PCS5/PCS6
                                        ;---------0------  PCS in I/O space
                                        ;-------------0--  wait for RDY inputs
                                        ;--------------11  3 wait states

; Timing Definitions



; General Definitions

FIRST_RESERVED_VEC	EQU	1	;reserve vectors 1-3
LAST_RESERVED_VEC	EQU	3
NUM_IRQ_VECTORS         EQU     256     ;number of interrupt vectors

