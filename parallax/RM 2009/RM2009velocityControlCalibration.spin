'' File: RM2009.spin
'' For Caltech RoboMagellan 2009
''12/4/2008                                                                                    
{{history: 1.0 file copied from RoboMagellanMASTER1p0.spin, modified
                untested!
          3/23/09 - electronics transferred to beaver 2 platform, encoders and motors changed accordingly
                
Known issues:
    

                   
   PIN   Purpose    Input  Output
    0   uartPCtx             X
    1   uartPCrx      X      
    2   uartCompasstx        X
    3   uartCompassrx X          doesnt work?
    4   (compass)  
    5     
    6    
    7                         
    8   
    9   motor                X    now used for _motorPWM
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
     1: debug: terminal window
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
  
    long PCisConnected         '0 if PC-MCU connection is broken
    long PCtimeoutCount

    long isUsingPSX

    long compassLookup[360]

    long compassDebug

    'for PID motor control
    'long setPoint
    'long lastError[10]
    'long lastErrorCounter
    'long intError
    'long _kP,_kD,_kI  
    long motorLeft,motorRight
    
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

    _motorPWM = 8

   _MAXSPEED = 40 'in whatever units returned by encoders
   _motMaxSpeed = 80
    _NEXT_TIME_BYTE=254  
   

OBJ 'objects used in this program-code must be in same directory
    term:   "PC_Interface"
    psx:    "ps2ControllerV1p1" '"ps2ControllerV1p2d"
    uartPC:   "FullDuplexSerial"
    uartCompass: "FullDuplexSerial"
    motorUart: "FullDuplexSerial"
    compass: "V2XE_Cog_1.0"
    motors: "HB25PositionController"
    graph:  "FullDuplexSerial" 
    
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

      term.str(string("R: "))
      term.dec(position[0])
      term.str(string(" L: "))
      term.dec(position[1])
      term.str(string(" vR: "))
      term.dec(velocity[0])
      term.str(string(" vL: "))
      term.dec(velocity[1])
      term.out($0d)       

      pausems(50)      

PUB TxRxCompassAndMotorData(debug) | loopCnt,i,startByte,reading, d0,d1,d2, encoderData[4],received, rcvStr[10], index, tempVelL,tempVelR , pulseL, pulseR
    startByte := 60
    index := 0
    pausems(2000)
    
    repeat
      loopCnt:=cnt
      'send compass data to dedicated compass serial port
      reading:=compass.getHeading
      compassDebug:=reading
      if( debug <> 0)
        term.out($0d)
        term.str(string("c: "))
        term.dec(reading)
        {{term.str(string(" t: "))
        term.dec(compass.getTruncHeading)
        term.str(string(" o: "))
        term.dec(compass.getOrigHeading)
        term.str(string(" l: "))
        term.dec(compassLookup[compass.getOrigHeading])    }} 
      d0:= reading//10
      d1:= (reading/10)//10
      d2:= (reading/100)//10
      uartCompass.tx(startByte)
      uartCompass.tx(d2+48)
      uartCompass.tx(d1+48)
      uartCompass.tx(d0+48)
      
      
     
      'send motor data to PC
      position[0]:=-1*motors.getPosition(2)  'right
      position[1]:=-1*motors.getPosition(1)  'left      
      velocity[0]:=-1*motors.getVelocity(2)               
      velocity[1]:=-1*motors.getVelocity(1)            
      
      encoderData[0]:=position[1]    'left
      encoderData[1]:=position[0]    'right
      encoderData[2]:=velocity[1]
      encoderData[3]:=velocity[0]

      uartPC.tx(startByte)
      repeat i from 0 to 3
        if(encoderData[i]<0)
          uartPC.tx(45) 'send '-'
        else
          uartPC.tx(48) 'send '0'
        uartPC.tx((encoderData[i]/10000)//10 +48)
        uartPC.tx((encoderData[i]/1000)//10 +48)
        uartPC.tx((encoderData[i]/100)//10 +48)
        uartPC.tx((encoderData[i]/10)//10 +48)
        uartPC.tx((encoderData[i]/1)//10 +48)
        
                                                      
      'receive and parse motor commands from PC
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
              tempVelL :=  (rcvStr[0]-48)*100+(rcvStr[1]-48)*10 - 100 ' "- 100" to allow for -100 to +100 range
              tempVelR :=  (rcvStr[2]-48)*100+(rcvStr[3]-48)*10 - 100 
               if (debug <> 0)
                 term.str(string(" L: "))
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

      'update motors
      if(isUsingPSX==0)  'if not using PSX, then use values from serial port
        motor[0]:=tempVelL
        motor[1]:=tempVelR
        
      {{if(motor[0] <> 0)  
        motors.setMaxSpeed(1,||(motor[0]*_MAXSPEED/100)) 'scale 100 to 40
      if(motor[1] <> 0)
        motors.setMaxSpeed(2,||(motor[1]*_MAXSPEED/100))
       
      if motor[0] <> 0
        motors.setPosition(1,1*motor[0])
      else
        motors.setPosition(1,0)
        
      if motor[1] <> 0
        motors.setPosition(2,1*motor[1])
      else
        motors.setPosition(2,0)  }}

      'mode 2 HB-25 (2 units daisy chained)
      outa[_motorPWM]:=0
      dira[_motorPWM]:=1
      pulseR:=1500+5*motor[0]  'microseconds, 1000us to 2000us
      pulseL:=1500+5*motor[1]
      outa[_motorPWM]:=1
      waitcnt(cnt+80*pulseL)
      outa[_motorPWM]:=0
      waitcnt(cnt+clkfreq*2/1000)
      outa[_motorPWM]:=1
      waitcnt(cnt+80*pulseR)
      outa[_motorPWM]:=0
      '-----------------------------------

      'loop timing
      if(debug <> 0)
        term.str(string(" cts ellpsd: "))
        term.dec((cnt-loopCnt)/1000)
      waitcnt(loopCnt+clkfreq/20)   'runs loop @ 20 Hz
      'pausems(1000)
      blinkLED
      
      
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
      term.str(string("compass (CW from E): "))
      term.dec(compassDebug)
      term.out($0d)

      term.str(string("other messages: "))
      term.out($0d)


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
    motorRight:=motor[0]
    motorLeft:=motor[1]
         
'PID motor control with v883 motor controllers
'updates motor speed based on motorLeft and motorRight, encoder data
'output = kP*position + kD*velocity
'd(output) = kP*velocity + kD*acceleration
'output= output+ d(output)= output + kP*velocity + kD*acceleration
PUB PIDmotorLoop(debugGraph) | motorRightRamped, motorLeftRamped, ramp,avgVelLeft,avgVelRight,freq, delay,motorLeftSpeed,motorRightSpeed,errorL,errorR , kmPr,kmDr,kmPl,kmDl ,velLeft,lastVelLeft,lastVelRight, velRight, accLeft, accRight,encCountLeft, encCountRight,valLeft, valRight,temp,pulseR,pulseL
    '1.2mph=33.6 wheel rpm = 430 encoder counts/second
    'at 24V, 80 cnts/sample
    '20Hz ~21 counts/sample
    freq:=20 'Hz
    ramp:=0
    
    'kmPr:=7  'proportionality gain
    'kmDr:=-6'-2   'derivative gain (make negative)
    'kmPl:=4
    'kmDl:=-6
    
    kmPr:=3  'proportionality gain
    kmDr:=-3'-2   'derivative gain (make negative)
    kmPl:=3
    kmDl:=-3
    
    'initialize variables
    valLeft:=0
    valRight:=0
    lastVelLeft:=0
    lastVelRight:=0
    motorRightRamped:=0
    motorLeftRamped:=0
    
    
    repeat
      delay:=cnt+clkfreq/freq

      navigatePSX
      if debugGraph==1
        'just for debugging purposes: update desired speeds with values from PSX  
        navigatePSX   'set motorLeft and motorRight from PSX
        'adjust PID constants from terminal
        if(term.button(0))
          if(term.abs_x < 319/2 and term.abs_y <216/2)
            'open
          elseif(term.abs_x < 319/2 and term.abs_y >216/2)    'lower left corner
            kmPr--
            kmPl--
          elseif(term.abs_x > 319/2 and term.abs_y >216/2)      'lower right corner
            kmDr++
            kmDl++        
        elseif term.button(1)
          if(term.abs_x < 319/2 and term.abs_y <216/2) 
            'open
          elseif(term.abs_x < 319/2 and term.abs_y >216/2)
            kmPr++
            kmPl++
          elseif(term.abs_x > 319/2 and term.abs_y >216/2)
            kmDr--
            kmDl--   

      'ramp motor speed  
      motorRightRamped:= (ramp*motorRightRamped+ (100-ramp)*motorRight)/100
      motorLeftRamped:= (ramp*motorLeftRamped+ (100-ramp)*motorLeft)/100
                 
      'update desired motor speeds, encoder counts,velocities
      motorLeftSpeed:=motorLeftRamped      'get desired speed from global variables
      motorRightSpeed:=motorRightRamped
      'temp:=encoderL.getPos          'update position counter and current velocity
      temp:=1*motors.getPosition(1)  'left   
      velLeft:=encCountLeft-temp
      encCountLeft:=temp      
      'temp:=encoderR.getPos
      temp:=1*motors.getPosition(2)  'right             
      velRight:=encCountRight-temp
      encCountRight:=temp
      'update acceleration
      accLeft:=(velLeft-lastVelLeft)*100*freq/_motMaxSpeed      'update acc, (in terms of -100 to 100)  
      accRight:=(velRight-lastVelRight)*100*freq/_motMaxSpeed   'update acc, (in terms of -100 to 100)  
      lastVelLeft:=velLeft
      lastVelRight:=velRight

      motorLeftSpeed<#=100                 'limit input from -100% to 100%
      motorLeftSpeed#>=-100
      motorRightSpeed<#=100
      motorRightSpeed#>=-100

      'calculate velocity error (in terms of -100 to 100), ranges from -200 to 200
      errorL:= motorLeftSpeed -velLeft*100*freq/_motMaxSpeed
      errorR:= motorRightSpeed -velRight*100*freq/_motMaxSpeed
      

      valLeft:=valLeft + kmPl*errorL/10 + kmDl*accLeft/10    'no int term
      valRight:=valRight + kmPr*errorR/10 + kmDr*accRight/10 'no int term

      valLeft<#=100                 'limit output from -100% to 100%
      valLeft#>=-100
      valRight<#=100
      valRight#>=-100

      'prevent reversing the motors direction instantaneously
      if motorRightSpeed>0
        valRight#>=0
      elseif motorRightSpeed<0
        valRight<#=0
      if motorleftSpeed>0
        valleft#>=0
      elseif motorleftSpeed<0
        valleft<#=0
      'prevent stalling
      if motorRightSpeed>10
        valRight#>=10
      elseif motorRightSpeed < -10
        valRight<#= -10  
      if motorleftSpeed>10
        valleft#>=10
      elseif motorleftSpeed < -10
        valleft<#= -10  
       

      'setMotorLeft(valLeft)        'actually set motor speed here
      'setMotorRight(valRight)
      'mode 2 HB-25 (2 units daisy chained)
      outa[_motorPWM]:=0
      dira[_motorPWM]:=1
      pulseR:=1500+5*valRight  'microseconds, 1000us to 2000us
      pulseL:=1500+5*valLeft
      outa[_motorPWM]:=1
      waitcnt(cnt+80*pulseL)
      outa[_motorPWM]:=0
      waitcnt(cnt+clkfreq*2/1000)
      outa[_motorPWM]:=1
      waitcnt(cnt+80*pulseR)
      outa[_motorPWM]:=0
      '-----------------------------------

      avgVelRight:= (8*avgVelRight+velRight*100*freq/_motMaxSpeed*2)/10   'put motor speed thru low pass, make more readable
      avgVelLeft:= (8*avgVelLeft+velLeft*100*freq/_motMaxSpeed*2)/10

      'graph data to serialPlot (java)
      if debugGraph==1
        if( 1==0)   'graph right side
          graph.tx(motorRightSpeed)           'setpoint
          graph.tx(avgVelRight)   'actual velocity
          graph.tx(valRight)                    ' signal output to motor
          'graph.tx(kmPr*10)
          'graph.tx(kmDr*10)
        else       'or graph left side
          graph.tx(motorLeftSpeed)           'setpoint
          graph.tx(avgVelLeft)   'actual velocity
          graph.tx(valLeft)                    ' signal output to motor
          'graph.tx(kmPl*10)
          'graph.tx(kmDl*10)
         
        graph.tx(_NEXT_TIME_BYTE)
         
        term.cls                               'print PID constants for tuning
       {{ term.str(string("kmPr: "))
        term.dec(kmPr)
        term.out($0d)
        term.str(string("kmDr: "))
        term.dec(kmDr)
        term.out($0d)
        term.str(string("kmPl: "))
        term.dec(kmPl)
        term.out($0d)
        term.str(string("kmDl: "))
        term.dec(kmDl)
        term.out($0d)
        term.str(string("stpt: "))
        term.dec(motorRightSpeed)
        term.str(string(" meas: "))
        term.dec(valRight)           }}
      
      
      term.str(string("setpt L (%): "))                  'print data to terminal
      term.dec(motorLeftSpeed)
      term.out($0d)
      term.str(string("setpt R: "))
      term.dec(motorRightSpeed)
      term.out($0d)
      term.str(string("vel L (%): "))
      term.dec(velLeft*100*freq/_motMaxSpeed)
      term.out($0d)
      term.str(string("vel R: "))
      term.dec(velRight*100*freq/_motMaxSpeed)
      term.out($0d)
      term.str(string("out L (%): "))
      term.dec(valLeft)
      term.out($0d)
      term.str(string("out R: "))
      term.dec(valRight)
      term.out($0d)
      term.str(string("acc L (v%/20s): "))
      term.dec(accLeft)
      term.out($0d)
      term.str(string("acc R: "))
      term.dec(accRight)
      term.out($0d)
      term.str(string("Err L (%): "))
      term.dec(errorL)
      term.out($0d)
      term.str(string("Err R: "))
      term.dec(errorR)
      term.out($0d)
     
      term.out($0d)
      term.dec((delay-cnt)/80)
      term.str(string("us left"))    
      
      waitcnt(delay)                        'wait to achieve desired update frequency
    
'initializes pins/objects/etc       
PUB INITIALIZATION
    'initialize variables
    motor[0] :=0
    motor[1] :=0
    motor[2] :=0
    motor[3] :=0   
    heartBeat :=0

    outa[_motorPWM]:=0
    dira[_motorPWM]:=1

    initCompassLookup
            
    LEDon
    

    'initalize objects now
    'start terminal (prints to propterminal.exe)  
    term.start(31,30)
    term.str(string("starting up"))
      'test with 9600 8 N 1
      'update 5/19/08 actually 115200 8 N 2...   
    uartPC.start(_uartPCrx,_uartPCtx, %0011 , 115200)'(rxpin, txpin, mode, baudrate) : okay
    graph.start(_uartCompassrx,_uartCompasstx,%0011,9600)
                                            
    'uartCompass.start(_uartCompassrx,_uartCompasstx, %0011 , 115200)'(rxpin, txpin, mode, baudrate) : okay
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

    PIDmotorLoop(1)
    
    term.str(string("init compass..."))
    compass.init 'uses 2 cogs
    term.out($0d)
    term.str(string("cog #(0-7): "))
    term.dec(cognew(TxRxCompassAndMotorData(0), @compassStack[0]))   '0 to disable debug statements
    'cognew(pausems(1), @stack[0]))
    term.out($0d)
    term.str(string("done"))
    pausems(1000)
         
    term.cls       
    LEDoff
    'repeat
    

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
    dira[_LED]~~
PUB LEDoff
    outa[_LED]~
    dira[_LED]~~

      
PUB pausems(ms)
  waitcnt(cnt+clkfreq/1000*ms)

PUB initCompassLookup
compassLookup[  0       ]:=     0
compassLookup[  1       ]:=     0
compassLookup[  2       ]:=     1
compassLookup[  3       ]:=     1
compassLookup[  4       ]:=     2
compassLookup[  5       ]:=     2
compassLookup[  6       ]:=     3
compassLookup[  7       ]:=     3
compassLookup[  8       ]:=     4
compassLookup[  9       ]:=     4
compassLookup[  10      ]:=     5
compassLookup[  11      ]:=     5
compassLookup[  12      ]:=     6
compassLookup[  13      ]:=     6
compassLookup[  14      ]:=     7
compassLookup[  15      ]:=     7
compassLookup[  16      ]:=     8
compassLookup[  17      ]:=     8
compassLookup[  18      ]:=     9
compassLookup[  19      ]:=     9
compassLookup[  20      ]:=     9
compassLookup[  21      ]:=     10
compassLookup[  22      ]:=     10
compassLookup[  23      ]:=     10
compassLookup[  24      ]:=     11
compassLookup[  25      ]:=     11
compassLookup[  26      ]:=     12
compassLookup[  27      ]:=     12
compassLookup[  28      ]:=     13
compassLookup[  29      ]:=     13
compassLookup[  30      ]:=     13
compassLookup[  31      ]:=     14
compassLookup[  32      ]:=     14
compassLookup[  33      ]:=     15
compassLookup[  34      ]:=     15
compassLookup[  35      ]:=     15
compassLookup[  36      ]:=     16
compassLookup[  37      ]:=     16
compassLookup[  38      ]:=     17
compassLookup[  39      ]:=     17
compassLookup[  40      ]:=     17
compassLookup[  41      ]:=     18
compassLookup[  42      ]:=     18
compassLookup[  43      ]:=     18
compassLookup[  44      ]:=     19
compassLookup[  45      ]:=     19
compassLookup[  46      ]:=     20
compassLookup[  47      ]:=     20
compassLookup[  48      ]:=     20
compassLookup[  49      ]:=     21
compassLookup[  50      ]:=     21
compassLookup[  51      ]:=     21
compassLookup[  52      ]:=     22
compassLookup[  53      ]:=     22
compassLookup[  54      ]:=     23
compassLookup[  55      ]:=     23
compassLookup[  56      ]:=     23
compassLookup[  57      ]:=     24
compassLookup[  58      ]:=     24
compassLookup[  59      ]:=     25
compassLookup[  60      ]:=     25
compassLookup[  61      ]:=     25
compassLookup[  62      ]:=     26
compassLookup[  63      ]:=     26
compassLookup[  64      ]:=     27
compassLookup[  65      ]:=     27
compassLookup[  66      ]:=     27
compassLookup[  67      ]:=     28
compassLookup[  68      ]:=     28
compassLookup[  69      ]:=     29
compassLookup[  70      ]:=     29
compassLookup[  71      ]:=     30
compassLookup[  72      ]:=     30
compassLookup[  73      ]:=     31
compassLookup[  74      ]:=     31
compassLookup[  75      ]:=     32
compassLookup[  76      ]:=     32
compassLookup[  77      ]:=     33
compassLookup[  78      ]:=     33
compassLookup[  79      ]:=     34
compassLookup[  80      ]:=     35
compassLookup[  81      ]:=     35
compassLookup[  82      ]:=     36
compassLookup[  83      ]:=     36
compassLookup[  84      ]:=     37
compassLookup[  85      ]:=     37
compassLookup[  86      ]:=     38
compassLookup[  87      ]:=     39
compassLookup[  88      ]:=     39
compassLookup[  89      ]:=     40
compassLookup[  90      ]:=     40
compassLookup[  91      ]:=     41
compassLookup[  92      ]:=     41
compassLookup[  93      ]:=     42
compassLookup[  94      ]:=     42
compassLookup[  95      ]:=     43
compassLookup[  96      ]:=     43
compassLookup[  97      ]:=     44
compassLookup[  98      ]:=     44
compassLookup[  99      ]:=     45
compassLookup[  100     ]:=     45
compassLookup[  101     ]:=     46
compassLookup[  102     ]:=     47
compassLookup[  103     ]:=     48
compassLookup[  104     ]:=     49
compassLookup[  105     ]:=     50
compassLookup[  106     ]:=     51
compassLookup[  107     ]:=     52
compassLookup[  108     ]:=     53
compassLookup[  109     ]:=     54
compassLookup[  110     ]:=     55
compassLookup[  111     ]:=     56
compassLookup[  112     ]:=     57
compassLookup[  113     ]:=     58
compassLookup[  114     ]:=     59
compassLookup[  115     ]:=     60
compassLookup[  116     ]:=     61
compassLookup[  117     ]:=     63
compassLookup[  118     ]:=     64
compassLookup[  119     ]:=     65
compassLookup[  120     ]:=     66
compassLookup[  121     ]:=     67
compassLookup[  122     ]:=     68
compassLookup[  123     ]:=     69
compassLookup[  124     ]:=     70
compassLookup[  125     ]:=     72
compassLookup[  126     ]:=     73
compassLookup[  127     ]:=     74
compassLookup[  128     ]:=     76
compassLookup[  129     ]:=     77
compassLookup[  130     ]:=     79
compassLookup[  131     ]:=     80
compassLookup[  132     ]:=     82
compassLookup[  133     ]:=     84
compassLookup[  134     ]:=     85
compassLookup[  135     ]:=     86
compassLookup[  136     ]:=     88
compassLookup[  137     ]:=     90
compassLookup[  138     ]:=     91
compassLookup[  139     ]:=     93
compassLookup[  140     ]:=     94
compassLookup[  141     ]:=     96
compassLookup[  142     ]:=     98
compassLookup[  143     ]:=     100
compassLookup[  144     ]:=     102
compassLookup[  145     ]:=     104
compassLookup[  146     ]:=     106
compassLookup[  147     ]:=     108
compassLookup[  148     ]:=     110
compassLookup[  149     ]:=     112
compassLookup[  150     ]:=     114
compassLookup[  151     ]:=     115
compassLookup[  152     ]:=     117
compassLookup[  153     ]:=     119
compassLookup[  154     ]:=     120
compassLookup[  155     ]:=     122
compassLookup[  156     ]:=     124
compassLookup[  157     ]:=     125
compassLookup[  158     ]:=     127
compassLookup[  159     ]:=     129
compassLookup[  160     ]:=     130
compassLookup[  161     ]:=     132
compassLookup[  162     ]:=     134
compassLookup[  163     ]:=     135
compassLookup[  164     ]:=     137
compassLookup[  165     ]:=     139
compassLookup[  166     ]:=     140
compassLookup[  167     ]:=     142
compassLookup[  168     ]:=     144
compassLookup[  169     ]:=     145
compassLookup[  170     ]:=     147
compassLookup[  171     ]:=     148
compassLookup[  172     ]:=     149
compassLookup[  173     ]:=     150
compassLookup[  174     ]:=     152
compassLookup[  175     ]:=     153
compassLookup[  176     ]:=     155
compassLookup[  177     ]:=     156
compassLookup[  178     ]:=     158
compassLookup[  179     ]:=     159
compassLookup[  180     ]:=     160
compassLookup[  181     ]:=     161
compassLookup[  182     ]:=     163
compassLookup[  183     ]:=     164
compassLookup[  184     ]:=     165
compassLookup[  185     ]:=     167
compassLookup[  186     ]:=     168
compassLookup[  187     ]:=     169
compassLookup[  188     ]:=     170
compassLookup[  189     ]:=     172
compassLookup[  190     ]:=     173
compassLookup[  191     ]:=     174
compassLookup[  192     ]:=     175
compassLookup[  193     ]:=     176
compassLookup[  194     ]:=     177
compassLookup[  195     ]:=     179
compassLookup[  196     ]:=     180
compassLookup[  197     ]:=     181
compassLookup[  198     ]:=     181
compassLookup[  199     ]:=     182
compassLookup[  200     ]:=     183
compassLookup[  201     ]:=     183
compassLookup[  202     ]:=     184
compassLookup[  203     ]:=     185
compassLookup[  204     ]:=     186
compassLookup[  205     ]:=     186
compassLookup[  206     ]:=     187
compassLookup[  207     ]:=     188
compassLookup[  208     ]:=     189
compassLookup[  209     ]:=     189
compassLookup[  210     ]:=     190
compassLookup[  211     ]:=     191
compassLookup[  212     ]:=     192
compassLookup[  213     ]:=     193
compassLookup[  214     ]:=     194
compassLookup[  215     ]:=     194
compassLookup[  216     ]:=     195
compassLookup[  217     ]:=     196
compassLookup[  218     ]:=     197
compassLookup[  219     ]:=     197
compassLookup[  220     ]:=     198
compassLookup[  221     ]:=     199
compassLookup[  222     ]:=     200
compassLookup[  223     ]:=     201
compassLookup[  224     ]:=     202
compassLookup[  225     ]:=     203
compassLookup[  226     ]:=     204
compassLookup[  227     ]:=     204
compassLookup[  228     ]:=     205
compassLookup[  229     ]:=     206
compassLookup[  230     ]:=     207
compassLookup[  231     ]:=     207
compassLookup[  232     ]:=     208
compassLookup[  233     ]:=     209
compassLookup[  234     ]:=     210
compassLookup[  235     ]:=     211
compassLookup[  236     ]:=     212
compassLookup[  237     ]:=     213
compassLookup[  238     ]:=     214
compassLookup[  239     ]:=     215
compassLookup[  240     ]:=     216
compassLookup[  241     ]:=     216
compassLookup[  242     ]:=     217
compassLookup[  243     ]:=     218
compassLookup[  244     ]:=     219
compassLookup[  245     ]:=     220
compassLookup[  246     ]:=     221
compassLookup[  247     ]:=     222
compassLookup[  248     ]:=     223
compassLookup[  249     ]:=     224
compassLookup[  250     ]:=     225
compassLookup[  251     ]:=     225
compassLookup[  252     ]:=     226
compassLookup[  253     ]:=     227
compassLookup[  254     ]:=     228
compassLookup[  255     ]:=     229
compassLookup[  256     ]:=     230
compassLookup[  257     ]:=     231
compassLookup[  258     ]:=     232
compassLookup[  259     ]:=     233
compassLookup[  260     ]:=     234
compassLookup[  261     ]:=     235
compassLookup[  262     ]:=     137
compassLookup[  263     ]:=     238
compassLookup[  264     ]:=     239
compassLookup[  265     ]:=     240
compassLookup[  266     ]:=     241
compassLookup[  267     ]:=     242
compassLookup[  268     ]:=     244
compassLookup[  269     ]:=     245
compassLookup[  270     ]:=     246
compassLookup[  271     ]:=     248
compassLookup[  272     ]:=     249
compassLookup[  273     ]:=     250
compassLookup[  274     ]:=     251
compassLookup[  275     ]:=     252
compassLookup[  276     ]:=     254
compassLookup[  277     ]:=     255
compassLookup[  278     ]:=     256
compassLookup[  279     ]:=     258
compassLookup[  280     ]:=     259
compassLookup[  281     ]:=     260
compassLookup[  282     ]:=     261
compassLookup[  283     ]:=     262
compassLookup[  284     ]:=     264
compassLookup[  285     ]:=     265
compassLookup[  286     ]:=     266
compassLookup[  287     ]:=     268
compassLookup[  288     ]:=     269
compassLookup[  289     ]:=     270
compassLookup[  290     ]:=     272
compassLookup[  291     ]:=     273
compassLookup[  292     ]:=     274
compassLookup[  293     ]:=     276
compassLookup[  294     ]:=     278
compassLookup[  295     ]:=     280
compassLookup[  296     ]:=     282
compassLookup[  297     ]:=     284
compassLookup[  298     ]:=     286
compassLookup[  299     ]:=     288
compassLookup[  300     ]:=     290
compassLookup[  301     ]:=     292
compassLookup[  302     ]:=     294
compassLookup[  303     ]:=     295
compassLookup[  304     ]:=     297
compassLookup[  305     ]:=     299
compassLookup[  306     ]:=     300
compassLookup[  307     ]:=     302
compassLookup[  308     ]:=     303
compassLookup[  309     ]:=     304
compassLookup[  310     ]:=     306
compassLookup[  311     ]:=     307
compassLookup[  312     ]:=     309
compassLookup[  313     ]:=     310
compassLookup[  314     ]:=     312
compassLookup[  315     ]:=     314
compassLookup[  316     ]:=     315
compassLookup[  317     ]:=     317
compassLookup[  318     ]:=     318
compassLookup[  319     ]:=     319
compassLookup[  320     ]:=     320
compassLookup[  321     ]:=     322
compassLookup[  322     ]:=     323
compassLookup[  323     ]:=     325
compassLookup[  324     ]:=     326
compassLookup[  325     ]:=     327
compassLookup[  326     ]:=     329
compassLookup[  327     ]:=     330
compassLookup[  328     ]:=     331
compassLookup[  329     ]:=     333
compassLookup[  330     ]:=     334
compassLookup[  331     ]:=     335
compassLookup[  332     ]:=     336
compassLookup[  333     ]:=     337
compassLookup[  334     ]:=     338
compassLookup[  335     ]:=     339
compassLookup[  336     ]:=     340
compassLookup[  337     ]:=     341
compassLookup[  338     ]:=     342
compassLookup[  339     ]:=     343
compassLookup[  340     ]:=     344
compassLookup[  341     ]:=     344
compassLookup[  342     ]:=     345
compassLookup[  343     ]:=     346
compassLookup[  344     ]:=     247
compassLookup[  345     ]:=     347
compassLookup[  346     ]:=     348
compassLookup[  347     ]:=     349
compassLookup[  348     ]:=     350
compassLookup[  349     ]:=     351
compassLookup[  350     ]:=     352
compassLookup[  351     ]:=     353
compassLookup[  352     ]:=     354
compassLookup[  353     ]:=     355
compassLookup[  354     ]:=     355
compassLookup[  355     ]:=     356
compassLookup[  356     ]:=     357
compassLookup[  357     ]:=     358
compassLookup[  358     ]:=     359
compassLookup[  359     ]:=     359
                      