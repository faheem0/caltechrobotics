'' File: balancingBotPEKv2p6.spin
'' Uses PEK to control balancing bot/segway, adjust PID values and setPoint thru terminal
''Version 2.6
''1/3/2008
{{history: 1.0 file started, ps2 controll + motors , servo, uart
           1.1 acc support, ADC + IR ranger, scanning cog added
           1.2 xbee support? failed
           1.3 acc problem fixed (must use pll8x OR less), motorcontroller code changed for this
           1.4 better balancing!
           1.5 still improving, fixed deriv term, still needs tuning
           1.6 abstraction improved, addition of arcsin
           1.7 reads rc gyro, balances?

           2.0 acc/gyro objects with built in, adjustable filters, conversion to degrees
           2.1 printing to PLX-DAQ
           2.2 code cleaned up, PD angle balancing, works!?,terminal window adjustments
           2.3 position factoered in? integral
           2.4 FULL SCALE!, victor 883 control added, acc no longer uses another cog, back to 80MHz, encoders? scan IR removed?
           2.5 encoder position scaled? encoders slip!?? slip fixed, 32:1 ratio = 768counts/rev
           2.6 scan IR removed, v883's mounted and tested, encoders circuit finalized, tested,
               3.8mph top speed no load @22.6V 109RPM, 1.2mph @ 7.2V 34RPM 
Known issues: ping returns 15cm/5in
              xbee doesn't work with usb-serial/Java    ?
              check limits and scale v883 PWM signals accordingly/individually
              right v883 fan needs help starting
              
Stuff to tune:
  kP
  kD
  kI
  last nth measurement used for derivative term
  refresh rate (frequency)
  motor deadband
                                                        
                                  }}
{{ PIN   Purpose    Input  Output
    0     acc-CS             X
    1     acc-DIO    X       X
    2     acc-CLK            X
    3     encL       X
    4     encL       X
    5     encR       X
    6     encR       X
    7     LED                X    
    8     motL               X
    9     motR               X
    10    gyroAux            X
    11    gyroOut            X
    12    gyroIn     X
    13                               
    14     UART-rx   X
    15     UART-tx           X
    16     D1L               X    
    17     D2L               X    
    18     ENL               X   
    19     D1R               X              
    20     D2R               X
    21     ENR               X  
    22     servo             X
    23     
    24     psx-DAT   X 
    25     psx-CMD           X
    26     psx-ATT           X
    27     psx-CLK           X              }}
{{COG usage:
  X  0: main cog
  X  1: terminal window/DAQ
     2: motor PWM (h-bridges)
     3: scanning servo + IR measurements
     4: uart (xbee?)
  X  5: servo PWM: servos, gyros, v883's
  
     7: psx
  X (8): gyro PWM reading
  X (9): filter calculating
  X  (10): encoder #1
  X  (11): encoder #2
    
                                                 }}
VAR
    long motorLeft   'duty cycle for h-bridges, -100 to 100 indicating %
    long motorRight
    'long panServoPosition '1000 to 2000
    long heartBeat  'for blinking the LED
    long stack[60] 'for motor cog
    'long stack2 [100] 'for scan cog, 100 is sufficient for 2 deg resolution
    long stack3[30] 'for gyro PWM reading cog
    long stack4[30] 'for filter cog
    long timer
    'long infraredScan[_scanResolution]

    long setPoint
    long lastError[10]
    long lastErrorCounter
    long intError
    long accReading 'raw acc data
    long accAngle 'converted to degrees
    long gyroReading  'raw gyro data
    long dGyroAngle
    long intGyroAngle  'integrated gyro readings (not converted to degrees)
    long intGyroAngleDegrees 'converted to degrees
    long filtAngle    'filtered angle
    long debug
    long _kP,_kD,_kI
    
    
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
    
    _LED = 7            'pins
    _motL = 8
    _motR = 9
    _gyroAux = 10
    _gyroOut = 11
    _gyroIn = 12       
    _panServo = 22
    
    '_panServoMin = 600    '0 degrees
    '_panServoMax = 2450    '180 degrees

    _motLFullReverse = 1146    'experimentally determined v883 PWM values
    _motLMinReverse = 1489
    _motLMinForward =  1558
    _motLFullForward =  1915
    _motRFullReverse = 1168
    _motRMinReverse = 1488
    _motRMinForward =  1556
    _motRFullForward =  1906
    
    _startByte = $FE
    _stopByte = $FE
    _scanResolution=10
    _scanOn = 0                        'TURN SCAN ON/OFF HERE
    _motorOn = 0                       'TURN MOTORS ON/OFF HERE

    '_kP =40'10'12 'for 7.2V
    '_kD =-5'5'7  'for 7.2V
    '_kI = 0
    

OBJ
    term:   "PC_Interface"
    PDAQ : "PLX-DAQ"
    acc:    "H48C Tri-Axis AccelerometerNoNewCog"       
    psx:    "ps2ControllerV1p2d"
    servos: "Servo32"
    uart:   "FullDuplexSerial"
    'infrared: "ADC0831"
    encoderL: "encoderCustomASM"
    encoderR: "encoderCustomASM"      
PUB main

    INITIALIZATION
    'encoderTest
    v883motorPWMTest
    
    'printAngle
    
    'printGyro
    angleBalanceLoop  
    repeat    
      'mainLoop2
      MAINLOOP
PUB encoderTest
    repeat
      term.cls
      
      waitcnt(clkfreq/20+cnt)

'tests v883 and encoders         
PUB v883motorPWMTest| PWMValue,cntStart,cntFinish,temp,lastPosR, currentPosR,rpmR,lastPosL, currentPosL,rpmL
 PWMValue:=1500
 repeat
    temp:=cnt+clkfreq/20
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
    servos.set(_motR,PWMValue)
    servos.set(_motL,PWMValue) 
    PWMValue<#= 2000                
    PWMValue#>=1000

    currentPosR:=encoderR.getPos
    currentPosL:=encoderL.getPos
    rpmR:= (currentPosR-lastPosR)*20*60/24/32
    rpmL:= (currentPosL-lastPosL)*20*60/24/32
    term.cls
    term.str(string("PWM value: "))
    term.dec(PWMValue)
    term.out($0d)
    term.dec(ina[23])
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
    term.str(string("MPH of L(100): "))   '1mph = 88 fpm
    term.dec(rpmL*314/88)
    term.out($0d)
    term.str(string("MPH of R(100): "))   '1mph = 88 fpm
    term.dec(rpmR*314/88)
    term.out($0d)
    lastPosR:=currentPosR
    lastPosL:=currentPosL
    waitcnt(temp)
 'repeat
    {{'768/24=32
    if ina[23]==0
      waitcnt(cnt+clkfreq)
      term.cls
      term.str(string("counting"))
      term.out($0d)
      '988/24,967,986,879,776   764,808,832,792,929,856,784 ?????
     
      waitpne(|< 23, |< 23, 0) 'Wait for Pin to go low
      cntStart:=encoderR.getPos
     repeat    
      
      waitcnt(cnt+clkfreq)

      waitpne(|< 23, |< 23, 0) 'Wait for Pin to go low
      cntFinish:=encoderR.getPos
      'servos.set(_motR,1500)
      term.dec(cntFinish-cntStart)
      term.out($0d)
      cntStart:=cntFinish    }}
   
pub printAngleDAQ |delayTime
    repeat until accReading <> 0
      blinkLED
      waitcnt(clkfreq/1000+cnt)

    repeat
        delayTime:=cnt+clkfreq/10     
        PDAQ.DataText(string("TIME,TIMER"))               ' Place current time and time since reset
        PDAQ.DataDiv(accAngle,1000)                                  ' Send data of angle
        PDAQ.DataDiv(intGyroAngle,1000)
        PDAQ.DataDiv(filtAngle,1000)                     ' Send data of sin of angle / 1000
        PDAQ.CR                                           ' End of data for row
        
        waitcnt(delayTime)

'loops and prints filtered/raw angles        
pub printAngle |delayTime
    term.str(string("waiting for gyro to init..."))  
    repeat until accReading <> 0
      blinkLED
      waitcnt(clkfreq/1000+cnt)

    repeat
        delayTime:=cnt+clkfreq/10     
        term.cls
        term.str(string("Acc angle: "))  
        term.dec(accAngle)
        term.out($0d)
        term.str(string("Gyro angle (deg): "))
        term.dec(intGyroAngleDegrees)
        term.out($0d)
        term.str(string("gyro reading: "))
        term.dec(gyroReading)
        term.out($0d)
        term.str(string("Filtered angle: "))
        term.dec(filtAngle)
        term.out($0d)        
             
        waitcnt(delayTime)        


        
'loops and prints acc data
pub printAcc  |count,mytemp
    ''DOES NOT WORK ANYMORE, acc doesn't run in own cog, so it interferes with filterLoop
    repeat
      'accReading:=acc.z
      
      'accAngle:=accReading*1000/ref*57 'works!
      term.cls
      term.str(string("accZ: "))
      count:=cnt
      'myTemp:=acc.z
      count:=count-cnt
      term.dec(myTemp)
      term.str(string(" "))
      term.dec(count/clkfreq*1_000_000)
      term.out($0d)
      term.str(string("accReading, same?: "))
      term.dec(accReading)
      term.out($0d)
      term.str(string("accAngle: "))
      term.dec(accAngle)
      term.str(string(" degrees"))
      
      term.out($0d)
      waitcnt(cnt+clkfreq/10)
      
'loops and prints out gyro reading, angle
pub printGyro 
    
    repeat
      term.cls                  
      term.str(string("gyroReading: "))
      term.dec(gyroReading)
      term.out($0d)
      term.str(string("intGyroAngle: "))
      term.dec(intGyroAngle)
      term.out($0d)
      term.str(string("intGyroAngleDegrees: "))
      term.dec(intGyroAngleDegrees)
      
      waitcnt(cnt+clkfreq/10)
      
'runs in its own cog
'updates accReading, accAngle, intGyroAngleDegrees, and filtAngle
'runs at 100Hz, actual loop takes 1.8ms out of 10ms
PUB filterLoop |a,delayTime,lastGyroAngle,myTimer
    a:=98                  'adjust complementary filter,0-100
    
    repeat 4               'pause for 4 seconds to allow gyro to initialize
      waitcnt(clkfreq+cnt)
      
    intGyroAngle:=0
    lastGyroAngle:=intGyroAngle

    'angle calculation loop, limited to ~200Hz by acc, ~500Hz by gyro
    repeat
      myTimer:=cnt
      delayTime:=clkfreq/100+cnt       'aim for 100Hz
      accReading:=acc.z    'takes about 1.7ms
      accAngle:=accReading*1000/490*57              'works!  scales acc's reading into degrees
      intGyroAngleDegrees:=intGyroAngle*1000/133    'works!  scales integrated gyro angle into degrees
      dGyroAngle:=intGyroAngleDegrees-lastGyroAngle '? reversed?-gets change in integrated gyro angle since last loop
      if((||dGyroAngle) >1000)     'noise filter, works!
        dGyroAngle:=0
      lastGyroAngle:=intGyroAngleDegrees            'update lastGyroAngle with the current one for the next loop
      filtAngle:=a*(filtAngle+dGyroAngle)/100 + (100-a)*accAngle/100     'ANGLE CALCULATION HERE
      '388us
      debug:=myTimer-cnt
      waitcnt(delayTime)               'wait until 10ms has passed for precise 100Hz operation
         
'runs in its own cog
'updates gyroReading and intGyroAngle with gyro reading (-? to ?), negative = leaning forward (by software)  
PUB readGyroLoop |time,angle     
    dira[_gyroIn]:=0 'input
    waitcnt(clkfreq*1+cnt)
    repeat
      waitpne(|< _gyroIn, |< _gyroIn, 0) 'Wait for Pin 12 to go low
      waitpeq(|< _gyroIn, |< _gyroIn, 0) 'Wait for Pin 12 to go high  (wait for start of PWM signal)
      time:=cnt
      'timer:=cnt -tempTimer
      waitpne(|< _gyroIn, |< _gyroIn, 0) 'Wait for Pin 12 to go low   (wait for end of PWM signal)
      time:=(cnt-time)
      time:=time/80'converts to us
      if(time==1505 or time==1506 or time ==1507)
        time:=0
      else
        time:=-1*(time-1506)  'change direction to match acc
      intGyroAngle+=time
      gyroReading:=time

PUB MAINLOOP    |temp
    'repeat
     'navigatePSX
    {{
    repeat  'ADDED CODE  for xbee test
      uart.rxflush 
      temp:=uart.rx
      if(temp<>0)
        term.bin(temp,8)'dec(uart.rx)
      
        waitcnt(clkfreq/10+cnt)
        term.out($0D)'term.cls
        term.str(string("rx byte: "))  }}
      
    'newBalanceLoopInfrared
    'newestBalanceLoop
      
               
    
    'term.cls  
    'printScan
    blinkLED
    
    
    'panServoStuff
    'TxRx     
    waitcnt(clkfreq/100+cnt)

      
'uses both gyro and accelerometer data through filtered angle to balance
PUB angleBalanceLoop | speed,dT,delayTime, freq,myFiltAngle,error
    freq:=20 'Hz
    dT:=clkfreq/(freq) 
    setPoint:=6000      'more positive = lean backwards

                 
    term.str(string("waiting for gyro to init..."))
    repeat until accReading <> 0  'wait for gyro to initialize
      blinkLED
      waitcnt(clkfreq/1000+cnt)
    waitcnt(clkfreq + cnt)

    _kP:=40
    _kD:=-6
    _kI:=0
      
    repeat
      delayTime:=cnt+dT
      blinkLED
      myFiltAngle:=filtAngle
      error:=setPoint - myFiltAngle              
      
      speed:=calculateMotor(error)    'method call
      setMotorLeft(speed)
      setMotorRight(speed)
      
      term.cls          
      term.str(string("freq: "))
      term.dec(freq)
      'term.out($0D)             
      term.str(string(" filtAngle: "))
      term.dec(myFiltAngle)
      term.out($0D)
      term.str(string("error: "))
      term.dec(error)
      term.out($0D)        
      term.str(string("setPoint: "))
      term.dec(setPoint)
      term.out($0D)
      term.str(string("motSpeed: "))
      term.dec(speed)
      term.out($0D)
      term.str(string("acc: "))
      term.dec(accAngle)
      term.out($0D)
      term.str(string("gyro: "))  
      term.dec(intGyroAngleDegrees)
      term.out($0D)
      term.str(string("dGyro: "))  
      term.dec(dGyroAngle)
      term.out($0D)
      term.str(string("debug: "))  
      term.dec(debug/80)
      term.out($0d)
      term.str(string("intError: "))  
      term.dec(intError)
      term.out($0d)
      term.str(string("kP: "))
      term.dec(_kP)
      term.out($0d)
      term.str(string("kD: "))
      term.dec(_kD)
      term.out($0d)
      term.str(string("kI: "))
      term.dec(_kI)
      'x from 0 to 319
      'y from 0 to 216
      if(term.button(0))
        if(term.abs_x < 319/2 and term.abs_y <216/2)
          setPoint-=100
        elseif(term.abs_x < 319/2 and term.abs_y >216/2)
          _kP--
        elseif(term.abs_x > 319/2 and term.abs_y >216/2)
          _kD++
        else
          _kI--
      elseif term.button(1)
        if(term.abs_x < 319/2 and term.abs_y <216/2) 
          setPoint+=100
        elseif(term.abs_x < 319/2 and term.abs_y >216/2)
          _kP++
        elseif(term.abs_x > 319/2 and term.abs_y >216/2)
          _kD--
        else
          _kI++
      waitcnt(delayTime)

      
'calculates motor speed based on the error, as well as the past history of error using PD control
'NOTE:for small X, sinX = X (~90% correct up to 44 degrees)  
PUB calculateMotor(error): motorVal            
    if((  error  > 30_000)or (error < -30_000))  'dont even try to balance if fallen past certain point
        motorLeft:=0
        motorRight:=0
    else                                   'otherwise, give PD response
      motorVal:= _kP*P(error)/10  + _kD*D(error)/10  +_kI*I(error)/10
'given the current error, have a response proportional to the current error (1* error)      
PUB P(error):pval
    pval:=error/100 '10 deg = 100%

''given the last 10 error measurements, find rate of change of error
PUB D(error):dval | lastNErrorToUse,index
    lastNErrorToUse:=4  'range from 0 to 9
    if((lastErrorCounter - lastNErrorToUse)<0)  'need to wrap around
      index:=(10+(lastErrorCounter-lastNErrorToUse))
    else
      index:=(lastErrorCounter-lastNErrorToUse)      
    dval:=(error-lastError[index])/100
    setLastError(error) 'update the history of error
PUB I(error):ival |iMin, iMax
    
    iMax:= 1000 'set limit
    intError+=error
    intError<#=iMax                
    intError#>=-1*iMax
    ival:=intError/100
        
'-lastError is a vector with 10 slots, holding the last 10 error values
'-increments lastErrorCounter from 0 -9     
PUB setLastError(newError)
    lastError[lastErrorCounter]:=newError
    lastErrorCounter++
    if(lastErrorCounter==10)
      lastErrorCounter:=0

      
'setMotor functions allow power curve to be manipulated HERE
PUB setMotorLeft(val)
    motorLeft:=smoothMotorValue(val)
PUB setMotorRight(val)
    motorRIght:=smoothMotorValue(val)
PUB smoothMotorValue(val)
    if(val==0)
      return val
    elseif(val>0)
      return val+7
    else 'val negative
      return val-7
    
    

'receives 3 bytes: start, command, data    
PUB TxRx | cmdByte , counter
    'receive data
    counter :=0
    repeat while (uart.rxtime(1000) <> _startByte)
      term.cls
      motorLeft:=motorRight:=0
      term.str(string("waiting for byte..."))
      term.dec(counter++)
    cmdByte :=uart.rx
    case  cmdByte
      1: '0-200
        motorLeft:= uart.rx -100
      2: '0-200
        motorRight:= uart.rx -100
      3: '0-180
        uart.rx 'panServoPosition:= _panServoMin + uart.rx*(_panServoMax-_panServoMin)/180

    'transmit data    
    '
    uart.tx(_stopByte)


'runs on own cog, continuously scans and updates ifraredScan[]
{{PUB scanLoop
   infrared.start(4,6,5)  'start(csPin, doPin, clkPin)      
   repeat
     scan
     pausems(100)
'pans servo 180 degree while measuring distance
PUB scan | ind,dist,_servoTransitTime
   'setPanServoDegree(0)
   'pausems(1000)
   _servoTransitTime:=800
   if getPanServoDegree <>0
     repeat ind from (_scanResolution) to 0
       dist:=infrared.cm
       if dist<20 'if d < 20cm
         infraredScan[ind]:=1
       else
         infraredScan[ind]:=0
       setPanServoDegree(ind*180/_scanResolution)
       pausems(_servoTransitTime/_scanResolution)
     setPanServoDegree(0)
   else
     repeat ind from 0 to (_scanResolution)
       dist:=infrared.cm
       if dist<20 'if d < 20cm
         infraredScan[ind]:=1
       else
         infraredScan[ind]:=0
       setPanServoDegree(ind*180/_scanResolution)
       pausems(_servoTransitTime/_scanResolution)
     setPanServoDegree(180)     

'prints contents of infraredScan   
PUB printScan |ind
   repeat ind from 0 to _scanResolution
     term.dec(infraredScan[ind])   
    
'sets pan servo to specified angle
PUB setPanServoDegree(degree)
    panServoPosition:= _panServoMin + degree*(_panServoMax-_panServoMin)/180  
    panServoPosition := _panServoMin #> panServoPosition <# _panServoMax 
    servos.set(_panServo,panServoPosition)
    
'gets pan servo position in degrees
PUB getPanServoDegree
   result:=(panServoPosition-_panServoMin)/(_panServoMax-_panServoMin)*180
    
                                                              }}
'control drive motors with PSX     
PUB navigatePSX
    if psx.getID <> 115       'controller not in analog mode
      motorRight:=motorLeft:=0
    else
      setMotorValuesFromPSX

'set motor values from PSX     
PUB setMotorValuesFromPSX | rightJoy, leftJoy
    rightJoy :=psx.getJoyRY
    leftJoy := psx.getJoyLY        
    
    rightJoy:=rightJoy - 128
    if rightJoy > 28
      motorRight := -1* (rightJoy-28)
    elseif rightJoy < -28
      motorRight := -1* (rightJoy+28)
    else
      motorRight := 0

    leftJoy:=leftJoy - 128
    if leftJoy > 28
      motorLeft := -1* (leftJoy-28)
    elseif leftJoy < -28
      motorLeft := -1* (leftJoy+28)
    else
      motorLeft := 0

'inits pins/objects/etc       
PUB INITIALIZATION
    motorLeft :=0
    motorRight :=0
    heartBeat :=0
    'setPanServoDegree(90)'panServoPosition := (_panServoMax + _panServoMin)/2
    LEDon
    dira[_LED]~~
    
    term.start(31,30)     'start terminal COG
    term.str(string("starting up"))
    if(_motorOn)
      cognew(motorPWMLoop, @stack[0]) 'start MOTOR cog
    'if(_scanOn)
    '  cognew(scanLoop, @stack2[0]) 'for scanning
    'else
     ' infrared.start(4,6,5)  'start(csPin, doPin, clkPin)
    
    'uart.start(14,15, %0000 , 9600 )'(rxpin, txpin, mode, baudrate) : okay
'' mode bit 0 = invert rx
'' mode bit 1 = invert tx
'' mode bit 2 = open-drain/source tx
'' mode bit 3 = ignore tx echo on rx       
    servos.set(_panServo,1500)
    servos.set(_gyroOut,1500)
    servos.set(_gyroAux, 1485) '1.0 - 1.5ms = normal rate gyro, 1.5-2.0ms = 'heading hold'
    servos.set(_motL,1500)
    servos.set(_motR,1500)
    servos.start     'start servo COG
    '1000   150k= 90deg inc 17
    '1450...23k = 90deg inc 1
    '1485...12k = 90deg inc 1
    '2000...140 = 90deg
    encoderL.start(3,4) 'starts new COG
    encoderR.start(5,6) 'starts new COG
    acc.start(0,1,2)       'start(CS_,DIO_,CLK_):okay does not use own cog, just inits pin #'s                   
    'psx.start(24,25,26,27) 'ddat, cmd, att, clk
    
    term.out($0d)
    cognew(filterLoop,@stack4[0]) 'start filter calculating COG, acc COG
    term.str(string("cog #(0-7): "))
    term.dec(cognew(readGyroLoop, @stack3[0])) 'start gyro PWM COG                  
    

    
    term.str(string("done"))
    pausems(1000)
         
    term.cls
    LEDoff
{{PUB INITIALIZATIONdaq
    motorLeft :=0
    motorRight :=0
    heartBeat :=0
    'setPanServoDegree(90)'panServoPosition := (_panServoMax + _panServoMin)/2
    LEDon
    dira[_LED]~~

    PDAQ.start(31,30,0,9600)                              ' Rx,Tx, Mode, Baud  
    PDAQ.Label(string("Time,Timer,accAng,gyroAng,filtAng"))              ' Label the spreadsheet columns
    PDAQ.ClearData                                        ' Clear present data
    PDAQ.ResetTimer                                       ' Reset timer for seconds interval
    
    if(_motorOn)
      cognew(motorPWMLoop, @stack[0]) 'start MOTOR cog
    
    
    uart.start(14,15, %0000 , 9600 )'(rxpin, txpin, mode, baudrate) : okay
'' mode bit 0 = invert rx
'' mode bit 1 = invert tx
'' mode bit 2 = open-drain/source tx
'' mode bit 3 = ignore tx echo on rx       
    servos.set(_panServo,panServoPosition)
    servos.set(_gyroOut,1500)
    servos.set(_gyroAux, 1485) '1.0 - 1.5ms = normal rate gyro, 1.5-2.0ms = 'heading hold'
    servos.start
    '1000   150k= 90deg inc 17
    '1450...23k = 90deg inc 1
    '1485...12k = 90deg inc 1
    '2000...140 = 90deg
    cognew(filterLoop,@stack4[0]) 'start filter calculating cog         
    cognew(readGyroLoop, @stack3[0])
    'acc.start(0,1,2)       'start(CS_,DIO_,CLK_):okay   MOVED to filter loop                 
    psx.start(24,25,26,27) 'ddat, cmd, att, clk
    
    
    LEDoff    
                     }}
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

'motor control with h-bridges, runs on its own cog
'updates motor speed based on variables motorLeft and motorRight     
 ' pins....18,  21,  16,  17,  19,  20    
' 6 pins....enL, enR, d1L,d2L,d1R,d2R      
PUB motorPWMLoop | dt,motorLeftSpeed,motorRightSpeed, enL, enR

   
    dira[16..21]~~   'change to output
    outa[16..21]~~
    enL:=18
    enR:=21
    dT := 80_000_000/25_000'clkfreq / 25_000             ' 1kHz refresh rate
  
    repeat
      
      motorLeftSpeed:=motorLeft            'set local variable to current state of global one
      motorRightSpeed:=motorRight
      
      motorLeftSpeed<#=100                 'limit input from -100% to 100%
      motorLeftSpeed#>=-100
      motorRightSpeed<#=100
      motorRightSpeed#>=-100

      if motorLeftSpeed==0                      'set motor directions
        outa[16..17]:=%00              'written 2 different ways, both work
      elseif( motorLeftSpeed== (||motorLeftSpeed))
        outa[16..17]:=%10
      else
        outa[16..17]:=%01
      if motorRightSpeed < 0                      
        outa[19..20]:=%01
      elseif motorRightSpeed>0
        outa[19..20]:=%10  
      elseif motorRightSpeed==0
        outa[19..20]:=%00     

      motorLeftSpeed:=(||motorLeftSpeed)              'direction no longer needed, so abs value
      motorRightSpeed:=(||motorRightSpeed)
      
      if(motorLeftSpeed<>0)                        'start pins high
        outa[enL]:=1                               
      if(motorRightSpeed<>0)
        outa[enR]:=1

      'conditions for low duration                       
      if(motorLeftSpeed==0 and motorRightSpeed==0)           
        waitcnt(cnt+dT*100)
      elseif(motorRightSpeed<>0 and motorLeftSpeed==0)
        waitcnt(cnt+dt*(||motorRightSpeed))
        if(||motorRightSpeed<>100)
          outa[enR]:=0
          waitcnt(cnt+dT*(100-||motorRightSpeed) )
      elseif(motorLeftSpeed<>0 and motorRightSpeed==0)
        waitcnt(cnt+dt*(||motorLeftSpeed))
        if(||motorLeftSpeed<>100)
          outa[enL]:=0
          waitcnt(cnt+dT*(100-||motorLeftSpeed) )
      elseif(||motorLeftSpeed == ||motorRightSpeed)
        waitcnt(cnt+dT*(||motorLeftSpeed) )
        if(||motorRightSpeed<>100)
          outa[enL]:=0
          outa[enR]:=0
          waitcnt(cnt+dT*(100-||motorRightSpeed) )
      elseif(||motorLeftSpeed < ||motorRightSpeed)        
        waitcnt(cnt+dT*(||motorLeftSpeed) )
        outa[enL]:=0
        waitcnt(cnt+dT*(||motorRightSpeed-||motorLeftSpeed) )      
        if(||motorRightSpeed<>100)
          outa[enR]:=0             
          waitcnt(cnt+dT*(100-||motorRightSpeed) )
      elseif(||motorRightSpeed < ||motorLeftSpeed)
        waitcnt(cnt+dT*(||motorRightSpeed) )
        outa[enR]:=0
        waitcnt(cnt+dT*(||motorLeftSpeed-||motorRightSpeed) )       
        if(||motorLeftSpeed<>100)
          outa[enL]:=0
          waitcnt(cnt+dT*(100-||motorLeftSpeed) )    
PUB pausems(ms)
  waitcnt(cnt+clkfreq/1000*ms)


                                  