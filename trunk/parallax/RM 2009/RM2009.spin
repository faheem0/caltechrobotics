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
    4   (compass)  
    5     
    6    
    7                         
    8   
    9   motor                X
    10  compass 
    11  compass 
    12  compass
    13  compass      
    14  compass
    15  (motor)                X        XXXXX
    16  uartSLVrx     X               XXXX
    17  uartSLVtx            X        XXXX
    18   LED                 X          
    19             
    20     
    21    
    22   (BS2 functions) 
    23   (BS2 functions)  
    24   psxClk              X
    25   psxAttn             X
    26   psxCmd              X
    27   psxDat       X      X
    
  COG usage:
     0: main cog (constantly updates encoder values, gets/sends CPU data)
     1: debug: terminal window/DAQ/graph
     2: motors
     3: UART-PC
     4: compass
     5: compass
     6: UART-compass
     7: compass-send      
    
                                                 }}
VAR
    long motor[4]   'desired speed -100 to 100 indicating %
    long compassStack[20]
    long stack[60]
    
    long heartBeat  'for blinking the LED
 
    long timer

    'global data (constantly updated)
    long position[4]
    long velocity[4]
  
    'keeping track of when to send PC compass data
    long compassDataSendCounter
 
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
    _motBus = 9
   
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

   'for position controller:
  QPOS = %00001_000
  QSPD = %00010_000
  CHFA = %00011_000
  TRVL = %00100_000
  CLRP = %00101_000
  SREV = %00110_000
  STXD = %00111_000
  SMAX = %01000_000
  SSRR = %01001_000
  L_MOTOR_ID = %00000_001
  R_MOTOR_ID = %00000_010
  MAX_SPEED = 24
  MAX_ACCELLERATION = 10
  ARRIVAL_TOLERANCE = 10
    

OBJ 'objects used in this program-code must be in same directory
    term:   "PC_Interface"
    psx:    "ps2ControllerV1p1" '"ps2ControllerV1p2d"
    uartPC:   "FullDuplexSerial"
    uartCompass: "FullDuplexSerial"
    motorUart: "FullDuplexSerial"
    compass: "V2XE_Cog_1.0"
    motors: "HB25PositionController"
    
PUB main  |temp  ,lowpass ,temp2
   
    INITIALIZATION
    'repeat
    {{repeat
      uartPC.tx(42)
      term.out($0d)
      term.str(string("sent"))
      term.dec(uartPC.rxtime(10))
      term.str(string("  "))         
      pausems(500)             }}
    {{repeat
      pausems(50)
      term.str(string("heading: "))
      term.dec(compass.getHeading)
      term.out($0d)}}
    
   {{   pausems(50)
      motors.setMaxSpeed(1,1111)
      motors.setMaxSpeed(2,1111)
      motors.setPosition(1,20000)
      motors.setPosition(2,20000)
    repeat
      term.str(string("1: "))
      term.dec(motors.getPosition(1))
      term.str(string(" 2: "))
      term.dec(motors.getPosition(2))
      term.str(string(" v1: "))
      term.dec(motors.getVelocity(1))
      term.str(string(" v2: "))
      term.dec(motors.getVelocity(2))
      term.out($0d)            }}
    'motors.setPosition(1,motors.getPosition(1))
    'repeat  
    
    repeat
      printStatus
      navigatePSX
      'temp code
      if(isUsingPSX<>0)
        if(motor[0] <> 0)  
          motors.setMaxSpeed(1,||(motor[0]*2/5)) 'scale 100 to 40
        if(motor[1] <> 0)
          motors.setMaxSpeed(2,||(motor[1]*2/5))
        
        if motor[0] <> 0
          motors.setPosition(1,1*motor[0])
        else
          motors.setPosition(1,0)
          
        if motor[1] <> 0
          motors.setPosition(2,1*motor[1])
        else
          motors.setPosition(2,0)
          
        'end temp code
      else
        motors.setPosition(1,0)
        motors.setPosition(2,0)
        
      term.str(string("1: "))
      term.dec(motors.getPosition(1))
      term.str(string(" 2: "))
      term.dec(motors.getPosition(2))
      term.str(string(" v1: "))
      term.dec(motors.getVelocity(1))
      term.str(string(" v2: "))
      term.dec(motors.getVelocity(2))
      term.out($0d)

      {{term.str(string("1: "))
      term.dec(position[0])
      term.str(string(" 2: "))
      term.dec(position[1])
      term.str(string(" v1: "))
      term.dec(velocity[0])
      term.str(string(" v2: "))
      term.dec(velocity[1])
      term.out($0d)       }}

      pausems(50)      

PUB sendCompassData(debug) | i,startByte,reading, d0,d1,d2, encoderData[4],received, rcvStr[10], index, tempVelL,tempVelR
    startByte := 60
    index := 0
    pausems(2000)
    
    repeat
      'send compass data to dedicated compass serial port
      reading:=compass.getHeading
      if( debug <> 0)
        term.out($0d)
        term.str(string("c: "))
        term.dec(reading)
      d0:= reading//10
      d1:= (reading/10)//10
      d2:= (reading/100)//10
      uartCompass.tx(startByte)
      uartCompass.tx(d2+48)
      uartCompass.tx(d1+48)
      uartCompass.tx(d0+48)
      pausems(100)
      
     
      'send motor data to PC
      position[0]:=motors.getPosition(1)  'left
      position[1]:=motors.getPosition(2)  'right      
      velocity[0]:=motors.getVelocity(1)
      velocity[1]:=motors.getVelocity(2)            
      
      encoderData[0]:=position[1]    'right
      encoderData[1]:=position[0]    'left
      encoderData[2]:=velocity[1]
      encoderData[4]:=velocity[0]

      uartPC.tx(startByte)
      repeat i from 0 to 3
        if(encoderData[i]<0)
          uartPC.tx(45) 'send '-'
        else
          uartPC.tx(48) 'send '0'
        uartPC.tx((encoderData[i]/1)//10 +48)
        uartPC.tx((encoderData[i]/10)//10 +48)
        uartPC.tx((encoderData[i]/100)//10 +48)
        uartPC.tx((encoderData[i]/1000)//10 +48)
        uartPC.tx((encoderData[i]/10000)//10 +48)
        
                                                      
      'receive motor comands from PC
      received := uartPC.rxcheck
      repeat until received == -1
        if received <> -1' and 1<>1
          'term.dec(received)
          'term.str(string(" "))
          if received == startByte
            'term.str(string("str byte received"))
            'term.dec(index)
            if index == 4
              'term.str(string("parsing"))
              uartPC.rxflush
              tempVelL :=  (rcvStr[0]-48)*100+(rcvStr[1]-48)*10
              tempVelR :=  (rcvStr[2]-48)*100+(rcvStr[3]-48)*10 
               if (debug <> 0)
                 term.str(string(" m: "))
                 term.dec(tempVelL)
                 term.str(string(" R: "))
                 term.dec(tempVelR)
            elseif (debug <> 0)
              term.str(string("invalid str lenth btw starts"))
                         
            index := 0   
          else
            'term.str(string("inc"))
            rcvStr[index]:=received
            index++
        received := uartPC.rxcheck
      
      
PUB printStatus
      term.cls
      term.str(string("Current Status: "))
      term.out($0d)
      if(PCisConnected<>0)
        term.str(string("PC: ON "))
      else
        term.str(string("PC: -- "))      

      if(isUsingPSX<>0)
        term.str(string("PSX: using "))
      else
        term.str(string("PSX: -----  "))           
      term.out($0d)

      term.str(string("    RF  LF  RB  LB"))   
      term.str(string("motor: "))
      term.dec(motor[0])
      term.str(string(" "))
      term.dec(motor[1])
      term.str(string(" "))
      term.dec(motor[2])
      term.str(string(" "))
      term.dec(motor[3])
      term.out($0d)

      term.str(string("other messages: "))
      term.out($0d)
'This function should be called several times per second
  'to display all important information     
PUB TxRxPC | cmdByte , counter,rx1,rx2,rx3,angle1,angle2  ,rcvByte, rcvStr[100],i,temp, maxCnt,endCnt
                            
    maxCnt:= clkfreq/1000*12 '20Hz = 50ms period, 12ms for motor PID control
    endCnt:=cnt +maxCnt
    'check if using PSX controller
    if(navigatePSX<>0)
      term.str(string("navPSX "))
      uartPC.rxflush  
      return

    term.str(string("receiving data "))
    'Receive data    
    rcvByte:=uartPC.rxcheck
    if rcvByte == -1
      return
    repeat until (rcvByte == _startByte )
      rcvByte:=uartPC.rx

    rcvByte:=uartPC.rx
    i:=0
    repeat until (rcvByte == _startByte)
      rcvStr[0]:=rcvByte
      rcvByte:=uartPC.rx
      i++
    rcvStr[i]:=rcvByte 'store last start byte
    uartPC.rxflush 'clear buffer
    
    'for debugging
    i:=0
    term.str(string("received: "))
    repeat until (rcvStr[i]:=_startByte)
      term.out(rcvStr[i])
      term.out($0d)
    
      
         
   
    
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
         motor[0]:=driveSpeed
         motor[1]:=driveSpeed
      elseif (psx.getThumbL| Ddown== Ddown)
         motor[0]:=-1*driveSpeed
         motor[1]:=-1*driveSpeed
      if(psx.getThumbL| Dleft== Dleft)
         motor[0]:=driveSpeed
         motor[1]:=-1*driveSpeed
      elseif (psx.getThumbL| Dright== Dright)
         motor[0]:=-1*driveSpeed
         motor[1]:=driveSpeed  
      'term.bin(psx.getThumbR,8)
      'term.out($0d)
      if(psx.getThumbR|L1 ==L1)
        motor[0]:=motor[0]*2
        motor[1]:=motor[1]*2
    else
      rightJoy :=psx.getJoyRY          'get current joystick positions
      leftJoy := psx.getJoyLY        
       
      rightJoy:=rightJoy - 128                         'account for deadband in center
      if rightJoy > deadBand                                     'since joysticks do not center
        motor[0] := -1* (rightJoy-deadBand)               'perfectly
      elseif rightJoy < -1*deadBand
        motor[0] := -1* (rightJoy+deadBand)
      else
        motor[0] := 0
       
      leftJoy:=leftJoy - 128
      if leftJoy > deadBand
        motor[1] := -1* (leftJoy-deadBand)
      elseif leftJoy < -1*deadBand
        motor[1] := -1* (leftJoy+deadBand)
      else
        motor[1] := 0
    
    motor[2]:=motor[0]       'set back wheels to same speed as front
    motor[3]:=motor[1]
                           
'initializes pins/objects/etc       
PUB INITIALIZATION
    'initialize variables
    motor[0] :=0
    motor[1] :=0
    motor[2] :=0
    motor[3] :=0   
    heartBeat :=0
            
    LEDon
    dira[_LED]~~

    'initalize objects now
    'start terminal (prints to propterminal.exe)  
    term.start(31,30)
    term.str(string("starting up"))
      'test with 9600 8 N 1
      'update 5/19/08 actually 115200 8 N 2...   
    uartPC.start(_uartPCrx,_uartPCtx, %0011 , 115200)'(rxpin, txpin, mode, baudrate) : okay
    uartCompass.start(_uartCompassrx,_uartCompasstx, %0011 , 115200)'(rxpin, txpin, mode, baudrate) : okay
    ''uart mode bits:    
      '' mode bit 0 = invert rx
      '' mode bit 1 = invert tx
      '' mode bit 2 = open-drain/source tx
      '' mode bit 3 = ignore tx echo on rx
    'initialize playstation controller (doesn't use another COG)
    'motorUart.start(_motBus,_motBus, %1100, 19200)    
    motors.start(_motBus)
    motors.reverseOrientation(1)
      
    psx.start(27,26,25,24) 'ddat, cmd, att, clk
    term.str(string("init compass..."))
    compass.init 'uses 2 cogs
    term.out($0d)
    term.str(string("cog #(0-7): "))
    'term.dec(cognew(sendCompassData(0), @compassStack[0]))   '0 to disable debug statements
    'cognew(pausems(1), @stack[0]))
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

                      