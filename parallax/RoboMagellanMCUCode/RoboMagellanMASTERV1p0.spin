'' File: RoboMagellanMASTERV-p-.spin
'' For Caltech RoboMagellan 2008, code for MASTER MCU only.
''     MASTER-has 2 ribbon cables, connects to CPU
''     SLAVE-has 1 larger ribbon cable, connects to MASTER MCU
''4/25/2008                                                                                    
{{history: 1.0 file copied from balancingBotPEKv4p7.spin, modified UNTESTED

Known issues: UNTESETD

                   
   PIN   Purpose    Input  Output
    0     
    1     
    2     
    3     
    4     
    5     
    6    
    7                         
    8   motor                X
    9   motor                X
    10  motor                X
    11  motor                X
    12  compass  
    13  compass                             
    14  compass   
    15   LED                 X
    16     
    17        
    18     
    19             
    20     
    21    
    22     
    23     
    24     
    25     
    26     
    27     
    
  COG usage:
     0: main cog
     1: terminal window/DAQ/graph
     2: UART-MCU
     3: UART-CPU
     4: PWM (servos, motor controllers)
     5: motor velocity (PID) calculator
     6: compass
     7:       
    
                                                 }}
VAR
    long motorLeftFront   'desired speed -100 to 100 indicating %
    long motorLeftBack
    long motorRightBack
    long motorRightFront
    
    long heartBeat  'for blinking the LED
    long stack[60] 'for motor cog
    long stack3[30] 'for gyro PWM reading cog
    long stack4[30] 'for filter cog
    long stack5[120] 'for motor PID control
    long timer
    

    'variables for turning code
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

    'variables updated by SLAVE-MCU
    long SLVencoderLFposition 
    long SLVencoderLBposition
    long SLVencoderRBposition
    long SLVencoderRFposition

    long SLVisConnected        '0 if MCU-MCU connection is broken
    
    
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz

    'pins
    _LED = 15            
    _motLF = 8
    _motLB = 9
    _motRB = 10
    _motRF = 11
    _uartPCtx =    4 
    _uartPCrx =    3
    _uartSLVtx =   1   'CHANGE THESE
    _uartSLVrx =   2   'CHANGE THESE

    _HM55EN= 19
    _HM55CL= 20      
    _HM55DA= 21
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
    _cmdStop=999
    '_scanResolution=10
    

    _NEXT_TIME_BYTE=254

    '_kP =40'10'12 'for 7.2V
    '_kD =-5'5'7  'for 7.2V
    '_kI = 0

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
PUB main  |temp
    
    INITIALIZATION
    {{repeat                     'basic serial port test, use hyper terminal
      temp:=uartPC.rx
      if temp <>0
        term.dec(temp)
        term.out($0d)
        'uartPC.tx(temp+1)      }}
    'repeat
    '  term.dec(compass.theta)
    '  waitcnt(cnt+clkfreq/5)
    '  term.out($0d)
    'repeat
     ' term.dec(compass.theta*10/227)
      
      'term.out($0d)
      'term.cls
   
    
    TURNTOANGLE (180)
    term.str(string("done turning"))
    repeat
      term.dec(compass.theta*10/227)
      
      term.out($0d)
      pausems(100)
      term.cls
    'repeat
    repeat
      
      'term.cls
      TxRx
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
PUB v883motorPWMTest| refreshPerSec,PWMValue,cntStart,cntFinish,temp,lastPosRF, currentPosRF,rpmRF,lastPosLF, currentPosLF,rpmLF
 PWMValue:=1500  
 refreshPerSec:=10
 repeat
    temp:=cnt+clkfreq/refreshPerSec
     
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

    currentPosRF:=SLVencoderRFposition
    currentPosLF:=SLVencoderLFposition
    rpmRF:= (currentPosRF-lastPosRF)*refreshPerSec*60/24/32
    rpmLF:= (currentPosLF-lastPosLF)*refreshPerSec*60/24/32
    term.cls
    term.str(string("PWM value: "))
    term.dec(PWMValue)
    term.out($0d)
    term.dec(ina[23])
    term.out($0d)
    term.str(string("posLF: "))
    term.dec(currentPosLF)
    term.str(string(" posRF: "))
    term.dec(currentPosRF)
    term.out($0d)
    term.str(string("rpmLF: "))
    term.dec(rpmLF)
    term.str(string(" rpmRF: "))
    term.dec(rpmRF)
    term.out($0d)
    term.str(string("countsLF: "))
    term.dec(currentPosLF-lastPosLF)
    term.str(string("countsRF: "))
    term.dec(currentPosRF-lastPosRF)
    term.out($0d)
    term.str(string("MPH of LF(100): "))   '1mph = 88 fpm
    term.dec(rpmLF*314/88)
    term.out($0d)
    term.str(string("MPH of RF(100): "))   '1mph = 88 fpm
    term.dec(rpmRF*314/88)
    term.out($0d)
    lastPosRF:=currentPosRF
    lastPosLF:=currentPosLF
    waitcnt(temp)

PUB v883motorPWMTestPSX| motorLeftRamped,ramp, motorRightRamped,refreshPerSec,cntStart,cntFinish,temp,lastPosR, currentPosR,rpmR,lastPosL, currentPosL,rpmL
 
 refreshPerSec:=5
 ramp:=80
 motorRightRamped:=0
 motorLeftRamped:=0
 repeat
    temp:=cnt+clkfreq/refreshPerSec

    
    navigatePSX                
    motorRightRamped:= (ramp*motorRightRamped+ (100-ramp)*motorRightFront)/100
    motorLeftRamped:= (ramp*motorLeftRamped+ (100-ramp)*motorLeftFront)/100    
    setMotorLeftFront(motorLeftRamped)
    setMotorLeftBack(motorLeftRamped)
    setMotorRightBack(motorRightRamped) 
    setMotorRightFront(motorRightRamped) 


    currentPosR:=SLVencoderRFposition
    currentPosL:=SLVencoderLFposition
    rpmR:= (currentPosR-lastPosR)*refreshPerSec*60/24/32
    rpmL:= (currentPosL-lastPosL)*refreshPerSec*60/24/32
    term.cls
    term.dec(psx.getID)
    term.out($0d)
    term.str(string("motorLeft: "))
    term.dec(motorLeftRamped)
    term.str(string(" motorRight: "))
    term.dec(motorRightRamped)
    term.out($0d)
    term.str(string("posL: "))
    term.dec(currentPosL)
    term.str(string(" posR: "))
    term.dec(currentPosR)
    term.out($0d)
    term.str(string("rpmL: "))
    term.dec(rpmL)
    term.str(string(" rpmR: "))
    term.dec(rpmR)
    term.out($0d)
    term.str(string("countsPerSL: "))
    term.dec((currentPosL-lastPosL)*refreshPerSec)
    term.str(string("countsPerSR: "))
    term.dec((currentPosR-lastPosR)*refreshPerSec)
    term.out($0d)
    term.str(string("MPH of L(100): "))   '1mph = 88 fpm
    term.dec(rpmL*314/88)
    term.out($0d)
    term.str(string("MPH of R(100): "))   '1mph = 88 fpm
    term.dec(rpmR*314/88)
    term.out($0d)
    lastPosR:=currentPosR
    lastPosL:=currentPosL
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

    
    

'receives 3 bytes: start, command, data    
PUB TxRx | cmdByte , counter,rx1,rx2,rx3,angle1,angle2
    'receive data
    counter :=0
    repeat while (uartPC.rxtime(1000) <> _startByte)  'wait for start byte
      'term.cls
      motorLeftFront:=motorRightFront:=0
      'term.str(string("waiting for byte..."))
      'term.dec(counter++)
    cmdByte :=uartPC.rx
    case  cmdByte                                   'get and parse command byte
      _cmdSetSpeed:
        term.str(string("set speed: "))
        rx1:= uartPC.rx-100 
        rx2:=uartPC.rx-100 
        rx3:=uartPC.rx
        if rx3 <> _stopByte
          term.str(string("invalid data packet"))
        else
          term.dec(rx1)
          term.str(string(" "))
          term.dec(rx2)
          motorLeftFront:=rx1
          motorRightFront:=rx2
      _cmdTurnAbs:
          term.str(string("turn abs: "))
          angle1:=uartPC.rx
          angle2:=uartPC.rx
          if rx3 <> _stopByte
            term.str(string("invalid data packet"))
          else
            angle1:=angle1+angle2
            term.dec(angle1)
            term.str(string(" degrees"))
            uartPC.tx(_cmdTurnAbs)   'confirm command
            TURNTOANGLE(angle1)
            uartPC.tx(_cmdAck)       'done turning
      _cmdTurnRel:   'fill in
           term.str(string("turn rel: "))
      _cmdStop:
          term.str(string("stop: "))
          
                                
          
          
      other:
        term.str(string("invalid command"))
    term.out($0d)  

    'transmit data    
    '
    uartPC.tx(_stopByte)
      
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
    
    LEDon
    dira[_LED]~~
    
    term.start(31,30)     'start terminal COG
    term.str(string("starting up"))
    'graph.start(14,15,%0010,9600)                              ' Rx,Tx, Mode, Baud   COG
        
    uartPC.start(_uartPCrx,_uartPCtx, %0011 , 9600)'(rxpin, txpin, mode, baudrate) : okay
    uartSLV.start(_uartSLVrx,_uartSLVtx, %0011 , 9600)'(rxpin, txpin, mode, baudrate) : okay       
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
    servos.set(_motRF,1500)
    servos.start     'start servo COG
    '1000   150k= 90deg inc 17
    '1450...23k = 90deg inc 1
    '1485...12k = 90deg inc 1
    '2000...140 = 90deg
    
    'acc.start(0,1,2)       'start(CS_,DIO_,CLK_):okay does not use own cog, just inits pin #'s                   
    psx.start(24,25,26,27) 'ddat, cmd, att, clk
    term.out($0d)
    term.str(string("cog #(0-7): "))
    term.dec(cognew(PIDmotorLoop(0), @stack5[0]))  'start motor PID control loop COG
    term.out($0d)
    'term.str(string("cog #(0-7): "))      
    'term.dec(cognew(filterLoop,@stack4[0])) 'start filter calculating COG
    
    'term.dec(cognew(readGyroLoop, @stack3[0])) 'start gyro PWM COG            
    
    
    term.out($0d)
    term.str(string("done"))
    pausems(1000)
         
    term.cls       
    LEDoff

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
      term.out($0d)
     
      term.out($0d)
      term.dec((delay-cnt)/80)
      term.str(string("us left"))    }}
      
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
          return
     
     'get car to start turning
     REPEAT WHILE (GetAngFromDesired > _RealNEARTARGET)
          if (stopTurn <> 0)
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
          return
     
     'inch till within deadBand
 
       
       if ||GETANGFROMDESIRED > _deadBand
         REPEAT UNTIL ||GETANGFROMDESIRED =< _deadBand
              if (stopTurn <> 0)
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

PUB GETCURRENTANG   |ang1, ang2, ang3, ang4, sum
                'takes 100 ms
    sum := 0
                
        ang1 := compass.theta*10/227
        pausems(33)
        ang2 := compass.theta*10/227
        pausems(33)
        ang3 := compass.theta*10/227
        pausems(33)
        ang4 := compass.theta*10/227

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
          currentAng := sum/4
          if currentAng < 0
                currentAng := 360 + currentAng
                                  
     else
          sum := ang1+ang2+ang3+ang4
          currentAng := sum/4
          
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