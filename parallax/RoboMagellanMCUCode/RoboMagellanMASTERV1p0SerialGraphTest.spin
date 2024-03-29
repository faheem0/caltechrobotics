'' File: RoboMagellanMASTERV-p-.spin
'' For Caltech RoboMagellan 2008, code for MASTER MCU only.
''     MASTER-has 2 ribbon cables, connects to CPU
''     SLAVE-has 1 larger ribbon cable, connects to MASTER MCU
''5/2/2008                                                                                    
{{history: 1.0 file copied from balancingBotPEKv4p7.spin, modified
                MCU-MCU uart tested, works-weird timing thing fixed (hopefully)
                compass reading - works
                MCU-PC uart - should work
                everything else-UNTESTED
                encoder data- successfully received through uartΣ
                PWM-tested, works
                motor PID velocity control doesnt work
                playstation controller added (new pinout)-tested, works
           1.1 testing with graph software

Known issues: PID motor contorl doesn't work

                   
   PIN   Purpose    Input  Output
    0   uartPCtx      X
    1   uartPCrx             X
    2     
    3     
    4     
    5     
    6    
    7                         
    8   motor                X
    9   motor                X
    10  motor                X
    11   LED                 X
    12  compassEN            X
    13  compassCLK           X                  
    14  compassDAT    X
    15  motor                X
    16  uartSLVrx     X
    17  uartSLVtx            X
    18     
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
     2: UART-MCU
     3: UART-PC
     4: PWM (servos, motor controllers)
     5: motor velocity (PID) calculator
     6: compass
     7: turning code      
    
                                                 }}
VAR
    long motorLeftFront   'desired speed -100 to 100 indicating %
    long motorLeftBack
    long motorRightBack
    long motorRightFront
    
    long heartBeat  'for blinking the LED
    long stack[60] 'for motor cog
    long stack3[60] 'for turning
 
    long stack5[120] 'for motor PID control
    long timer
    

    'variables for turning code
    long compassLookup[361]
    long heading
    long initialHeading
    long angleCount

    long currentAng
    long initialAng
    long turnAngSign
    long desiredAng                 'absolute angle
    long estAngFromDesired
    long angFromDesired
    long angChange
    long desiredTurnAng             'may be signed from 180 to -180

    long stopTurn                   '0 means keep going, anything not 0 means stop
    long isTurning                  '0 means not turning
    long turnCog
    
    'variables updated by SLAVE-MCU
    long SLVencoderLFposition 
    long SLVencoderLBposition
    long SLVencoderRBposition
    long SLVencoderRFposition

    long SLVisConnected        '0 if MCU-MCU connection is broken
    long SLVtimeoutCount

    long PCisConnected         '0 if PC-MCU connection is broken
    long PCtimeoutCount
    
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
       
    'pins
    _LED = 11            
    _motLF = 8
    _motLB = 9
    _motRB = 10
    _motRF = 15
    
    _HM55EN= 12
    _HM55CL= 13      
    _HM55DA= 14

    _uartPCtx =    0 
    _uartPCrx =    1
    _uartSLVrx =   16   
    _uartSLVtx =   17   
    
' P21 ──│1  6│── +3.3V     P19 = Enable
'         │  ├┴──┴┤  │               P20 = Clock
' P21 ──│2 │ /\ │ 5│── P19       P21 = Data
'         │  │/  \│  │
' VSS ──│3 └────┘ 4│── P20    
    
    _motLFullReverse = 1146    'experimentally determined v883 PWM values
    _motLFMinReverse = 1489+20
    _motLFMinForward =  1558-20
    _motLFullForward =  1915
    _motRFullReverse = 1168
    _motRFMinReverse = 1488+20
    _motRFMinForward =  1556-20
    _motRFullForward =  1906

    'encoder has resolution of 24, gearbox has raio of 32, 24*32=768 counts/wheel rev
        '1mp ~= 88 feet per minute, wheel circumference= 3.14*(1 foot) = 3.14 feet
        '
    _motMaxSpeed=1100'430 'counts/second
    
    _startByte = 254
    _stopByte = 233
    _cmdSetSpeed =217
    _cmdAck =218
    _cmdTurnAbs=220
    _cmdTurnRel=221
    _cmdStop=219 'ADD THIS TO PROTOCOL
    _cmdHasStopped=216
    _cmdDoneTurning = 215
    '_scanResolution=10
    

    _NEXT_TIME_BYTE=254

 
    'compass constants
    _LMotorEN = 0
    _LMotorD1 = 1
    _LMotorD2 = 2

    _RMotorEN = 3
    _RMotorD1 = 5
    _RMotorD2 = 6

    

    _RealNearTarget = 10
    _NearTarget = 25                    
    _DeadBand = 1               'degrees within desired b4 stopping

    _TurnSpeed = 30
    _SlowTurnSpeed = 15
    _PulseSpeed = 15                'for getting into deadband
    
    _ThresholdAngChange = 5     '5 degrees per 200 ms
    _MaxAngChange = 10          
    _MotorChangeStep = 5       'max is 100
    

OBJ
    term:   "PC_Interface"
    PDAQ : "PLX-DAQ"
    acc:    "H48C Tri-Axis AccelerometerNoNewCog"       
    psx:    "ps2ControllerV1p1" '"ps2ControllerV1p2d"
    servos: "Servo32"
    uartPC:   "FullDuplexSerial"
    uartSLV: "FullDuplexSerial"
    graph:  "FullDuplexSerial"
    compass:    "HM55B Compass Module Asm" 
PUB main  |temp  ,lowpass

    
    INITIALIZATION
    {{term.cls
    term.str(string("printing: "))
    repeat
      temp:=uartPC.rxtime(1000)
      if temp <>-1
        term.dec(temp)
        term.out($0d)
      pausems(100)      }}
    'repeat
    '  term.hex(uartSLV.rx,2)
    '  term.out($0d)
    'motorLeftFront:=100
    
    'v883motorPWMTest
    v883motorPWMTestPSX    
    repeat
      temp:=cnt
      'TxRxMCU
      'TxRxPC
      MuxUARTs
      term.cls     
      term.str(string("isConnected PC: "))
      term.dec(PCisConnected)
      term.str(string(" SLV: "))
      term.dec(SLVisConnected)
       
       
      term.out($0d)
      term.str(string("LFenc: "))
      term.dec(SLVencoderLFposition)
      term.str(string(" LBenc: "))
      term.dec(SLVencoderLBposition)
      term.str(string(" RBenc: "))
      term.dec(SLVencoderRBposition)
      term.str(string(" RFenc: "))
      term.dec(SLVencoderRFposition)
      term.out($0d)
      term.dec((cnt-temp)/80000)
      term.str(string(" ms"))

      term.out($0d)
      term.str(string("motorLF: "))
      term.dec(motorLeftFront)
      term.str(string(" "))
      term.dec(motorLeftBack)
      term.str(string(" "))
      term.dec(motorRightBack)
      term.str(string(" "))
      term.dec(motorRightFront)
      pausems(50)
      blinkLED
      
   {{ repeat
     term.dec(compass.theta)
     waitcnt(cnt+clkfreq/5)
     term.out($0d)
    repeat
      term.cls
      term.dec(compass.theta*10/227)
      term.out($0d)
      pausems(100)  }}
   {{ repeat                             'test compass linearization code
      temp:=compass.theta
      lowpass:=(80*lowpass+20*temp)/100
      temp:=lowpass
      term.str(string("raw: "))
      term.dec(temp)
      
      term.out($0d)
      term.str(string("scaled: "))
      term.dec(temp*10/227)

      term.out($0d)
      term.str(string("lookup: "))
      term.dec(compassLookup[temp*10/227])
      
      
      term.out($0d)
      pausems(100)
      term.cls      }}
    
    
    TURNTOANGLE (180)
    term.str(string("done turning"))
    'repeat
    repeat
      
      'term.cls
      TxRxPC
      pausems(100)
    'v883motorPWMTest
    'v883motorPWMTestPSX
    'PIDmotorLoop(1)
    'printAngle
    'printAngleDAQ
     'printAngleGraph
    'printGyro
    'angleBalanceLoop  



'tests v883 and encoders         
PUB v883motorPWMTest| refreshPerSec,PWMValue,cntStart,cntFinish,temp,lastPos[4], currentPos[4],rpm[4] ,i
 PWMValue:=1500  
 refreshPerSec:=10
 repeat i from 0 to 3    'initialize variables
   lastPos[i]:=0
   currentPos[i]:=0
   rpm[i]:=0
 repeat
    temp:=cnt+clkfreq/refreshPerSec
     MuxUARTs
    if term.button(0)
      if(term.abs_x < 319/2) 
        PWMValue+=1
      else
        PWMValue+=10
    elseif term.button(1)
      if(term.abs_x < 319/2) 
        PWMValue-=1
      else
        PWMValue-=10 

    servos.set(_motLF,PWMValue)    
    servos.set(_motLB,PWMValue)    
    servos.set(_motRB,PWMValue)
    servos.set(_motRF,PWMValue)
     
    PWMValue<#= 2000                
    PWMValue#>=1000
    currentPos[0]:=SLVencoderLFposition
    currentPos[1]:=SLVencoderLBposition     
    currentPos[2]:=SLVencoderRBposition     
    currentPos[3]:=SLVencoderRFposition
    repeat i from 0 to 3
      rpm[i]:= (currentPos[i]-lastPos[i])*refreshPerSec*60/24/32
    
    term.cls
    term.str(string("isConnected PC: "))
    term.dec(PCisConnected)
    term.str(string(" SLV: "))
    term.dec(SLVisConnected)
    term.str(string("PWM value: "))
    term.dec(PWMValue)
    term.out($0d)
    term.str(string("    LF   LB   RB   RF"))
    term.out($0d)
    term.str(string("pos: "))
    repeat i from 0 to 3
      term.dec(currentPos[i])
      term.str(string(" "))
    term.out($0d)
    term.str(string("rpm: "))
    repeat i from 0 to 3
      term.dec(rpm[i])
      term.str(string(" "))
    term.out($0d)
    term.str(string("counts: "))
    repeat i from 0 to 3
      term.dec(currentPos[i]-lastPos[i])
      term.str(string(" "))
    term.out($0d)
    term.str(string("MPH: "))   '1mph = 88 fpm
    repeat i from 0 to 3
      term.dec(rpm[i]*314/88)
      term.str(string(" "))
    term.out($0d)
    
    term.out($0d)
    repeat i from 0 to 3
      lastPos[i]:=currentPos[i]
    
    waitcnt(temp)

'tests v883 and encoders         
PUB v883motorPWMTestPSX| ramp,motorRightRamped, motorLeftRamped,refreshPerSec,PWMValue,cntStart,cntFinish,temp,lastPos[4], currentPos[4],rpm[4] ,i
 PWMValue:=1500  
 refreshPerSec:=10
 ramp:=80
 motorRightRamped:=0
 motorLeftRamped:=0
 repeat i from 0 to 3    'initialize variables
   lastPos[i]:=0
   currentPos[i]:=0
   rpm[i]:=0
 repeat
    temp:=cnt+clkfreq/refreshPerSec
     MuxUARTs
   
    navigatePSX                
    motorRightRamped:= (ramp*motorRightRamped+ (100-ramp)*motorRightFront)/100
    motorLeftRamped:= (ramp*motorLeftRamped+ (100-ramp)*motorLeftFront)/100
        
    setMotorLeftFront(motorLeftRamped)
    setMotorLeftBack(motorLeftRamped)
    setMotorRightBack(motorRightRamped) 
    setMotorRightFront(motorRightRamped) 

    currentPos[0]:=SLVencoderLFposition
    currentPos[1]:=SLVencoderLBposition     
    currentPos[2]:=SLVencoderRBposition     
    currentPos[3]:=SLVencoderRFposition
    repeat i from 0 to 3
      rpm[i]:= (currentPos[i]-lastPos[i])*refreshPerSec*60/24/32
    
    term.cls
    term.str(string("isConnected PC: "))
    term.dec(PCisConnected)
    term.str(string(" SLV: "))
    term.dec(SLVisConnected)
    term.str(string("    LF   LB   RB   RF"))
    term.out($0d)
    term.str(string("stpt: "))
    term.dec(motorLeftFront)
    term.str(string(" "))
    term.dec(motorLeftBack)
    term.str(string(" "))
    term.dec(motorRightBack)
    term.str(string(" "))
    term.dec(motorRightFront)
    term.out($0d)
    term.str(string("pos: "))
    repeat i from 0 to 3
      term.dec(currentPos[i])
      term.str(string(" "))
    term.out($0d)
    term.str(string("rpm: "))
    repeat i from 0 to 3
      term.dec(rpm[i])
      term.str(string(" "))
    term.out($0d)
    term.str(string("counts: "))
    repeat i from 0 to 3
      term.dec(currentPos[i]-lastPos[i])
      term.str(string(" "))
    term.out($0d)
    term.str(string("MPH: "))   '1mph = 88 fpm
    repeat i from 0 to 3
      term.dec(rpm[i]*314/88)
      term.str(string(" "))
    term.out($0d)
    
    term.out($0d)
    repeat i from 0 to 3
      lastPos[i]:=currentPos[i]
    
    waitcnt(temp)    

         
'setMotor functions allow power curve to be manipulated HERE
PUB setMotorLeftFront(val)
    setSegwayLeft(val)
   
PUB setMotorRightFront(val)
    setSegwayRight(val)
    
PUB setMotorLeftBack(val)
    
PUB setMotorRightBack(val)
      
PUB setSegwayLeft(val)
    if ||val < 3
      val:=0
    val<#=100                
    val#>=-100
    if(val==0)  'stopped
      servos.set(_motLF,(_motLFMinReverse+_motLFMinForward)/2)
    elseif val< 0 'reverse
      servos.set(_motLF,_motLFMinReverse -(_motLFMinReverse-_motLFullReverse)*-1*val/100)
    else 'forward
      servos.set(_motLF,(_motLFullForward-_motLFMinForward)*val/100+_motLFMinForward)
PUB setSegwayRight(val)
    if ||val < 3
      val:=0
    val<#=100                
    val#>=-100
    if(val==0)  'stopped
      servos.set(_motRF,(_motRFMinReverse+_motRFMinForward)/2)
    elseif val< 0 'reverse
      servos.set(_motRF,_motRFMinReverse -(_motRFMinReverse-_motRFullReverse)*-1*val/100)
    else 'forward
      servos.set(_motRF,(_motRFullForward-_motRFMinForward)*val/100+_motRFMinForward)   


       
'receives these bytes: start, encoder data, stop
PUB TxRxMCU | tempBuff[16] ,i  ,counter, tempr, maxCnt,endCnt
    maxCnt:= clkfreq/1000*15 '20Hz = 50ms period, 12ms for motor PID control
    endCnt:=cnt +maxCnt
    'receive data
    uartSLV.rxflush
    tempr:=uartSLV.rxcheck               
    repeat until (tempr == _startByte or cnt>endCnt)
      tempr:=uartSLV.rxcheck
      'term.dec(1)
    if TxRxMCUTimeoutCheck(cnt>endCnt )<>0
      
      return 0
    pausems(1)'term.str(string("FLAG"))   REALLY WEIRD BUT IT WORKS     
    'else temp==_startByte         
    repeat i from 0 to 15                   'read in 16 data bytes
      tempr:=uartSLV.rxcheck
      repeat until tempr <> -1 or cnt >endCnt
      if TxRxMCUTimeoutCheck(cnt>endCnt )<>0
        
        return 0
      else
         tempBuff[i]:=tempr
     
    if(uartSLV.rxtime((endCnt-cnt)*clkfreq/1000)<>_stopByte)
      'invalid data
      'term.str(string("invalid data packet"))
      'term.out($0d)
      SLVtimeoutCount++
      if SLVtimeoutCount>10
        SLVisConnected :=0 'no longer connected
       return 0
    else
       'term.str(string("valid data"))
       'term.out($0d)
       SLVtimeoutCount:=0
       SLVisConnected:=1
       SLVencoderLFposition:=tempBuff[0]|(tempBuff[1]<<8)|(tempBuff[2]<<16)|(tempBuff[3]<<24)
       SLVencoderLBposition:=tempBuff[4]|(tempBuff[5]<<8)|(tempBuff[6]<<16)|(tempBuff[7]<<24)
       SLVencoderRBposition:=tempBuff[8]|(tempBuff[9]<<8)|(tempBuff[10]<<16)|(tempBuff[11]<<24)
       SLVencoderRFposition:=tempBuff[12]|(tempBuff[13]<<8)|(tempBuff[14]<<16)|(tempBuff[15]<<24)   
       {{term.str(string("LF: "))
       term.hex(SLVencoderLFposition, 8)
       term.out($0d)
       term.str(string("LB: "))
       term.hex(SLVencoderLBposition, 8)
       term.out($0d)
       term.str(string("RB: "))
       term.hex(SLVencoderRBposition, 8)
       term.out($0d)
       term.str(string("RF: "))
       term.hex(SLVencoderRFposition, 8)
       term.out($0d) }}
       return 1
PUB TxRxMCUTimeoutCheck(condition)
    if (condition)'timeout
       SLVtimeoutCount++
       if SLVtimeoutCount>20
         SLVisConnected :=0 'no longer connected
       return 1
    return 0
'receives these bytes: start, command, <data>, stop    
PUB TxRxPC | cmdByte , counter,rx1,rx2,rx3,angle1,angle2  ,temp, maxCnt,endCnt
    maxCnt:= clkfreq/1000*15 '20Hz = 50ms period, 12ms for motor PID control
    endCnt:=cnt +maxCnt
    'transmit data
    if (turnCog<>-1 and isTurning==0)       'send turn ack
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
    'else, temp == _startByte
    PCtimeoutCount:=0
    PCisConnected:=1  
    cmdByte :=uartPC.rx
    case  cmdByte                                   'get and parse command byte
      _cmdSetSpeed:
        term.str(string("set speed: "))
        rx1:= uartPC.rx-100 
        rx2:=uartPC.rx-100 
        rx3:=uartPC.rx
        if rx3 <> _stopByte
          term.str(string("invalid data packet"))
          return 0                                      
        if isTurning==0
          term.str(string("speed controlled in turn"))
        
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
            term.str(string("invalid data packet"))
          elseif isTurning <>0
            term.str(string("error: already turning!"))
          else
            angle1:=angle1+angle2
            term.dec(angle1)
            term.str(string(" degrees"))
            uartPC.tx(_startByte)    'confirm command 
            uartPC.tx(_cmdTurnAbs)   
            uartPC.tx(_stopByte)
            isTurning:=1 'true
            turnCog:=cognew(TURNTOANGLE(angle1), @stack3[0])
            term.out($0d)
            term.str(string("COGNUM: "))
            term.dec(turnCog)
            term.out($0d)
            pausems(500)
            
      _cmdTurnRel:   'fill in
           term.str(string("turn rel: not impl yet"))
      _cmdStop:
          term.str(string("stop: "))                            
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
        term.str(string("invalid command"))
        term.out($0d)  
    'uartPC.rxflush
PUB TxRxPCTimeoutCheck(condition)
    if (condition)'timeout
       PCtimeoutCount++
       if PCtimeoutCount>100
         PCisConnected :=0 'no longer connected
       return 1
    return 0
PUB MuxUARTs
   'repeat
    TxRxMCU
    TxRxPC
      
'control drive motors with PSX     
PUB navigatePSX
    psx.update
    if psx.getID <> 115       'controller not in analog mode
      motorRightFront:=motorLeftFront:=motorLeftBack:=motorRightBack:=0
    else
      setMotorValuesFromPSX

'set motor values from PSX     
PUB setMotorValuesFromPSX | rightJoy, leftJoy
    rightJoy :=psx.getJoyRY
    leftJoy := psx.getJoyLY        
    
    rightJoy:=rightJoy - 128
    if rightJoy > 28
      motorRightFront := -1* (rightJoy-28)
    elseif rightJoy < -28
      motorRightFront := -1* (rightJoy+28)
    else
      motorRightFront := 0

    leftJoy:=leftJoy - 128
    if leftJoy > 28
      motorLeftFront := -1* (leftJoy-28)
    elseif leftJoy < -28
      motorLeftFront := -1* (leftJoy+28)
    else
      motorLeftFront := 0
    
    motorLeftBack:=motorLeftFront
    motorRightBack:=motorRightFront       
'inits pins/objects/etc       
PUB INITIALIZATION
    motorLeftFront :=0
    motorLeftBack :=0
    motorRightBack :=0
    motorRightFront :=0
    heartBeat :=0
    initCompassLookup
    isTurning := 0
    turnCog:= -1
    SLVisConnected:=1
    
    LEDon
    dira[_LED]~~
    
    term.start(31,30)     'start terminal COG
    term.str(string("starting up"))
    graph.start(_uartPCrx,_uartPCtx,%0010,9600)                              ' Rx,Tx, Mode, Baud   COG

    'test with 9600 8 N 1    
    'uartPC.start(_uartPCrx,_uartPCtx, %0011 , 115200)'(rxpin, txpin, mode, baudrate) : okay

    uartSLV.start(_uartSLVrx,_uartSLVtx, %0000 , 115200)'(rxpin, txpin, mode, baudrate) : okay       
'' mode bit 0 = invert rx
'' mode bit 1 = invert tx
'' mode bit 2 = open-drain/source tx
'' mode bit 3 = ignore tx echo on rx

    'compass init stuff
    compass.start(_HM55EN,_HM55CL,_HM55DA )'start(EnablePin,ClockPin,DataPin):okay
    heading := compass.theta*10/227
    angleCount := 0
    initialHeading := heading  
    

   
    servos.set(_motLF,1500)
    servos.set(_motLB,1500)
    servos.set(_motRB,1500)
    servos.set(_motRF,1500)
    servos.start     'start servo COG
    '1000   150k= 90deg inc 17
    '1450...23k = 90deg inc 1
    '1485...12k = 90deg inc 1
    '2000...140 = 90deg

    psx.start(27,26,25,24) 'ddat, cmd, att, clk
    term.out($0d)
    term.str(string("cog #(0-7): "))
    'term.dec(cognew(PIDmotorLoop(0), @stack5[0]))  'start motor PID control loop COG
    term.out($0d)
    'term.str(string("cog #(0-7): "))      
    'term.dec(cognew(filterLoop,@stack4[0])) 'start filter calculating COG
    
    'term.dec(cognew(readGyroLoop, @stack3[0])) 'start gyro PWM COG            
    
    
    term.out($0d)
    term.str(string("done"))
    pausems(1000)
         
    term.cls       
    LEDoff
    PIDmotorLoop(1)
'blinks LED using counter    
PUB blinkLED
    if heartBeat == 0
      LEDon
      heartBeat:=10
    else
      LEDoff
      heartBeat -= 1

PUB LEDon
    outa[_LED]~~
PUB LEDoff
    outa[_LED]~
    
'PID motor control with v883 motor controllers
'updates motor speed based on motorLeft and motorRight, encoder data
'output = kP*position + kD*velocity
'd(output) = kP*velocity + kD*acceleration
'output= output+ d(output)= output + kP*velocity + kD*acceleration
PUB PIDmotorLoop(debugGraph) | motorRFRamped, motorLFRamped, ramp,avgVelLF,avgVelRF,freq, delay,motorLeftFrontSpeed,motorRightFrontSpeed,errorLF,errorRF , kmPrf,kmDrf,kmPlf,kmDlf ,velLF,lastVelLF,lastVelRF, velRF, accLF, accRF,encCountLF, encCountRF,valLF, valRF,temp, XXXXXX,motorRBRamped, motorLBRamped,avgVelLB,avgVelRB,motorLeftBackSpeed,motorRightBackSpeed,errorLB,errorRB , kmPrb,kmDrb,kmPlb,kmDlb ,velLB,lastVelLB,lastVelRB, velRB, accLB, accRB,encCountLB, encCountRB,valLB, valRB
    '1.2mph=33.6 wheel rpm = 430 encoder counts/second
    'at 24V, 80 cnts/sample
    '20Hz ~21 counts/sample
    freq:=20 'Hz
    ramp:=80

    'initalize constants (adjustable)
    kmPrf:=7  'proportionality gain
    kmDrf:=-6'-2   'derivative gain (make negative)
    kmPlf:=4
    kmDlf:=-6

    kmPrb:=kmPrf     'if you change these, change them below too before they are actually used
    kmDrb:=kmDrf
    kmPlb:=kmPlf
    kmDlb:=kmDlf
    
    'initialize variables
    valLF:=0
    valLB:=0
    valRB:=0
    valRF:=0
    lastVelLF:=0
    lastVelLB:=0
    lastVelRB:=0
    lastVelRF:=0
    motorLFRamped:=0
    motorLBRamped:=0
    motorRBRamped:=0
    motorRFRamped:=0
                    
    
    
    
    repeat
      delay:=cnt+clkfreq/freq
      TxRxMCU
      if debugGraph==1
        'just for debugging purposes: update desired speeds with values from PSX  
        navigatePSX   'set motorLeft and motorRight from PSX
        'adjust PID constants from terminal
        if(term.button(0))
          if(term.abs_x < 319/2 and term.abs_y <216/2)
            'open
          elseif(term.abs_x < 319/2 and term.abs_y >216/2)    'lower left corner
            kmPrf--
            kmPlf--
          elseif(term.abs_x > 319/2 and term.abs_y >216/2)      'lower right corner
            kmDrf++
            kmDlf++        
        elseif term.button(1)
          if(term.abs_x < 319/2 and term.abs_y <216/2) 
            'open
          elseif(term.abs_x < 319/2 and term.abs_y >216/2)
            kmPrf++
            kmPlf++
          elseif(term.abs_x > 319/2 and term.abs_y >216/2)
            kmDrf--
            kmDlf--
              
      kmPrb:=kmPrf   'temporarily?
      kmDrb:=kmDrf
      kmPlb:=kmPlf
      kmDlb:=kmDlf
      'ramp motor speed                                                          
      motorLFRamped:= (ramp*motorLFRamped+ (100-ramp)*motorLeftFront)/100         'get desired speed from global variables
      motorLBRamped:= (ramp*motorLBRamped+ (100-ramp)*motorLeftBack)/100
      motorRBRamped:= (ramp*motorRBRamped+ (100-ramp)*motorRightBack)/100
      motorRFRamped:= (ramp*motorRFRamped+ (100-ramp)*motorRightFront)/100
                 
      'update desired motor speeds, encoder counts,velocities
      motorLeftFrontSpeed:=motorLFRamped     'use ramped speeds
      motorLeftBackSpeed:=motorLBRamped     
      motorRightBackSpeed:=motorRBRamped
      motorRightFrontSpeed:=motorRFRamped
      temp:=SLVencoderLFposition          'update position counter and current velocity
      velLF:=encCountLF-temp
      encCountLF:=temp
      temp:=SLVencoderLBposition          
      velLB:=encCountLB-temp
      encCountLB:=temp      
      temp:=SLVencoderRBposition
      velRB:=encCountRB-temp
      encCountRB:=temp  
      temp:=SLVencoderRFposition
      velRF:=encCountRF-temp
      encCountRF:=temp
      'update acceleration
      accLF:=(velLF-lastVelLF)*100*freq/_motMaxSpeed      'update acc, (in terms of -100 to 100)
      accLB:=(velLB-lastVelLB)*100*freq/_motMaxSpeed      'update acc, (in terms of -100 to 100)  
      accRB:=(velRB-lastVelRB)*100*freq/_motMaxSpeed   'update acc, (in terms of -100 to 100)
      accRF:=(velRF-lastVelRF)*100*freq/_motMaxSpeed   'update acc, (in terms of -100 to 100)  
      lastVelLF:=velLF
      lastVelLB:=velLB
      lastVelRB:=velRB
      lastVelRF:=velRF

      motorLeftFrontSpeed<#=100                 'limit input from -100% to 100%
      motorLeftFrontSpeed#>=-100
      motorLeftBackSpeed<#=100                 
      motorLeftBackSpeed#>=-100
      motorRightBackSpeed<#=100
      motorRightBackSpeed#>=-100
      motorRightFrontSpeed<#=100
      motorRightFrontSpeed#>=-100

      'calculate velocity error (in terms of -100 to 100), ranges from -200 to 200
      errorLF:= motorLeftFrontSpeed -velLF*100*freq/_motMaxSpeed
      errorLB:= motorLeftBackSpeed -velLB*100*freq/_motMaxSpeed
      errorRB:= motorRightBackSpeed -velRB*100*freq/_motMaxSpeed
      errorRF:= motorRightFrontSpeed -velRF*100*freq/_motMaxSpeed
      

      valLF:=valLF + kmPlf*errorLF/10 + kmDlf*accLF/10    'no int term
      valLB:=valLB + kmPlb*errorLB/10 + kmDlb*accLB/10    'no int term
      valRB:=valRB + kmPrb*errorRB/10 + kmDrb*accRB/10 'no int term
      valRF:=valRF + kmPrf*errorRF/10 + kmDrf*accRF/10 'no int term

      valLF<#=100                 'limit output from -100% to 100%
      valLF#>=-100
      valLB<#=100
      valLB#>=-100
      valRB<#=100
      valRB#>=-100
      valRF<#=100
      valRF#>=-100

      'prevent reversing the motors direction instantaneously
      if motorLeftFrontSpeed>0
        valLF#>=0
      elseif motorLeftFrontSpeed<0
        valLF<#=0
      if motorLeftBackSpeed>0
        valLB#>=0
      elseif motorLeftBackSpeed<0
        valLB<#=0
      if motorRightBackSpeed>0
        valRB#>=0
      elseif motorRightBackSpeed<0
        valRB<#=0
      if motorRightFrontSpeed>0
        valRF#>=0
      elseif motorRightFrontSpeed<0
        valRF<#=0
      
      'prevent stalling
      if motorLeftFrontSpeed>10
        valLF#>=10
      elseif motorLeftFrontSpeed < -10
        valLF<#= -10
      if motorLeftBackSpeed>10
        valLB#>=10
      elseif motorLeftBackSpeed < -10
        valLB<#= -10
      if motorRightBackSpeed>10
        valRB#>=10
      elseif motorRightBackSpeed < -10
        valRB<#= -10  
      if motorRightFrontSpeed>10
        valRF#>=10
      elseif motorRightFrontSpeed < -10
        valRF<#= -10  
      
       
      if(SLVisConnected <>0)
        setMotorLeftFront(valLF)        'actually set motor speed here
        setMotorLeftBack(valLB)      
        setMotorRightBack(valRB)
        setMotorRightFront(valRF)
      else
        setMotorLeftFront(0)        'actually set motor speed here
        setMotorLeftBack(0)      
        setMotorRightBack(0)
        setMotorRightFront(0)

      avgVelRF:= (8*avgVelRF+velRF*100*freq/_motMaxSpeed*2)/10   'put motor speed thru low pass, make more readable
      avgVelRB:= (8*avgVelRB+velRB*100*freq/_motMaxSpeed*2)/10 
      avgVelLB:= (8*avgVelLB+velLB*100*freq/_motMaxSpeed*2)/10
      avgVelLF:= (8*avgVelLF+velLF*100*freq/_motMaxSpeed*2)/10

      'graph data to serialPlot (java)          'THIS PART NOT UPDATED FOR 4WD
      if debugGraph==1
        if( 1==0)   'graph right side
          graph.tx(motorRightFrontSpeed)           'setpoint
          graph.tx(avgVelRF)   'actual velocity
          graph.tx(valRF)                    ' signal output to motor
          graph.tx(kmPrf*10)
          graph.tx(kmDrf*10)
        else       'or graph left side
          graph.tx(motorLeftFrontSpeed)           'setpoint
          graph.tx(avgVelLF)   'actual velocity
          graph.tx(valLF)                    ' signal output to motor
          graph.tx(kmPlf*10)
          graph.tx(kmDlf*10)
         
        graph.tx(_NEXT_TIME_BYTE)
         
        term.cls                               'print PID constants for tuning
        term.str(string("kmPrf: "))
        term.dec(kmPrf)
        term.out($0d)
        term.str(string("kmDrf: "))
        term.dec(kmDrf)
        term.out($0d)
        term.str(string("kmPlf: "))
        term.dec(kmPlf)
        term.out($0d)
        term.str(string("kmDlf: "))
        term.dec(kmDlf)
        term.out($0d)
        term.str(string("stpt: "))
        term.dec(motorRightFrontSpeed)
        term.str(string(" meas: "))
        term.dec(valRF)
      {{
      
      term.str(string("setpt L (%): "))                  'print data to terminal
      term.dec(motorLeftSpeed)
      term.out($0d)
      term.str(string("setpt R: "))
      term.dec(motorRightSpeed)
      term.out($0d)
      term.str(string("vel L (%): "))
      term.dec(velLF*100*freq/_motMaxSpeed)
      term.out($0d)
      term.str(string("vel R: "))
      term.dec(velRF*100*freq/_motMaxSpeed)
      term.out($0d)
      term.str(string("out L (%): "))
      term.dec(valLF)
      term.out($0d)
      term.str(string("out R: "))
      term.dec(valRF)
      term.out($0d)
      term.str(string("acc L (v%/20s): "))
      term.dec(accLF)
      term.out($0d)
      term.str(string("acc R: "))
      term.dec(accRF)
      term.out($0d)
      term.str(string("Err L (%): "))
      term.dec(errorL)
      term.out($0d)
      term.str(string("Err R: "))
      term.dec(errorR)
      term.out($0d)           }}
     
      'term.out($0d)
      'term.dec((delay-cnt)/80)
      'term.str(string("us left"))    
      
      waitcnt(delay)                        'wait to achieve desired update frequency

 
PUB pausems(ms)
  waitcnt(cnt+clkfreq/1000*ms)


'COMPASS code
PUB TURNTOANGLE (angle)
       'turns to the desiredAng, exit anytime by setting stopTurn to non-zero

     stopTurn := 0
     desiredAng := angle 
     term.cls 
     initialAng := GETCURRENTANG

     if (stopTurn <> 0)
          motorLeftFront := 0
          motorLeftBack:=motorLeftFront 
          motorRightFront := 0
          motorRightBack:=motorRightFront
          isTurning:=0
          return
     
     desiredTurnAng := desiredAng - initialAng
     if (desiredTurnAng > 180)
          desiredTurnAng := desiredTurnAng - 360
     if (desiredTurnAng < -180)
          desiredTurnAng := desiredTurnAng + 360     
     
     if (desiredTurnAng => 0)
        turnAngSign := 1
     else
        turnAngSign := -1
   
        
     term.str(string("initialAng: "))
     term.dec(initialAng)
     term.out($0d)
     term.str(string("desiredAng: "))
     term.dec(desiredAng)
     pausems(2000)
     term.cls

     if (stopTurn <> 0)
          motorLeftFront := 0
           motorLeftBack:=motorLeftFront 
           motorRightFront := 0
           motorRightBack:=motorRightFront
           isTurning:=0
          return
     
     'get car to start turning
     REPEAT WHILE (GetAngFromDesired > _RealNEARTARGET)
          if (stopTurn <> 0)
                motorLeftFront := 0
                motorLeftBack:=motorLeftFront 
                motorRightFront := 0
                motorRightBack:=motorRightFront
                isTurning:=0
              return
          term.cls
         if (angFromDesired > _NearTarget)
            motorLeftFront := turnAngSign * _TurnSpeed
            motorLeftBack:=motorLeftFront
            motorRightFront := - turnAngSign * _TurnSpeed
            motorRightBack:=motorRightFront
            term.str(string("turning"))
            term.out($0d)
         else
            motorLeftFront := turnAngSign * _SlowTurnSpeed
            motorLeftBack:=motorLeftFront      
            motorRightFront := - turnAngSign * _SlowTurnSpeed
            motorRightBack:=motorRightFront
            term.str(string("slowly turning"))
            term.out($0d)
        term.str(string("currentAng: "))   
        term.dec(currentAng)
        term.out($0d)
        term.str(string("angFromDesired: "))   
        term.dec(angFromDesired)
        term.out($0d)
        
     'stops motors when nearTarget
     
    motorLeftFront := 0
    motorLeftBack:=motorLeftFront 
    motorRightFront := 0
    motorRightBack:=motorRightFront 
          
     if (stopTurn <> 0)
             motorLeftFront := 0
            motorLeftBack:=motorLeftFront 
             motorRightFront := 0
             motorRightBack:=motorRightFront
             isTurning:=0
          return
           
     term.cls
     
     term.str(string("initialAng: "))   
     term.dec(initialAng)
     term.out($0d)
     term.str(string("currentAng: "))   
     term.dec(currentAng)
     term.out($0d)
     term.str(string("desiredAng: "))
     term.dec(desiredAng)
     term.out($0d) 
     term.str(string("angFromDesired: "))   
     term.dec(angFromDesired)
     term.out($0d)
     
     pausems(2000)
       if (stopTurn <> 0)
             motorLeftFront := 0
                 motorLeftBack:=motorLeftFront 
              motorRightFront := 0
              motorRightBack:=motorRightFront
              isTurning:=0
          return
     
     'inch till within deadBand
 
       
       if ||GETANGFROMDESIRED > _deadBand
         REPEAT UNTIL ||GETANGFROMDESIRED =< _deadBand
              if (stopTurn <> 0)
                      motorLeftFront := 0
                        motorLeftBack:=motorLeftFront 
                    motorRightFront := 0
                    motorRightBack:=motorRightFront
                    isTurning:=0
                return
             term.cls 
           if angFromDesired > 0
             motorLeftFront := turnAngSign *_PulseSpeed
             motorLeftBack:=motorLeftFront 
             motorRightFront := - turnAngSign *_PulseSpeed
             motorRightBack:=motorRightFront 
           else
             motorLeftFront := - turnAngSign *_PulseSpeed
             motorLeftBack:=motorLeftFront 
             motorRightFront := turnAngSign *_PulseSpeed
             motorRightBack:=motorRightFront   
           term.str(string("angFromDesired: "))   
           term.dec(angFromDesired)
           term.out($0d)
           pausems(50)
           motorLeftFront := 0
           motorLeftBack:=motorLeftFront    
           motorRightFront := 0
           motorRightBack:=motorRightFront 
           
           
    
     term.str(string("In DeadBand"))
          term.out($0d)
          term.str(string("angFromDesired: "))   
           term.dec(angFromDesired)
           term.out($0d)
           term.str(string("currentAng: "))   
          term.dec(currentAng)
           term.out($0d)
     isTurning:=0
     
    return

PUB GETANGFROMDESIRED
                    'takes at least 100 ms
    if (turnAngSign > 0)
         if (GETCURRENTANG > 150 + desiredAng)  'if true, then must cross 360-0 gap)
               angFromDesired := desiredAng + 360 - currentAng
         elseif (desiredAng > 210 + currentAng)   'overshot the 360-0 gap
               angFromDesired := desiredAng - 360 - currentAng
         else
               angFromDesired := desiredAng - currentAng            
    if (turnAngSign < 0)
         if (GETCURRENTANG > 210 + desiredAng)  
               angFromDesired := currentAng - desiredAng - 360
         elseif (desiredAng > 150 + currentAng)   
               angFromDesired := currentAng + 360 - desiredAng
         else
               angFromDesired := currentAng - desiredAng 
    RETURN  angFromDesired    

PUB GETCURRENTANG   |ang1, ang2, ang3, ang4, sum, tempAng
                'takes 100 ms
    sum := 0
                
        ang1 := compassLookUp[compass.theta*10/227] 
        pausems(33)
        ang2 := compassLookUp[compass.theta*10/227]
        pausems(33)
        ang3 := compassLookUp[compass.theta*10/227]
        pausems(33)
        ang4 := compassLookUp[compass.theta*10/227]

        'special case for angs close to 0, 360
        
     if ||(ang1-ang2)=> 300 OR  ||(ang1-ang3)=> 300 OR ||(ang1-ang4)=> 300
          if ang1 > 300
                ang1 := ang1 - 360
          if ang2 > 300
                ang2 := ang2 - 360
          if ang3 > 300
                ang3 := ang3 - 360
          if ang4 > 300
                ang4 := ang4 - 360
          sum := ang1+ang2+ang3+ang4
          tempAng := sum/4
          if tempAng < 0
                tempAng := 360 + tempAng
                                  
     else
          sum := ang1+ang2+ang3+ang4
          tempAng := sum/4

     currentAng := tempAng
          
    Return currentAng

PUB GETANGCHANGE   |ang1, ang2, ang3, ang4, ang5, ang6, change1, change2, change3

   'signed ang change over 200 ms
   'takes about 300 ms

    ang1 := GETCURRENTANG
    pausems(100)
    ang2 := GETCURRENTANG

        
    angChange := (ang2-ang1)
    if angChange > 300
          angChange := angChange - 360

    if angChange < -300
          angChange := angChange + 360      
    Return (angChange)

PUB initCompassLookup
  compassLookup[  0       ]:=     315
  compassLookup[  1       ]:=     316
  compassLookup[  2       ]:=     317
  compassLookup[  3       ]:=     319
  compassLookup[  4       ]:=     320
  compassLookup[  5       ]:=     322
  compassLookup[  6       ]:=     324
  compassLookup[  7       ]:=     326
  compassLookup[  8       ]:=     327
  compassLookup[  9       ]:=     328
  compassLookup[  10      ]:=     329
  compassLookup[  11      ]:=     330
  compassLookup[  12      ]:=     331
  compassLookup[  13      ]:=     332
  compassLookup[  14      ]:=     333
  compassLookup[  15      ]:=     334
  compassLookup[  16      ]:=     335
  compassLookup[  17      ]:=     336
  compassLookup[  18      ]:=     337
  compassLookup[  19      ]:=     338
  compassLookup[  20      ]:=     340
  compassLookup[  21      ]:=     341
  compassLookup[  22      ]:=     343
  compassLookup[  23      ]:=     345
  compassLookup[  24      ]:=     346
  compassLookup[  25      ]:=     348
  compassLookup[  26      ]:=     349
  compassLookup[  27      ]:=     351
  compassLookup[  28      ]:=     352
  compassLookup[  29      ]:=     354
  compassLookup[  30      ]:=     356
  compassLookup[  31      ]:=     357
  compassLookup[  32      ]:=     359
  compassLookup[  33      ]:=     0
  compassLookup[  34      ]:=     1
  compassLookup[  35      ]:=     2
  compassLookup[  36      ]:=     3
  compassLookup[  37      ]:=     4
  compassLookup[  38      ]:=     5
  compassLookup[  39      ]:=     6
  compassLookup[  40      ]:=     7
  compassLookup[  41      ]:=     8
  compassLookup[  42      ]:=     9
  compassLookup[  43      ]:=     10
  compassLookup[  44      ]:=     11
  compassLookup[  45      ]:=     13
  compassLookup[  46      ]:=     15
  compassLookup[  47      ]:=     18
  compassLookup[  48      ]:=     20
  compassLookup[  49      ]:=     21
  compassLookup[  50      ]:=     23
  compassLookup[  51      ]:=     25
  compassLookup[  52      ]:=     27
  compassLookup[  53      ]:=     29
  compassLookup[  54      ]:=     31
  compassLookup[  55      ]:=     32
  compassLookup[  56      ]:=     33
  compassLookup[  57      ]:=     34
  compassLookup[  58      ]:=     36
  compassLookup[  59      ]:=     38
  compassLookup[  60      ]:=     40
  compassLookup[  61      ]:=     42
  compassLookup[  62      ]:=     44
  compassLookup[  63      ]:=     45
  compassLookup[  64      ]:=     46
  compassLookup[  65      ]:=     47
  compassLookup[  66      ]:=     49
  compassLookup[  67      ]:=     51
  compassLookup[  68      ]:=     53
  compassLookup[  69      ]:=     55
  compassLookup[  70      ]:=     56
  compassLookup[  71      ]:=     59
  compassLookup[  72      ]:=     61
  compassLookup[  73      ]:=     63
  compassLookup[  74      ]:=     65
  compassLookup[  75      ]:=     66
  compassLookup[  76      ]:=     67
  compassLookup[  77      ]:=     68
  compassLookup[  78      ]:=     69
  compassLookup[  79      ]:=     70
  compassLookup[  80      ]:=     71
  compassLookup[  81      ]:=     73
  compassLookup[  82      ]:=     76
  compassLookup[  83      ]:=     77
  compassLookup[  84      ]:=     79
  compassLookup[  85      ]:=     81
  compassLookup[  86      ]:=     83
  compassLookup[  87      ]:=     85
  compassLookup[  88      ]:=     87
  compassLookup[  89      ]:=     89
  compassLookup[  90      ]:=     90
  compassLookup[  91      ]:=     91
  compassLookup[  92      ]:=     92
  compassLookup[  93      ]:=     93
  compassLookup[  94      ]:=     95
  compassLookup[  95      ]:=     96
  compassLookup[  96      ]:=     98
  compassLookup[  97      ]:=     101
  compassLookup[  98      ]:=     103
  compassLookup[  99      ]:=     105
  compassLookup[  100     ]:=     106
  compassLookup[  101     ]:=     108
  compassLookup[  102     ]:=     110
  compassLookup[  103     ]:=     112
  compassLookup[  104     ]:=     113
  compassLookup[  105     ]:=     115
  compassLookup[  106     ]:=     116
  compassLookup[  107     ]:=     118
  compassLookup[  108     ]:=     120
  compassLookup[  109     ]:=     121
  compassLookup[  110     ]:=     122
  compassLookup[  111     ]:=     123
  compassLookup[  112     ]:=     124
  compassLookup[  113     ]:=     125
  compassLookup[  114     ]:=     127
  compassLookup[  115     ]:=     128
  compassLookup[  116     ]:=     130
  compassLookup[  117     ]:=     131
  compassLookup[  118     ]:=     133
  compassLookup[  119     ]:=     135
  compassLookup[  120     ]:=     136
  compassLookup[  121     ]:=     138
  compassLookup[  122     ]:=     140
  compassLookup[  123     ]:=     142
  compassLookup[  124     ]:=     143
  compassLookup[  125     ]:=     145
  compassLookup[  126     ]:=     146
  compassLookup[  127     ]:=     148
  compassLookup[  128     ]:=     149
  compassLookup[  129     ]:=     151
  compassLookup[  130     ]:=     152
  compassLookup[  131     ]:=     154
  compassLookup[  132     ]:=     156
  compassLookup[  133     ]:=     158
  compassLookup[  134     ]:=     159
  compassLookup[  135     ]:=     160
  compassLookup[  136     ]:=     162
  compassLookup[  137     ]:=     163
  compassLookup[  138     ]:=     165
  compassLookup[  139     ]:=     166
  compassLookup[  140     ]:=     167
  compassLookup[  141     ]:=     169
  compassLookup[  142     ]:=     170
  compassLookup[  143     ]:=     171
  compassLookup[  144     ]:=     173
  compassLookup[  145     ]:=     174
  compassLookup[  146     ]:=     176
  compassLookup[  147     ]:=     178
  compassLookup[  148     ]:=     180
  compassLookup[  149     ]:=     181
  compassLookup[  150     ]:=     183
  compassLookup[  151     ]:=     184
  compassLookup[  152     ]:=     185
  compassLookup[  153     ]:=     186
  compassLookup[  154     ]:=     187
  compassLookup[  155     ]:=     189
  compassLookup[  156     ]:=     190
  compassLookup[  157     ]:=     191
  compassLookup[  158     ]:=     193
  compassLookup[  159     ]:=     194
  compassLookup[  160     ]:=     196
  compassLookup[  161     ]:=     198
  compassLookup[  162     ]:=     199
  compassLookup[  163     ]:=     201
  compassLookup[  164     ]:=     203
  compassLookup[  165     ]:=     204
  compassLookup[  166     ]:=     205
  compassLookup[  167     ]:=     206
  compassLookup[  168     ]:=     207
  compassLookup[  169     ]:=     208
  compassLookup[  170     ]:=     209
  compassLookup[  171     ]:=     210
  compassLookup[  172     ]:=     211
  compassLookup[  173     ]:=     212
  compassLookup[  174     ]:=     213
  compassLookup[  175     ]:=     214
  compassLookup[  176     ]:=     216
  compassLookup[  177     ]:=     217
  compassLookup[  178     ]:=     218
  compassLookup[  179     ]:=     219
  compassLookup[  180     ]:=     221
  compassLookup[  181     ]:=     222
  compassLookup[  182     ]:=     224
  compassLookup[  183     ]:=     225
  compassLookup[  184     ]:=     226
  compassLookup[  185     ]:=     227
  compassLookup[  186     ]:=     227
  compassLookup[  187     ]:=     228
  compassLookup[  188     ]:=     229
  compassLookup[  189     ]:=     230
  compassLookup[  190     ]:=     231
  compassLookup[  191     ]:=     232
  compassLookup[  192     ]:=     233
  compassLookup[  193     ]:=     233
  compassLookup[  194     ]:=     234
  compassLookup[  195     ]:=     235
  compassLookup[  196     ]:=     236
  compassLookup[  197     ]:=     236
  compassLookup[  198     ]:=     237
  compassLookup[  199     ]:=     238
  compassLookup[  200     ]:=     239
  compassLookup[  201     ]:=     240
  compassLookup[  202     ]:=     241
  compassLookup[  203     ]:=     241
  compassLookup[  204     ]:=     242
  compassLookup[  205     ]:=     243
  compassLookup[  206     ]:=     244
  compassLookup[  207     ]:=     244
  compassLookup[  208     ]:=     245
  compassLookup[  209     ]:=     246
  compassLookup[  210     ]:=     247
  compassLookup[  211     ]:=     247
  compassLookup[  212     ]:=     248
  compassLookup[  213     ]:=     249
  compassLookup[  214     ]:=     249
  compassLookup[  215     ]:=     250
  compassLookup[  216     ]:=     251
  compassLookup[  217     ]:=     251
  compassLookup[  218     ]:=     252
  compassLookup[  219     ]:=     253
  compassLookup[  220     ]:=     253
  compassLookup[  221     ]:=     254
  compassLookup[  222     ]:=     254
  compassLookup[  223     ]:=     255
  compassLookup[  224     ]:=     255
  compassLookup[  225     ]:=     256
  compassLookup[  226     ]:=     256
  compassLookup[  227     ]:=     257
  compassLookup[  228     ]:=     257
  compassLookup[  229     ]:=     258
  compassLookup[  230     ]:=     258
  compassLookup[  231     ]:=     259
  compassLookup[  232     ]:=     259
  compassLookup[  233     ]:=     260
  compassLookup[  234     ]:=     260
  compassLookup[  235     ]:=     260
  compassLookup[  236     ]:=     261
  compassLookup[  237     ]:=     261
  compassLookup[  238     ]:=     261
  compassLookup[  239     ]:=     261
  compassLookup[  240     ]:=     262
  compassLookup[  241     ]:=     262
  compassLookup[  242     ]:=     262
  compassLookup[  243     ]:=     263
  compassLookup[  244     ]:=     263
  compassLookup[  245     ]:=     263
  compassLookup[  246     ]:=     264
  compassLookup[  247     ]:=     264
  compassLookup[  248     ]:=     264
  compassLookup[  249     ]:=     265
  compassLookup[  250     ]:=     265
  compassLookup[  251     ]:=     265
  compassLookup[  252     ]:=     266
  compassLookup[  253     ]:=     266
  compassLookup[  254     ]:=     267
  compassLookup[  255     ]:=     267
  compassLookup[  256     ]:=     267
  compassLookup[  257     ]:=     268
  compassLookup[  258     ]:=     268
  compassLookup[  259     ]:=     268
  compassLookup[  260     ]:=     269
  compassLookup[  261     ]:=     269
  compassLookup[  262     ]:=     269
  compassLookup[  263     ]:=     270
  compassLookup[  264     ]:=     270
  compassLookup[  265     ]:=     270
  compassLookup[  266     ]:=     271
  compassLookup[  267     ]:=     271
  compassLookup[  268     ]:=     271
  compassLookup[  269     ]:=     272
  compassLookup[  270     ]:=     272
  compassLookup[  271     ]:=     272
  compassLookup[  272     ]:=     273
  compassLookup[  273     ]:=     273
  compassLookup[  274     ]:=     273
  compassLookup[  275     ]:=     274
  compassLookup[  276     ]:=     274
  compassLookup[  277     ]:=     274
  compassLookup[  278     ]:=     275
  compassLookup[  279     ]:=     275
  compassLookup[  280     ]:=     275
  compassLookup[  281     ]:=     276
  compassLookup[  282     ]:=     276
  compassLookup[  283     ]:=     276
  compassLookup[  284     ]:=     277
  compassLookup[  285     ]:=     277
  compassLookup[  286     ]:=     277
  compassLookup[  287     ]:=     278
  compassLookup[  288     ]:=     278
  compassLookup[  289     ]:=     278
  compassLookup[  290     ]:=     279
  compassLookup[  291     ]:=     279
  compassLookup[  292     ]:=     279
  compassLookup[  293     ]:=     280
  compassLookup[  294     ]:=     280
  compassLookup[  295     ]:=     280
  compassLookup[  296     ]:=     281
  compassLookup[  297     ]:=     281
  compassLookup[  298     ]:=     281
  compassLookup[  299     ]:=     282
  compassLookup[  300     ]:=     282
  compassLookup[  301     ]:=     282
  compassLookup[  302     ]:=     283
  compassLookup[  303     ]:=     283
  compassLookup[  304     ]:=     283
  compassLookup[  305     ]:=     284
  compassLookup[  306     ]:=     284
  compassLookup[  307     ]:=     284
  compassLookup[  308     ]:=     285
  compassLookup[  309     ]:=     285
  compassLookup[  310     ]:=     285
  compassLookup[  311     ]:=     286
  compassLookup[  312     ]:=     286
  compassLookup[  313     ]:=     286
  compassLookup[  314     ]:=     287
  compassLookup[  315     ]:=     287
  compassLookup[  316     ]:=     287
  compassLookup[  317     ]:=     288
  compassLookup[  318     ]:=     288
  compassLookup[  319     ]:=     288
  compassLookup[  320     ]:=     289
  compassLookup[  321     ]:=     289
  compassLookup[  322     ]:=     290
  compassLookup[  323     ]:=     290
  compassLookup[  324     ]:=     291
  compassLookup[  325     ]:=     291
  compassLookup[  326     ]:=     292
  compassLookup[  327     ]:=     292
  compassLookup[  328     ]:=     293
  compassLookup[  329     ]:=     293
  compassLookup[  330     ]:=     294
  compassLookup[  331     ]:=     294
  compassLookup[  332     ]:=     295
  compassLookup[  333     ]:=     295
  compassLookup[  334     ]:=     296
  compassLookup[  335     ]:=     296
  compassLookup[  336     ]:=     297
  compassLookup[  337     ]:=     297
  compassLookup[  338     ]:=     298
  compassLookup[  339     ]:=     298
  compassLookup[  340     ]:=     299
  compassLookup[  341     ]:=     299
  compassLookup[  342     ]:=     300
  compassLookup[  343     ]:=     300
  compassLookup[  344     ]:=     301
  compassLookup[  345     ]:=     301
  compassLookup[  346     ]:=     302
  compassLookup[  347     ]:=     302
  compassLookup[  348     ]:=     303
  compassLookup[  349     ]:=     304
  compassLookup[  350     ]:=     305
  compassLookup[  351     ]:=     306
  compassLookup[  352     ]:=     307
  compassLookup[  353     ]:=     308
  compassLookup[  354     ]:=     309
  compassLookup[  355     ]:=     310
  compassLookup[  356     ]:=     311
  compassLookup[  357     ]:=     312
  compassLookup[  358     ]:=     313
  compassLookup[  359     ]:=     314
  compassLookup[  360     ]:=     315    