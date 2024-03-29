'' File: RoboMagellanMASTERV-p-.spin
'' For Caltech RoboMagellan 2008, code for MASTER MCU only.
''     MASTER-has 2 ribbon cables, connects to CPU
''     SLAVE-has 1 larger ribbon cable, connects to MASTER MCU
''6/15/2008                                                                                    
{{history: 1.0 file copied from balancingBotPEKv4p7.spin, modified
                MCU-MCU uart tested, works-weird timing thing fixed (hopefully)
                compass reading - works
                MCU-PC uart - should work
                everything else-UNTESTED
                encoder data- successfully received through uartΣ
                PWM-tested, works             
                playstation controller added (new pinout)-tested, works
                PID motor control works: plug encoders in correctly, dark to dark
                v883motorPWMTestPSX can now be used to drive the segway around
                turn code tested on raised platform, works
                BUG FIX: delay in turn code, printStatus method created, everything runs in 7 cogs
                main loop (PIDmotorLoop) uses PSX (adds ~3ms) as top priority -tested, works
                BUG FIX: psx code doesn't clear speed to 0, PIDmotorLoop timer overflow prevented
                emergency timeout disabled, PC uart test notes updated
                ------------------------
                SWITCH TO FINAL PLATFORM
                ------------------------
                work on velocity control
                v883motorPWMTest changed
                most constants changed for RM robot platform, Kd, Kp adjusted, mostly works
                  stuff changed
                                commented out blinkLED, txrxPC
                                commented out txrxPC init
                                uncommented graph init
                                changed PIDmotorLoop parameter from 0 to 1

                compass filtering added , code cleaned up, comments updated
                compass uart added, untested
                compass uart tested, works, all 8 cogs used now (including the turning one)
                PINOUT CHANGED - LED moved from P11 to P18, bumperSwitch added to P11, still need to debounce
                psx code updated to allow controlling using direction pad (Dpad)
                switch debouncing, UNTESTED
                6/5  - bumper switch debouncing tested and works; turning tested and works with changed constants
                new compass lookup table
                add new DeadBand constant
                added compass offset to account for PC/compass north difference   UNTESTED
                6/6 - need to test how wide to make turn deadBand (at 2 now)
                improved COMPASSFILTER
                added PC bumper switch interface
                modified for autolevel delays
                
Known issues:
        timeOverCount should be 0, but it isn't...

                   
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
    12  compassEN            X
    13  compassCLK           X                  
    14  compassDAT    X
    15  motor                X
    16  uartSLVrx     X
    17  uartSLVtx            X
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
     2: UART-MCU
     3: UART-PC
     4: PWM (servos, motor controllers)
     5: motor velocity (PID) calculator
     6: UART-compass
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
    long stack5[220] 'for motor PID control
    
    long timer

    long filteredAngle, rawFilteredAngle
 
    long switchDebounceCounter[2]

    'keeping track of when to send PC compass data
    long compassDataSendCounter

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

    long isUsingPSX

    'for debugging
    long flag
    long timeOverCount

CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
       
    'pins
    _LED = 18
    _bumperSwitch = 11           
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
    _uartCompasstx =   2   
    _uartCompassrx =   3   
    'Compass schematic
' P14 ──│1  6│── +3.3V     P12 = Enable
'         │  ├┴──┴┤  │               P13 = Clock
' P14 ──│2 │ /\ │ 5│── P12       P14 = Data
'         │  │/  \│  │
' VSS ──│3 └────┘ 4│── P13    
    {{segway values
    _motLFullReverse = 1146    'experimentally determined v883 PWM values
    _motLFMinReverse = 1489+20
    _motLFMinForward =  1558-20
    _motLFullForward =  1915
    _motRFullReverse = 1168
    _motRFMinReverse = 1488+20
    _motRFMinForward =  1556-20
    _motRFullForward =  1906   }}
    
    _motLFullReverse = 1000    'experimentally determined v883 PWM values
    _motLFMinReverse = 1480+20
    _motLFMinForward =  1560-20
    _motLFullForward =  2000
    _motRFullReverse =  _motLFullReverse
    _motRFMinReverse =  _motLFMinReverse
    _motRFMinForward =  _motLFMinForward
    _motRFullForward =  _motLFullForward
    
    'for segway
    'encoder has resolution of 24, gearbox has raio of 32, 24*32=768 counts/wheel rev
        '1mp ~= 88 feet per minute, wheel circumference= 3.14*(1 foot) = 3.14 feet
    'for RM robot platform
    'encoder has resolution of 128*4=512 counts/wheel rev
        '1mp ~= 88 feet per minute, wheel circumference= 3.14*(2/3 foot)
        '
    _motMaxSpeed=1060 'counts/second
    
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

    _delayAutoLevel = 201
    _resetAutoLevel = 200

    _NEXT_TIME_BYTE=254                                     

    _switchDebounceThreshold = 5  'at 20Hz
    _compassOffset = 15  'how much larger compass angle is than GPS, MUST BE positive
    
    'compass constants
    _compassDataSendFreq = 10 'in 1/10 Hz

    _RealNearTarget = 10
    _NearTarget = 25                    
    _DeadBand = 2               'degrees within desired b4 stopping
    _DeadBandNum = 2            'times in deadband b4 stopping

    _TurnSpeed = 30
    _SlowTurnSpeed = 15
    _PulseSpeed = 20                'for getting into deadband
    
    _ThresholdAngChange = 5     '5 degrees per 200 ms
    _MaxAngChange = 10          
    _MotorChangeStep = 5       'max is 100
    

OBJ 'objects used in this program-code must be in same directory
    term:   "PC_Interface"
    PDAQ : "PLX-DAQ"
    acc:    "H48C Tri-Axis AccelerometerNoNewCog"       
    psx:    "ps2ControllerV1p1" '"ps2ControllerV1p2d"
    servos: "Servo32"
    uartPC:   "FullDuplexSerial"
    uartSLV: "FullDuplexSerial"
    uartCompass: "FullDuplexSerial"   
    graph:  "FullDuplexSerial"
    compass:    "HM55B Compass Module Asm"
    
PUB main  |temp  ,lowpass
   
    INITIALIZATION(0)

'This function should be called several times per second
  'to display all important information     
PUB printStatus
      term.cls
      term.str(string("timeOverCount: "))
      term.dec(timeOverCount)
      term.out($0d)
      if(PCisConnected<>0)
        term.str(string("PC: ON "))
      else
        term.str(string("PC: -- "))
        
      if(SLVisConnected<>0)
        term.str(string("SLV: ON "))
      else
        term.str(string("SLV: -- "))

      if(isUsingPSX<>0)
        term.str(string("PSX "))
      else
        term.str(string(" -  "))
      
      if(isTurning <>0)
        term.str(string("TURNING"))
      else
        term.str(string("  ---  "))
      term.out($0d)

      if (bumperSwitchPressed)
        term.str(string("bumper ON"))
      term.out($0d)
      term.str(string("compass: raw ="))
      term.dec(compassLookUp[compass.theta*10/227])
      term.str(string(" filt&conv ="))
      term.dec(filteredAngle)
      'term.str(string(" "))
      'term.dec(rawfilteredangle/100)
      
      term.out($0d)

      term.str(string("    LF  LB  RB  RF"))
      term.out($0d)
      term.str(string("Enc: "))
      term.dec(SLVencoderLFposition)
      term.str(string(" "))
      term.dec(SLVencoderLBposition)
      term.str(string(" "))
      term.dec(SLVencoderRBposition)
      term.str(string(" "))
      term.dec(SLVencoderRFposition)
      term.out($0d)

      term.str(string("motor: "))
      term.dec(motorLeftFront)
      term.str(string(" "))
      term.dec(motorLeftBack)
      term.str(string(" "))
      term.dec(motorRightBack)
      term.str(string(" "))
      term.dec(motorRightFront)
      term.out($0d)

      term.str(string("other messages: "))
      term.out($0d)


'tests v883 and encoders by varying the power (no velocity control)
  'from data from the mouse; left/right click the left/right sides of
  'the terminal to inc/dec the PWM value        
PUB v883motorPWMTest| refreshPerSec,PWMValue,cntStart,cntFinish,temp,lastPos[4], currentPos[4],rpm[4] ,i
 PWMValue:=1500  
 refreshPerSec:=20
 repeat i from 0 to 3    'initialize variables
   lastPos[i]:=0
   currentPos[i]:=0
   rpm[i]:=0
 repeat
    temp:=cnt+clkfreq/refreshPerSec
    TxRxMCU
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
      rpm[i]:= (currentPos[i]-lastPos[i])*refreshPerSec*60/128/4
    
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
      term.dec(rpm[i]*314*2/3/88)
      term.str(string(" "))
    term.out($0d)
    
    term.out($0d)
    repeat i from 0 to 3
      lastPos[i]:=currentPos[i]
    
    waitcnt(temp)

'tests v883 and encoders using the playstation controller and
  'velocity control        
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
    term.str(string("PSX ID: "))
    term.dec(psx.getID)
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
PUB setMotorLeftBack(val)
    if ||val < 3
      val:=0
    val<#=100                
    val#>=-100
    if(val==0)  'stopped
      servos.set(_motLB,(_motLFMinReverse+_motLFMinForward)/2)
    elseif val< 0 'reverse
      servos.set(_motLB,_motLFMinReverse -(_motLFMinReverse-_motLFullReverse)*-1*val/100)
    else 'forward
      servos.set(_motLB,(_motLFullForward-_motLFMinForward)*val/100+_motLFMinForward)
PUB setMotorRightBack(val)
    if ||val < 3
      val:=0
    val<#=100                
    val#>=-100
    if(val==0)  'stopped
      servos.set(_motRB,(_motRFMinReverse+_motRFMinForward)/2)
    elseif val< 0 'reverse
      servos.set(_motRB,_motRFMinReverse -(_motRFMinReverse-_motRFullReverse)*-1*val/100)
    else 'forward
      servos.set(_motRB,(_motRFullForward-_motRFMinForward)*val/100+_motRFMinForward)   
    
PUB setMotorRightFront(val)
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
    

 
'Manages communication between master and slave MCU's;
  'currently only one way (receives only)       
  'receives these bytes: start, <encoder data>, stop
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
       return 1
PUB TxRxMCUTimeoutCheck(condition)
    if (condition)'timeout
       SLVtimeoutCount++
       if SLVtimeoutCount>20
         SLVisConnected :=0 'no longer connected
       return 1
    return 0
    
'Manages communication between PC and master MCU
  'bidirectional, very complicated
  'receives these bytes: start, command, <data>, stop    
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
    if (bumperSwitchPressed)
      uartPC.tx(_startByte)
      uartPC.tx(_cmdBumperSwitchOn)
      uartPC.tx(_stopByte)  
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
        term.out($0d)  
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
PUB INITIALIZATION(debugGraph)
    'initialize variables
    compassDataSendCounter:=0
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

    'initalize objects now
    'start terminal (prints to propterminal.exe)  
    term.start(31,30)     
    term.str(string("starting up"))
    if debugGraph==1
      graph.start(_uartPCrx,_uartPCtx,%0010,9600)  ' Rx,Tx, Mode, Baud, (use with serialplot.java for debugging)
    else
      'test with 9600 8 N 1
      'update 5/19/08 actually 115200 8 N 2...   
      uartPC.start(_uartPCrx,_uartPCtx, %0011 , 115200)'(rxpin, txpin, mode, baudrate) : okay
    uartSLV.start(_uartSLVrx,_uartSLVtx, %0000 , 115200)'(rxpin, txpin, mode, baudrate) : okay
    ''uart mode bits:    
      '' mode bit 0 = invert rx
      '' mode bit 1 = invert tx
      '' mode bit 2 = open-drain/source tx
      '' mode bit 3 = ignore tx echo on rx

    'initialize compass
    compass.start(_HM55EN,_HM55CL,_HM55DA )'start(EnablePin,ClockPin,DataPin):okay
    filteredAngle:=compassLookUp[compass.theta*10/227]   
    heading := compass.theta*10/227
    angleCount := 0
    initialHeading := heading  

    'initalize servo/PWM controller
    servos.set(_motLF,1500)
    servos.set(_motLB,1500)
    servos.set(_motRB,1500)
    servos.set(_motRF,1500)
    servos.start     'start servo

    'initialize playstation controller (doesn't use another COG)           
    psx.start(27,26,25,24) 'ddat, cmd, att, clk
    
    uartCompass.start(_uartCompassrx,_uartCompasstx, %0011 , 115200)'(rxpin, txpin, mode, baudrate) : okay 

    'term.dec(cognew(PIDmotorLoop(0), @stack5[0]))  'start motor PID control loop COG
    'v883motorPWMTestPSX

    term.out($0d)
    term.str(string("cog #(0-7): "))
    term.dec(cognew(pausems(1), @stack5[0]))    
    term.out($0d)
    term.str(string("done"))
    pausems(1000)
         
    term.cls       
    LEDoff
    
    PIDmotorLoop(debugGraph)
    'v883motorPWMTest
    'PIDmotorLoop(1)
    term.out($0d)
    'term.str(string("cog #(0-7): "))      
   
    
    

'blinks LED using counter    
PUB blinkLED
    if heartBeat == 0
      LEDon
      heartBeat:=9
      printStatus
    else
      LEDoff
      heartBeat -= 1

    

PUB LEDon
    outa[_LED]~~
PUB LEDoff
    outa[_LED]~
    
'PID motor control with v883 motor controllers-
  'this function could be simplified with arrays of length 4
  'updates motor speed based on motorLeft and motorRight, encoder data
  'output = kP*position + kD*velocity
  'd(output) = kP*velocity + kD*acceleration
  'output= output+ d(output)= output + kP*velocity + kD*acceleration
PUB PIDmotorLoop(debugGraph) | motorRFRamped, motorLFRamped, ramp,avgVelLF,avgVelRF,freq, delay,motorLeftFrontSpeed,motorRightFrontSpeed,errorLF,errorRF , kmPrf,kmDrf,kmPlf,kmDlf ,velLF,lastVelLF,lastVelRF, velRF, accLF, accRF,encCountLF, encCountRF,valLF, valRF,temp, XXXXXX,motorRBRamped, motorLBRamped,avgVelLB,avgVelRB,motorLeftBackSpeed,motorRightBackSpeed,errorLB,errorRB , kmPrb,kmDrb,kmPlb,kmDlb ,velLB,lastVelLB,lastVelRB, velRB, accLB, accRB,encCountLB, encCountRB,valLB, valRB
    '1.2mph=33.6 wheel rpm = 430 encoder counts/second   UPDATE THESE from segway values
    'at 24V, 80 cnts/sample
    '20Hz ~21 counts/sample
    freq:=20 'Hz
    ramp:=80

    'initalize constants (adjustable)
    kmPrf:=4  'proportionality gain
    kmDrf:=-2   'derivative gain (make negative)
    kmPlf:=4
    kmDlf:=-2

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
      COMPASSFILTER
      if debugGraph <> 1     'if not debugging, print status and get data from PC
        blinkLED
        TxRxPC  
      TxRxMCU
      'term.str(string("compass(raw,filt): "))
      'term.dec(compassLookUp[compass.theta*10/227])
      'term.str(string(" "))
      'term.dec(filteredAngle)
      'term.out($0d)
      
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
      temp:=-1*SLVencoderLFposition          'update position counter and current velocity
      velLF:=encCountLF-temp
      encCountLF:=temp
      temp:=-1*SLVencoderLBposition          
      velLB:=encCountLB-temp
      encCountLB:=temp      
      temp:=-1*SLVencoderRBposition
      velRB:=encCountRB-temp
      encCountRB:=temp  
      temp:=-1*SLVencoderRFposition
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
      if(delay<cnt)
        timeOverCount++
      else
        waitcnt(delay+80_000)                        'wait to achieve desired update frequency

PUB bumperSwitchPressed
    if ina[_bumperSwitch] == 0 'replace with <> 0 if wired other way around
      switchDebounceCounter[0]++
      if switchDebounceCounter[0] > _switchDebounceThreshold
        switchDebounceCounter[1]:=0
        return true
      return false
    else
      switchDebounceCounter[1]++
      if switchDebounceCounter[1] > _switchDebounceThreshold
        switchDebounceCounter[0]:=0
        return false
      return true
      
PUB pausems(ms)
  waitcnt(cnt+clkfreq/1000*ms)


'------------------------------ COMPASS code ----------------------------------
'------ Author: Dingchao Lu dingchao@caltech.edu

'low pass filter (should be called at ~20Hz), updates rawFilteredAngle, filteredAngle
  'WARNING: the filtered angle responds very slowly (~1 sec) to changes, use accordingly
  'sends compass data to PC at rate _compassDataSendFreq
  'data sent: startByte, angle1, angle2, stopByte where angle = angle1+angle2
  'rawFilteredAngle is untruncated, filteredAngle is truncated, in degrees
PUB COMPASSFILTER |newAngle,oldAngle, sum, lowPassConst
     lowPassConst := 90 'should range from 0 to 100, weight on old term        
    
     newAngle := compassLookup[compass.theta*10/227]*100                 'copy raw angle    
     oldAngle:=rawfilteredAngle                           'copy raw filtered angle
        
     'handles special case for angs close to 0, 360   
     if ||(oldAngle-newAngle)> 200*100
        if oldAngle > 200*100 
          oldAngle := oldAngle - 360*100
        if newAngle > 200*100 
          newAngle := newAngle - 360*100       
         
        oldAngle := ( (100-lowPassConst) * newAngle + lowPassConst* oldAngle  )/100
        if oldAngle < 0
          oldAngle := 360*100  + oldAngle
                                  
     else
        oldAngle := ( (100-lowPassConst) * newAngle + lowPassConst* oldAngle  )/100   
        
    rawFilteredAngle:=oldAngle   'update global variables
    filteredAngle:=rawFilteredAngle/100
    
    'now send data out to PC if necessary
    compassDataSendCounter++   'increment counter
    filteredAngle:=convertAngleforPC(filteredAngle) 'convert angle for GPS
    if(compassDataSendCounter==20*10/_compassDataSendFreq)   'if counter has reached desired count
      uartCompass.tx(_startByte)     'actually send data to PC
      if filteredAngle > 180
        uartCompass.tx(180)
        uartCompass.tx(filteredAngle-180)
      else
        uartCompass.tx(0)
        uartCompass.tx(filteredAngle)
      uartCompass.tx(_stopByte)
      
      compassDataSendCounter:=0   'reset counter
    
PUB convertAngleforPC(angle)
    angle+=(360-_compassOffset)
    if angle>359
      angle-=360
    return angle
PUB convertAnglefromPC(angle)
    angle+=_compassOffset
    if angle>359
      angle-=360
    return angle
PUB TURNTOANGLE (angle)   | inDeadBand
       'turns to the desiredAng, exit anytime by setting stopTurn to non-zero

     stopTurn := 0
     desiredAng := angle 
     'term.cls 
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
   
        
     ''term.str(string("initialAng: "))
     'term.dec(initialAng)
     'term.out($0d)
     'term.str(string("desiredAng: "))
     'term.dec(desiredAng)
     
     'term.cls

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
          'term.cls
         if (angFromDesired > _NearTarget)
            motorLeftFront := turnAngSign * _TurnSpeed
            motorLeftBack:=motorLeftFront
            motorRightFront := - turnAngSign * _TurnSpeed
            motorRightBack:=motorRightFront
            'term.str(string("turning"))
            'term.out($0d)
         else
            motorLeftFront := turnAngSign * _SlowTurnSpeed
            motorLeftBack:=motorLeftFront      
            motorRightFront := - turnAngSign * _SlowTurnSpeed
            motorRightBack:=motorRightFront
            'term.str(string("slowly turning"))
            'term.out($0d)
        'term.str(string("currentAng: "))   
        'term.dec(currentAng)
        'term.out($0d)
        'term.str(string("angFromDesired: "))   
        'term.dec(angFromDesired)
        'term.out($0d)
        
     'stops motors when nearTarget
     
    motorLeftFront := 0
    motorLeftBack:=motorLeftFront 
    motorRightFront := 0
    motorRightBack:=motorRightFront 
          
  
           
     'term.cls
     
     'term.str(string("initialAng: "))   
     'term.dec(initialAng)
     'term.out($0d)
     'term.str(string("currentAng: "))   
     'term.dec(currentAng)
     'term.out($0d)
     'term.str(string("desiredAng: "))
     'term.dec(desiredAng)
     'term.out($0d) 
     'term.str(string("angFromDesired: "))   
     'term.dec(angFromDesired)
     'term.out($0d)
     
     
       if (stopTurn <> 0)
             motorLeftFront := 0
                 motorLeftBack:=motorLeftFront 
              motorRightFront := 0
              motorRightBack:=motorRightFront
              isTurning:=0
          return
     
     'inch till within deadBand
 
      inDeadBand := 0 
       'if ||GETANGFROMDESIRED > _deadBand
      REPEAT UNTIL (||GETANGFROMDESIRED =< _deadBand) AND (inDeadBand => _DeadBandNum)
              if (stopTurn <> 0)
                      motorLeftFront := 0
                        motorLeftBack:=motorLeftFront 
                    motorRightFront := 0
                    motorRightBack:=motorRightFront
                    isTurning:=0
                return
             'term.cls
           if ||angFromDesired =< _deadBand
                inDeadBand := inDeadBand + 1
           else
                inDeadBand := 0               
                
           if (angFromDesired > 0) AND (inDeadBand == 0)
             motorLeftFront := turnAngSign *_PulseSpeed
             motorLeftBack:=motorLeftFront 
             motorRightFront := - turnAngSign *_PulseSpeed
             motorRightBack:=motorRightFront
             
           elseif (angFromDesired < 0) AND (inDeadBand == 0)
             motorLeftFront := - turnAngSign *_PulseSpeed
             motorLeftBack:=motorLeftFront 
             motorRightFront := turnAngSign *_PulseSpeed
             motorRightBack:=motorRightFront   
           'term.str(string("angFromDesired: "))   
           'term.dec(angFromDesired)
           'term.out($0d)
           pausems(50)
           motorLeftFront := 0
           motorLeftBack:=motorLeftFront    
           motorRightFront := 0
           motorRightBack:=motorRightFront 
           
           
    
     'term.str(string("In DeadBand"))
          'term.out($0d)
          'term.str(string("angFromDesired: "))   
           'term.dec(angFromDesired)
           'term.out($0d)
           'term.str(string("currentAng: "))   
          'term.dec(currentAng)
           'term.out($0d)
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

'this function fills teh compassLookup[] array so that it acts
  'as a lookup table going from [0,360]-->[0,360], normalizing
  'the compass readings
    'Example: angle := compassLookUp[compass.theta*10/227]      

PUB initCompassLookup
compassLookup[  0       ]:=     0
compassLookup[  1       ]:=     1
compassLookup[  2       ]:=     2
compassLookup[  3       ]:=     3
compassLookup[  4       ]:=     4
compassLookup[  5       ]:=     5
compassLookup[  6       ]:=     6
compassLookup[  7       ]:=     7
compassLookup[  8       ]:=     8
compassLookup[  9       ]:=     9
compassLookup[  10      ]:=     10
compassLookup[  11      ]:=     12
compassLookup[  12      ]:=     13
compassLookup[  13      ]:=     15
compassLookup[  14      ]:=     16
compassLookup[  15      ]:=     18
compassLookup[  16      ]:=     20
compassLookup[  17      ]:=     22
compassLookup[  18      ]:=     24
compassLookup[  19      ]:=     26
compassLookup[  20      ]:=     28
compassLookup[  21      ]:=     30
compassLookup[  22      ]:=     32
compassLookup[  23      ]:=     33
compassLookup[  24      ]:=     35
compassLookup[  25      ]:=     36
compassLookup[  26      ]:=     38
compassLookup[  27      ]:=     40
compassLookup[  28      ]:=     42
compassLookup[  29      ]:=     44
compassLookup[  30      ]:=     46
compassLookup[  31      ]:=     48
compassLookup[  32      ]:=     50
compassLookup[  33      ]:=     51
compassLookup[  34      ]:=     53
compassLookup[  35      ]:=     54
compassLookup[  36      ]:=     55
compassLookup[  37      ]:=     56
compassLookup[  38      ]:=     58
compassLookup[  39      ]:=     59
compassLookup[  40      ]:=     60
compassLookup[  41      ]:=     62
compassLookup[  42      ]:=     63
compassLookup[  43      ]:=     65
compassLookup[  44      ]:=     66
compassLookup[  45      ]:=     68
compassLookup[  46      ]:=     70
compassLookup[  47      ]:=     71
compassLookup[  48      ]:=     73
compassLookup[  49      ]:=     74
compassLookup[  50      ]:=     75
compassLookup[  51      ]:=     76
compassLookup[  52      ]:=     78
compassLookup[  53      ]:=     79
compassLookup[  54      ]:=     80
compassLookup[  55      ]:=     83
compassLookup[  56      ]:=     87
compassLookup[  57      ]:=     90
compassLookup[  58      ]:=     91
compassLookup[  59      ]:=     93
compassLookup[  60      ]:=     94
compassLookup[  61      ]:=     96
compassLookup[  62      ]:=     97
compassLookup[  63      ]:=     99
compassLookup[  64      ]:=     100
compassLookup[  65      ]:=     101
compassLookup[  66      ]:=     103
compassLookup[  67      ]:=     104
compassLookup[  68      ]:=     106
compassLookup[  69      ]:=     107
compassLookup[  70      ]:=     109
compassLookup[  71      ]:=     110
compassLookup[  72      ]:=     111
compassLookup[  73      ]:=     113
compassLookup[  74      ]:=     114
compassLookup[  75      ]:=     116
compassLookup[  76      ]:=     117
compassLookup[  77      ]:=     119
compassLookup[  78      ]:=     120
compassLookup[  79      ]:=     121
compassLookup[  80      ]:=     123
compassLookup[  81      ]:=     124
compassLookup[  82      ]:=     125
compassLookup[  83      ]:=     126
compassLookup[  84      ]:=     128
compassLookup[  85      ]:=     129
compassLookup[  86      ]:=     130
compassLookup[  87      ]:=     131
compassLookup[  88      ]:=     133
compassLookup[  89      ]:=     134
compassLookup[  90      ]:=     135
compassLookup[  91      ]:=     136
compassLookup[  92      ]:=     138
compassLookup[  93      ]:=     139
compassLookup[  94      ]:=     140
compassLookup[  95      ]:=     141
compassLookup[  96      ]:=     143
compassLookup[  97      ]:=     144
compassLookup[  98      ]:=     146
compassLookup[  99      ]:=     147
compassLookup[  100     ]:=     149
compassLookup[  101     ]:=     150
compassLookup[  102     ]:=     151
compassLookup[  103     ]:=     153
compassLookup[  104     ]:=     154
compassLookup[  105     ]:=     156
compassLookup[  106     ]:=     157
compassLookup[  107     ]:=     159
compassLookup[  108     ]:=     160
compassLookup[  109     ]:=     161
compassLookup[  110     ]:=     162
compassLookup[  111     ]:=     163
compassLookup[  112     ]:=     164
compassLookup[  113     ]:=     165
compassLookup[  114     ]:=     167
compassLookup[  115     ]:=     168
compassLookup[  116     ]:=     169
compassLookup[  117     ]:=     170
compassLookup[  118     ]:=     172
compassLookup[  119     ]:=     174
compassLookup[  120     ]:=     176
compassLookup[  121     ]:=     178
compassLookup[  122     ]:=     180
compassLookup[  123     ]:=     180
compassLookup[  124     ]:=     181
compassLookup[  125     ]:=     182
compassLookup[  126     ]:=     182
compassLookup[  127     ]:=     183
compassLookup[  128     ]:=     183
compassLookup[  129     ]:=     184
compassLookup[  130     ]:=     184
compassLookup[  131     ]:=     185
compassLookup[  132     ]:=     185
compassLookup[  133     ]:=     186
compassLookup[  134     ]:=     187
compassLookup[  135     ]:=     188
compassLookup[  136     ]:=     189
compassLookup[  137     ]:=     190
compassLookup[  138     ]:=     193
compassLookup[  139     ]:=     197
compassLookup[  140     ]:=     200
compassLookup[  141     ]:=     202
compassLookup[  142     ]:=     204
compassLookup[  143     ]:=     205
compassLookup[  144     ]:=     207
compassLookup[  145     ]:=     208
compassLookup[  146     ]:=     209
compassLookup[  147     ]:=     210
compassLookup[  148     ]:=     211
compassLookup[  149     ]:=     212
compassLookup[  150     ]:=     213
compassLookup[  151     ]:=     214
compassLookup[  152     ]:=     215
compassLookup[  153     ]:=     216
compassLookup[  154     ]:=     216
compassLookup[  155     ]:=     217
compassLookup[  156     ]:=     217
compassLookup[  157     ]:=     218
compassLookup[  158     ]:=     218
compassLookup[  159     ]:=     219
compassLookup[  160     ]:=     219
compassLookup[  161     ]:=     220
compassLookup[  162     ]:=     220
compassLookup[  163     ]:=     221
compassLookup[  164     ]:=     222
compassLookup[  165     ]:=     223
compassLookup[  166     ]:=     224
compassLookup[  167     ]:=     225
compassLookup[  168     ]:=     226
compassLookup[  169     ]:=     227
compassLookup[  170     ]:=     228
compassLookup[  171     ]:=     229
compassLookup[  172     ]:=     230
compassLookup[  173     ]:=     231
compassLookup[  174     ]:=     232
compassLookup[  175     ]:=     233
compassLookup[  176     ]:=     234
compassLookup[  177     ]:=     235
compassLookup[  178     ]:=     236
compassLookup[  179     ]:=     237
compassLookup[  180     ]:=     238
compassLookup[  181     ]:=     239
compassLookup[  182     ]:=     239
compassLookup[  183     ]:=     240
compassLookup[  184     ]:=     240
compassLookup[  185     ]:=     240
compassLookup[  186     ]:=     241
compassLookup[  187     ]:=     241
compassLookup[  188     ]:=     241
compassLookup[  189     ]:=     242
compassLookup[  190     ]:=     242
compassLookup[  191     ]:=     243
compassLookup[  192     ]:=     243
compassLookup[  193     ]:=     244
compassLookup[  194     ]:=     244
compassLookup[  195     ]:=     245
compassLookup[  196     ]:=     245
compassLookup[  197     ]:=     246
compassLookup[  198     ]:=     246
compassLookup[  199     ]:=     247
compassLookup[  200     ]:=     247
compassLookup[  201     ]:=     248
compassLookup[  202     ]:=     248
compassLookup[  203     ]:=     249
compassLookup[  204     ]:=     249
compassLookup[  205     ]:=     250
compassLookup[  206     ]:=     250
compassLookup[  207     ]:=     251
compassLookup[  208     ]:=     251
compassLookup[  209     ]:=     252
compassLookup[  210     ]:=     252
compassLookup[  211     ]:=     253
compassLookup[  212     ]:=     253
compassLookup[  213     ]:=     254
compassLookup[  214     ]:=     254
compassLookup[  215     ]:=     255
compassLookup[  216     ]:=     255
compassLookup[  217     ]:=     256
compassLookup[  218     ]:=     256
compassLookup[  219     ]:=     257
compassLookup[  220     ]:=     257
compassLookup[  221     ]:=     258
compassLookup[  222     ]:=     258
compassLookup[  223     ]:=     259
compassLookup[  224     ]:=     259
compassLookup[  225     ]:=     259
compassLookup[  226     ]:=     260
compassLookup[  227     ]:=     260
compassLookup[  228     ]:=     260
compassLookup[  229     ]:=     261
compassLookup[  230     ]:=     261
compassLookup[  231     ]:=     262
compassLookup[  232     ]:=     262
compassLookup[  233     ]:=     262
compassLookup[  234     ]:=     263
compassLookup[  235     ]:=     263
compassLookup[  236     ]:=     264
compassLookup[  237     ]:=     264
compassLookup[  238     ]:=     264
compassLookup[  239     ]:=     265
compassLookup[  240     ]:=     265
compassLookup[  241     ]:=     265
compassLookup[  242     ]:=     266
compassLookup[  243     ]:=     266
compassLookup[  244     ]:=     266
compassLookup[  245     ]:=     267
compassLookup[  246     ]:=     267
compassLookup[  247     ]:=     268
compassLookup[  248     ]:=     269
compassLookup[  249     ]:=     269
compassLookup[  250     ]:=     270
compassLookup[  251     ]:=     270
compassLookup[  252     ]:=     270
compassLookup[  253     ]:=     271
compassLookup[  254     ]:=     271
compassLookup[  255     ]:=     272
compassLookup[  256     ]:=     272
compassLookup[  257     ]:=     272
compassLookup[  258     ]:=     273
compassLookup[  259     ]:=     273
compassLookup[  260     ]:=     273
compassLookup[  261     ]:=     274
compassLookup[  262     ]:=     274
compassLookup[  263     ]:=     275
compassLookup[  264     ]:=     275
compassLookup[  265     ]:=     276
compassLookup[  266     ]:=     276
compassLookup[  267     ]:=     277
compassLookup[  268     ]:=     277
compassLookup[  269     ]:=     278
compassLookup[  270     ]:=     278
compassLookup[  271     ]:=     279
compassLookup[  272     ]:=     279
compassLookup[  273     ]:=     279
compassLookup[  274     ]:=     280
compassLookup[  275     ]:=     280
compassLookup[  276     ]:=     281
compassLookup[  277     ]:=     281
compassLookup[  278     ]:=     282
compassLookup[  279     ]:=     282
compassLookup[  280     ]:=     283
compassLookup[  281     ]:=     283
compassLookup[  282     ]:=     284
compassLookup[  283     ]:=     285
compassLookup[  284     ]:=     286
compassLookup[  285     ]:=     287
compassLookup[  286     ]:=     288
compassLookup[  287     ]:=     289
compassLookup[  288     ]:=     289
compassLookup[  289     ]:=     290
compassLookup[  290     ]:=     290
compassLookup[  291     ]:=     291
compassLookup[  292     ]:=     291
compassLookup[  293     ]:=     292
compassLookup[  294     ]:=     292
compassLookup[  295     ]:=     293
compassLookup[  296     ]:=     293
compassLookup[  297     ]:=     294
compassLookup[  298     ]:=     294
compassLookup[  299     ]:=     295
compassLookup[  300     ]:=     295
compassLookup[  301     ]:=     296
compassLookup[  302     ]:=     296
compassLookup[  303     ]:=     297
compassLookup[  304     ]:=     297
compassLookup[  305     ]:=     298
compassLookup[  306     ]:=     298
compassLookup[  307     ]:=     299
compassLookup[  308     ]:=     299
compassLookup[  309     ]:=     300
compassLookup[  310     ]:=     300
compassLookup[  311     ]:=     301
compassLookup[  312     ]:=     301
compassLookup[  313     ]:=     302
compassLookup[  314     ]:=     303
compassLookup[  315     ]:=     304
compassLookup[  316     ]:=     305
compassLookup[  317     ]:=     306
compassLookup[  318     ]:=     307
compassLookup[  319     ]:=     308
compassLookup[  320     ]:=     309
compassLookup[  321     ]:=     310
compassLookup[  322     ]:=     311
compassLookup[  323     ]:=     312
compassLookup[  324     ]:=     313
compassLookup[  325     ]:=     314
compassLookup[  326     ]:=     315
compassLookup[  327     ]:=     316
compassLookup[  328     ]:=     317
compassLookup[  329     ]:=     318
compassLookup[  330     ]:=     319
compassLookup[  331     ]:=     320
compassLookup[  332     ]:=     321
compassLookup[  333     ]:=     322
compassLookup[  334     ]:=     323
compassLookup[  335     ]:=     324
compassLookup[  336     ]:=     325
compassLookup[  337     ]:=     326
compassLookup[  338     ]:=     327
compassLookup[  339     ]:=     328
compassLookup[  340     ]:=     329
compassLookup[  341     ]:=     330
compassLookup[  342     ]:=     331
compassLookup[  343     ]:=     332
compassLookup[  344     ]:=     334
compassLookup[  345     ]:=     335
compassLookup[  346     ]:=     336
compassLookup[  347     ]:=     338
compassLookup[  348     ]:=     339
compassLookup[  349     ]:=     340
compassLookup[  350     ]:=     342
compassLookup[  351     ]:=     344
compassLookup[  352     ]:=     345
compassLookup[  353     ]:=     347
compassLookup[  354     ]:=     348
compassLookup[  355     ]:=     349
compassLookup[  356     ]:=     351
compassLookup[  357     ]:=     353
compassLookup[  358     ]:=     355
compassLookup[  359     ]:=     358

{{ old lookup table, semi-works when compass is not mounted on robot
  replaced 6/5/08
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
  compassLookup[  360     ]:=     315          }}