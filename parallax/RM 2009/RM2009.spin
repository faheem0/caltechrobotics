'' File: RM2009.spin
'' For Caltech RoboMagellan 2009
''12/4/2008                                                                                    
{{history: 1.0 file copied from RoboMagellanMASTER1p0.spin, modified
                untested!
                
Known issues:
    

                   
   PIN   Purpose    Input  Output
    0   uartPCtx             X
    1   uartPCrx      X      
    2   uartCompasstx        X
    3   uartCompassrx X 
    4     
    5     
    6    
    7                         
    8   motor                X
    9   motor                X
    10  motor                X
    11  bumperSwitch  X
    12  compassEN            X        XXXX
    13  compassCLK           X        XXXX          
    14  compassDAT    X               XXXX
    15  motor                X
    16  uartSLVrx     X               XXXX
    17  uartSLVtx            X        XXXX
    18   LED                 X          
    19             
    20     
    21    
    22     
    23     
    24   psxClk              X
    25   psxAttn             X
    26   psxCmd              X
    27   psxDat       X      X
    
  COG usage:
     0: main cog (constantly updates encoder values, gets/sends CPU data)
     1: debug: terminal window/DAQ/graph
     2: 
     3: UART-PC
     4: 
     5: 
     6: UART-compass
     7:       
    
                                                 }}
VAR
    long motorLeftFront   'desired speed -100 to 100 indicating %
    long motorLeftBack
    long motorRightBack
    long motorRightFront
    
    long heartBeat  'for blinking the LED
 
    long timer
 
  
    'keeping track of when to send PC compass data
    long compassDataSendCounter
 
    long stopTurn                   '0 means keep going, anything not 0 means stop
    long isTurning                  '0 means not turning
    long turnCog
    
    long PCisConnected         '0 if PC-MCU connection is broken
    long PCtimeoutCount

    long isUsingPSX

    'for debugging
    long flag
    long timeOverCount

CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
       
    'pins
    _LED = 18
    _motLF = 8
    _motLB = 9
    _motRB = 10
    _motRF = 15
   
    _uartPCtx =    0 
    _uartPCrx =    1
    _uartCompasstx =   2   
    _uartCompassrx =   3   
    'Compass schematic
' P14 ──│1  6│── +3.3V     P12 = Enable
'         │  ├┴──┴┤  │               P13 = Clock
' P14 ──│2 │ /\ │ 5│── P12       P14 = Data
'         │  │/  \│  │
' VSS ──│3 └────┘ 4│── P13    
    _startByte = 254
    _stopByte = 233
    _cmdSetSpeed =217
    _cmdAck =218
    _cmdTurnAbs=220
    _cmdTurnRel=221
    _cmdStop=219 'ADD THIS TO PROTOCOL
    _cmdHasStopped=216
    _cmdDoneTurning = 215
    _cmdBumperSwitchOn = 214

 
    _NEXT_TIME_BYTE=254                                     

    _switchDebounceThreshold = 5  'at 20Hz
    

OBJ 'objects used in this program-code must be in same directory
    term:   "PC_Interface"
    psx:    "ps2ControllerV1p1" '"ps2ControllerV1p2d"
    uartPC:   "FullDuplexSerial"
    uartCompass: "FullDuplexSerial"   
    
PUB main  |temp  ,lowpass
   
    INITIALIZATION

'This function should be called several times per second
  'to display all important information     
PUB TxRxPC | cmdByte , counter,rx1,rx2,rx3,angle1,angle2  ,temp, maxCnt,endCnt
    
    maxCnt:= clkfreq/1000*12 '20Hz = 50ms period, 12ms for motor PID control
    endCnt:=cnt +maxCnt
    'check if using PSX controller
    if(navigatePSX<>0)
      term.str(string("navPSX "))
      uartPC.rxflush  
      return
    if(PCisConnected==0 and isUsingPSX==0)
      'motorLeftFront:=motorLeftBack:=motorRightBack:=motorRightFront:=0  NO EMERGENCY TIMEOUT
    'transmit data
    {{if (turnCog<>-1 and isTurning==0)       'send turn ack
      term.str(string("DONE TURNING!!!"))
      term.out($0d)
      uartPC.tx(_startByte)    'done turning 
      uartPC.tx(_cmdDoneTurning)
      'uartPC.tx(_cmdHasStopped)             '
      uartPC.tx(_stopByte)
      cogStop(turnCog)
      turnCog:=-1
    if TxRxPCTimeoutCheck(cnt>endCnt )<>0
      return 0   
    'receive data
    temp:=uartPC.rxcheck
    repeat until (temp == _startByte or cnt>endCnt)
      temp:=uartPC.rxcheck
    if TxRxPCTimeoutCheck(cnt>endCnt )<>0
      return 0
      
    'at this point, _startByte was received
    PCtimeoutCount:=0
    PCisConnected:=1  
    cmdByte :=uartPC.rx
    case  cmdByte                                   'get and parse command byte
      _cmdSetSpeed:
        term.str(string("set speed: "))
        rx1:= uartPC.rx-100 
        rx2:=uartPC.rx-100 
        rx3:=uartPC.rx
        uartSLV.tx(_delayAutoLevel)
        if rx3 <> _stopByte
          term.str(string("ERROR: invalid data packet"))
          return 0                                      
        if isTurning<>0
          term.str(string("ERROR: speed controlled in turn"))
        
        else
          term.dec(rx1)
          term.str(string(" "))
          term.dec(rx2)
          motorLeftFront:=rx1
          motorLeftBack:=rx1
          motorRightBack:=rx2
          motorRightFront:=rx2
        uartPC.tx(_startByte)    'confirm command 
        uartPC.tx(_cmdSetSpeed)   
        uartPC.tx(_stopByte)
        
      _cmdTurnAbs:
          term.str(string("turn abs: "))
          angle1:=uartPC.rx
          angle2:=uartPC.rx
          rx3:=uartPC.rx
          if rx3 <> _stopByte
            term.str(string("ERROR: invalid data packet"))
          elseif isTurning <>0
            term.str(string("ERROR: already turning!"))
          else
            uartSLV.tx(_resetAutoLevel)                
            angle1:=angle1+angle2
            term.dec(angle1)
            term.str(string(" degrees"))
            uartPC.tx(_startByte)    'confirm command 
            uartPC.tx(_cmdTurnAbs)   
            uartPC.tx(_stopByte)
            isTurning:=1 'true
            turnCog:=cognew(TURNTOANGLE(convertAnglefromPC(angle1)), @stack3[0])
            term.out($0d)
            term.str(string("COGNUM: "))
            term.dec(turnCog)
            term.out($0d)
            'pausems(500)
            
            
      _cmdTurnRel:   'TO BE IMPLEMENTED
           term.str(string("ERROR: turn rel: not impl yet"))
      _cmdStop:
          term.str(string("stop: "))
          uartSLV.tx(_delayAutoLevel)                        
          uartPC.tx(_startByte)    'confirm command 
          uartPC.tx(_cmdStop)   
          uartPC.tx(_stopByte)
          if isTurning ==0
            motorLeftFront:=0
            motorLeftBack:=0   
            motorRightBack:=0
            motorRightFront:=0
          else
            stopTurn:=1 'anything non zero disables turning
          
                                
          
          
      other:
        term.str(string("ERROR: invalid command"))
        term.out($0d)            }}
    'uartPC.rxflush
PUB TxRxPCTimeoutCheck(condition)
    if (condition)'timeout
       PCtimeoutCount++
       if PCtimeoutCount>100
         PCisConnected :=0 'no longer connected
       return 1
    return 0

'control drive motors with PSX if controller is plugged in and in analog mode (red LED on)
  'if not, does nothing (stop disabled)     
PUB navigatePSX
    psx.update
    if psx.getID <> 115       'controller is not in analog mode
      'motorRightFront:=motorLeftFront:=motorLeftBack:=motorRightBack:=0
      isUsingPSX:=0
      return 0
    else
      stopTurn:=1
      setMotorValuesFromPSX
      isUsingPSX:=1
      PCisConnected:=0 'force a timeout
      return 1

'set motor values from PSX     
PUB setMotorValuesFromPSX | rightJoy, leftJoy, deadBand, Dup, Ddown, Dright, Dleft, L1, L2, turnSpeed, driveSpeed
    deadBand :=28
    Dleft:=%01111111
    Ddown:=%10111111
    Dright:=%11011111
    Dup:=%11101111
    L1:=%11111011
    L2:=%11111110
    turnSpeed:=25
    driveSpeed:=50
    if psx.getThumbL <> %11111111
      if(psx.getThumbL| Dup== Dup)
         motorRightFront:=driveSpeed
         motorLeftFront:=driveSpeed
      elseif (psx.getThumbL| Ddown== Ddown)
         motorRightFront:=-1*driveSpeed
         motorLeftFront:=-1*driveSpeed
      if(psx.getThumbL| Dleft== Dleft)
         motorRightFront:=turnSpeed
         motorLeftFront:=-1*turnSpeed
      elseif (psx.getThumbL| Dright== Dright)
         motorRightFront:=-1*turnSpeed
         motorLeftFront:=turnSpeed  
      'term.bin(psx.getThumbR,8)
      'term.out($0d)
      if(psx.getThumbR|L1 ==L1)
        motorRightFront:=motorRightFront*2
        motorLeftFront:=motorLeftFront*2
    else
      rightJoy :=psx.getJoyRY          'get current joystick positions
      leftJoy := psx.getJoyLY        
       
      rightJoy:=rightJoy - 128                         'account for deadband in center
      if rightJoy > deadBand                                     'since joysticks do not center
        motorRightFront := -1* (rightJoy-deadBand)               'perfectly
      elseif rightJoy < -1*deadBand
        motorRightFront := -1* (rightJoy+deadBand)
      else
        motorRightFront := 0
       
      leftJoy:=leftJoy - 128
      if leftJoy > deadBand
        motorLeftFront := -1* (leftJoy-deadBand)
      elseif leftJoy < -1*deadBand
        motorLeftFront := -1* (leftJoy+deadBand)
      else
        motorLeftFront := 0
    
    motorLeftBack:=motorLeftFront       'set back wheels to same speed as front
    motorRightBack:=motorRightFront
          
'initializes pins/objects/etc       
PUB INITIALIZATION
    'initialize variables
    motorLeftFront :=0
    motorLeftBack :=0
    motorRightBack :=0
    motorRightFront :=0
    heartBeat :=0
    isTurning := 0
    turnCog:= -1
    
    LEDon
    dira[_LED]~~

    'initalize objects now
    'start terminal (prints to propterminal.exe)  
    term.start(31,30)     
    term.str(string("starting up"))
      'test with 9600 8 N 1
      'update 5/19/08 actually 115200 8 N 2...   
      uartPC.start(_uartPCrx,_uartPCtx, %0011 , 115200)'(rxpin, txpin, mode, baudrate) : okay
    ''uart mode bits:    
      '' mode bit 0 = invert rx
      '' mode bit 1 = invert tx
      '' mode bit 2 = open-drain/source tx
      '' mode bit 3 = ignore tx echo on rx
    'initialize playstation controller (doesn't use another COG)           
    psx.start(27,26,25,24) 'ddat, cmd, att, clk
    
    term.out($0d)
    term.str(string("cog #(0-7): "))
    term.out($0d)
    term.str(string("done"))
    pausems(1000)
         
    term.cls       
    LEDoff
    

'blinks LED using counter    
PUB blinkLED
    if heartBeat == 0
      LEDon
      heartBeat:=9
    else
      LEDoff
      heartBeat -= 1

    

PUB LEDon
    outa[_LED]~~
PUB LEDoff
    outa[_LED]~

      
PUB pausems(ms)
  waitcnt(cnt+clkfreq/1000*ms)

                      