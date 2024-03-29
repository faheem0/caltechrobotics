'' File: balancingBotPEKv2p1.spin
'' Uses PEK to control balancing bot from serial port
''Version 2.1
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
Last updated: 12-29-2007
Known issues: ping returns 15cm/5in
              xbee doesn't work with usb-serial/Java    ?
              does not balance! direction of derivative component?
              jittery oscillations!!
              
Stuff to tune:
  kP
  kD
  last nth measurement used for derivative term
  refresh rate (frequency)
  motor deadband
                                                        
                                  }}
{{ PIN   Purpose    Input  Output
    0     acc-CS             X
    1     acc-DIO    X       X
    2     acc-CLK            X
    3     
    4     ADC-CS             X
    5     ADC-CLK            X
    6     ADC-DO     X
    7     LED                X    
    8     
    9    
    10    gyroAux            X
    11    gyroOut            X
    12    gyroIn     X
    13     ultrasonicX       X                          
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
    0: main cog
    1: terminal window
    2: motor PWM
    3: scanning servo + IR measurements
    4: uart
    5: servos
    6: acc
    7: psx
   (8): gyro
    
                                                 }}
VAR
    long motorLeft   'duty cycle, -100 to 100 indicating %
    long motorRight
    long panServoPosition '1000 to 2000
    long heartBeat  'for blinking the LED
    long stack[60] 'for motor cog
    long stack2 [100] 'for scan cog, 100 is sufficient for 2 deg resolution
    long stack3[30] 'for gyro PWM reading cog
    long timer
    long infraredScan[_scanResolution]
    long setPoint
    long lastErrorAcc[10]
    long lastErrorCounterAcc
    long lastGyro[10]
    long lastCounterGyro
    long gyroReading
    long gyroAngle
    
    
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll8x                ' 5 MHz crystal multiplied → 80 MHz
    _LED = 7
    _gyroIn = 12
    _gyroOut = 11
    _gyroAux = 10
    _ultrasonicPin = 13
    _panServo = 22
    _panServoMin = 600    '0 degrees
    _panServoMax = 2450    '180 degrees
    _startByte = $FE
    _stopByte = $FE
    _scanResolution=10
    _scanOn = 0                        'TURN SCAN ON/OFF HERE
    _motorOn = 0                       'TURN MOTORS ON/OFF HERE

    _kP =7'10'12 'for 7.2V
    _kD =0 '5'7  'for 7.2V
    _kPg =70
    _kDg = 0'-30
    '_kPIR = 130
    '_KDIR = 60
    

OBJ
    term:   "PC_Interface"
    PDAQ : "PLX-DAQ"
    acc:    "H48C Tri-Axis Accelerometer"       
    psx:    "ps2ControllerV1p2d"
    servos: "Servo32"
    uart:   "FullDuplexSerial"
    ultrasonic: "Ping"
    infrared: "ADC0831"    
PUB main

    'INITIALIZATION
    INITIALIZATIONdaq
    printAngleDAQ
    printAngle
    'printAcc
    printGyro    
    repeat    
      'mainLoop2
      MAINLOOP
pub printAngleDAQ |a,accReading,accAngle,ref,intGyroAngle,filtAngle,delayTime,printCount,dGyroAngle,lastGyroAngle
    a:=98 'adjust complementary filter,0-100
    LEDon
    repeat 2  'pause for 4 seconds to allow gyro to initialize
      waitcnt(clkfreq+cnt)
      LEDon
      waitcnt(clkfreq+cnt)       
      LEDoff
    gyroAngle:=0
    lastGyroAngle:=gyroAngle

    'angle calculation loop, limited to ~200Hz by acc, ~500Hz by gyro
    repeat
      blinkLED
      timer:=cnt
      delayTime:=clkfreq/100+cnt  'aim for 100Hz
      accReading:=acc.z
      ref:=490'acc.vref 'reading for 1g
      'this is a comment
      ' :=is assignment operator
      accAngle:=accReading*1000/ref*57 'works!  scales acc's reading into degrees
      intGyroAngle:=gyroAngle*1000/133  'works!  scales integrated gyro angle into degrees
      dGyroAngle:=intGyroAngle-lastGyroAngle '? reversed?-gets change in integrated gyro angle since last loop
      lastGyroAngle:=intGyroAngle 'update lastGyroAngle with the current one for the next loop
      filtAngle:=a*(filtAngle+dGyroAngle)/100 + (100-a)*accAngle/100
      'filtAngle:= 98*intGyroAngle/100 + 2 *accAngle/100  needs high pass
      timer:=(cnt-timer)/40  '388us
      if(printCount:=10)
        'timer:=cnt
        
        PDAQ.DataText(string("TIME,TIMER"))               ' Place current time and time since reset
        PDAQ.DataDiv(accAngle,1000)                                  ' Send data of angle
        PDAQ.DataDiv(intGyroAngle,1000)
        PDAQ.DataDiv(filtAngle,1000)                     ' Send data of sin of angle / 1000
        PDAQ.CR                                           ' End of data for row
        'Row:=PDAQ.RowGet                                  ' Read current row
        'If Row => 300                                     ' Greater than 300?
        '   PDAQ.RowSet(2)                                     ' back to row 2
        '   PDAQ.Msg(string("Restarting Data"))                ' Post message to control            
        'Pause(100)                                        ' 100mSec Pause
        {{term.cls
        term.str(string("Acc angle: "))  
        term.dec(accAngle)
        term.out($0d)
        term.str(string("Gyro angle: "))
        term.dec(intGyroAngle)
        term.out($0d)
        term.str(string("gyro reading: "))
        term.dec(gyroReading)
        term.out($0d)
        term.str(string("Filtered angle: "))
        term.dec(filtAngle)
        term.out($0d)        
        term.str(string("timer: "))
        'timer:=(cnt-timer)/40  '16ms
        term.dec(timer)
        term.str(string(" us"))
        printCount:=0             }}
        delayTime:=clkfreq/100+cnt 
      printCount++
      
      
      waitcnt(delayTime) 'wait until 10ms has passed for precise 100Hz operation
pub printAngle |a,accReading,accAngle,ref,intGyroAngle,filtAngle,delayTime,printCount,dGyroAngle,lastGyroAngle
    a:=98 'adjust complementary filter,0-100
    LEDon
    repeat 2  'pause for 4 seconds to allow gyro to initialize
      waitcnt(clkfreq+cnt)
      LEDon
      waitcnt(clkfreq+cnt)       
      LEDoff
    gyroAngle:=0
    lastGyroAngle:=gyroAngle

    'angle calculation loop, limited to ~200Hz by acc, ~500Hz by gyro
    repeat
      timer:=cnt
      delayTime:=clkfreq/100+cnt  'aim for 100Hz
      accReading:=acc.z
      ref:=490'acc.vref 'reading for 1g
      'this is a comment
      ' :=is assignment operator
      accAngle:=accReading*1000/ref*57 'works!  scales acc's reading into degrees
      intGyroAngle:=gyroAngle*1000/133  'works!  scales integrated gyro angle into degrees
      dGyroAngle:=intGyroAngle-lastGyroAngle '? reversed?-gets change in integrated gyro angle since last loop
      lastGyroAngle:=intGyroAngle 'update lastGyroAngle with the current one for the next loop
      filtAngle:=a*(filtAngle+dGyroAngle)/100 + (100-a)*accAngle/100
      'filtAngle:= 98*intGyroAngle/100 + 2 *accAngle/100  needs high pass
      timer:=(cnt-timer)/40  '388us
      if(printCount:=10)
        'timer:=cnt
        term.cls
        term.str(string("Acc angle: "))  
        term.dec(accAngle)
        term.out($0d)
        term.str(string("Gyro angle: "))
        term.dec(intGyroAngle)
        term.out($0d)
        term.str(string("gyro reading: "))
        term.dec(gyroReading)
        term.out($0d)
        term.str(string("Filtered angle: "))
        term.dec(filtAngle)
        term.out($0d)        
        term.str(string("timer: "))
        'timer:=(cnt-timer)/40  '16ms
        term.dec(timer)
        term.str(string(" us"))
        printCount:=0
        delayTime:=clkfreq/100+cnt
      printCount++
      
      
      waitcnt(delayTime) 'wait until 10ms has passed for precise 100Hz operation
pub printAcc |accReading,accAngle,ref
    repeat
      accReading:=acc.z
      ref:=490'acc.vref
      accAngle:=accReading*1000/ref*57 'works!
      term.dec(accReading)
      term.str(string(" "))
      term.dec(ref)
      term.str(string(" "))
      term.dec(accAngle)
      term.str(string(" degrees"))
      
      term.out($0d)
      waitcnt(cnt+clkfreq/10)
'loops and prints out gyro reading
pub printGyro |intAngle
    
    repeat
      intAngle:=gyroAngle*1000/133  'works!
      term.dec(gyroReading)
      term.str(string(" "))
      term.dec(gyroAngle)
      term.str(string(" "))
      term.dec(intAngle)
      term.str(string(" "))
      term.dec(timer/80)
      term.out($0d)
      waitcnt(cnt+clkfreq/10)
      
'runs in its own cog
'updates gyroReading with gyro reading (-? to ?), negative = leaning forward (by software)  
PUB readGyroLoop |time,angle,tempTimer      
    dira[_gyroIn]:=0 'input
    waitcnt(clkfreq*1+cnt)
    repeat
      waitpne(|< _gyroIn, |< _gyroIn, 0) 'Wait for Pin 12 to go low
      waitpeq(|< _gyroIn, |< _gyroIn, 0) 'Wait for Pin 12 to go high
      time:=cnt
      'timer:=cnt -tempTimer
      waitpne(|< _gyroIn, |< _gyroIn, 0) 'Wait for Pin 12 to go low
      time:=(cnt-time)
      tempTimer:=cnt
      time:=time/40'converts to us
      if(time==1505 or time==1506 or time ==1507)
        time:=0
      else
        time:=-1*(time-1506)
      'time:=time
      gyroAngle+=time
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
    newestBalanceLoop
      
    clearScreenPrint           
    
    'term.cls  
    'printScan
    blinkLED
    
    
    'panServoStuff
    'TxRx     
    waitcnt(clkfreq/100+cnt)

      
'uses both gyro and accelerometer data to balance
PUB newestBalanceLoop |meas,nextMeas, speed,dT,count, freq,currentError,gyroMeas  
    freq:=20 'Hz
    dT:=clkfreq/(freq*5) '5 measurement samples averaged, spaced out in loop
    setPoint:=37'32      'more positive = lean backwards
    lastErrorCounterAcc:=0
      
    repeat
      count:=cnt+dT
      blinkLED
      meas:=nextMeas/5
      currentError:=setPoint - meas
      'setLastError(currentError)
      nextMeas:=acc.z          
      timer:=cnt  'start timer
      term.cls
      gyroMeas:=gyroReading
      speed:=calculateMotor(currentError)+calculateMotorGyro(gyroMeas)    'method call
      setMotorLeft(speed)
      setMotorRight(speed)
      waitcnt(count)
      count:=cnt+dT
      nextMeas+=acc.z       
      timer:=cnt-timer  'stop timer
      
      term.str(string("freq?: "))
      term.dec(clkfreq/timer)
      term.out($0D)
      waitcnt(count)
      count:=cnt+dT
      nextMeas+=acc.z      
      term.str(string("gyro: "))
      term.dec(gyroMeas)
      term.out($0D)
      term.str(string("measurement: "))
      term.dec(meas)
      term.out($0D)
      waitcnt(count)
      count:=cnt+dT
      nextMeas+=acc.z
      term.str(string("setPoint: "))
      term.dec(setPoint)
      term.out($0D)
      waitcnt(count)
      count:=cnt+dT
      nextMeas+=acc.z       
      waitcnt(count)

      
'calculates motor speed based on the error, as well as the past history of error using PD control
'NOTE:for small X, sinX = X (~90% correct up to 44 degrees)  
PUB calculateMotor(error): motorVal            
    if((  error  > 300)or (error < -300))  'dont even try to balance if fallen past certain point
        motorLeft:=0
        motorRight:=0
    else                                   'otherwise, give PD response
      motorVal:= _kP*P(error)/10  + _kD*D(error)/10
PUB calculateMotorGyro(reading): motorVal
    motorVal:= _kPg*reading/10 +_kDg*Dgyro(reading)/10
'given the current error, have a response proportional to the current error (1* error)      
PUB P(error):pval
    pval:=error

''given the last 10 error measurements, find rate of change of error
PUB D(error):dval | lastNErrorToUse,index
    lastNErrorToUse:=4  'range from 0 to 9
    if((lastErrorCounterAcc - lastNErrorToUse)<0)  'need to wrap around
      index:=(10+(lastErrorCounterAcc-lastNErrorToUse))
    else
      index:=(lastErrorCounterAcc-lastNErrorToUse)      
    dval:=error-lastErrorAcc[index]
    setLastError(error) 'update the history of error
PUB Dgyro(newReading):dval |lastNReadingToUse,index
    lastNReadingToUse:=4  'range from 0 to 9
    if((lastCounterGyro - lastNReadingToUse)<0)  'need to wrap around
      index:=(10+(lastCounterGyro-lastNReadingToUse))
    else
      index:=(lastCounterGyro-lastNReadingToUse)      
    dval:=newReading-lastGyro[index]
    setLastGyro(newReading) 'update the history of error
        
'-lastError is a vector with 10 slots, holding the last 10 error values
'-increments lastErrorCounterAcc from 0 -9     
PUB setLastError(newError)
    lastErrorAcc[lastErrorCounterAcc]:=newError
    lastErrorCounterAcc++
    if(lastErrorCounterAcc==10)
      lastErrorCounterAcc:=0
PUB setLastGyro(newReading)
    lastGyro[lastCounterGyro]:=newReading
    lastCounterGyro++
    if(lastCounterGyro==10)
      lastCounterGyro:=0
'setMotor functions allow power curve to be manipulated HERE
PUB setMotorLeft(val)
    motorLeft:=smoothMotorValue(val)
PUB setMotorRight(val)
    motorRIght:=smoothMotorValue(val)
PUB smoothMotorValue(val)
    if(val==0)
      return val
    elseif(val>0)
      return val-15
    else 'val negative
      return val+15
    
    

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
        setPanServoDegree(uart.rx) 'panServoPosition:= _panServoMin + uart.rx*(_panServoMax-_panServoMin)/180

    'transmit data    
    uart.tx(ultrasonic.Inches(_ultrasonicPin))
    uart.tx(_stopByte)


'runs on own cog, continuously scans and updates ifraredScan[]
PUB scanLoop
   infrared.start(4,6,5)  'start(csPin, doPin, clkPin)      
   repeat
     scan
     pausems(100)
'pans servo 180 degree while measuring distance
PUB scan | i,dist,_servoTransitTime
   'setPanServoDegree(0)
   'pausems(1000)
   _servoTransitTime:=800
   if getPanServoDegree <>0
     repeat i from (_scanResolution) to 0
       dist:=infrared.cm
       if dist<20 'if d < 20cm
         infraredScan[i]:=1
       else
         infraredScan[i]:=0
       setPanServoDegree(i*180/_scanResolution)
       pausems(_servoTransitTime/_scanResolution)
     setPanServoDegree(0)
   else
     repeat i from 0 to (_scanResolution)
       dist:=infrared.cm
       if dist<20 'if d < 20cm
         infraredScan[i]:=1
       else
         infraredScan[i]:=0
       setPanServoDegree(i*180/_scanResolution)
       pausems(_servoTransitTime/_scanResolution)
     setPanServoDegree(180)     

'prints contents of infraredScan   
PUB printScan |i
   repeat i from 0 to _scanResolution
     term.dec(infraredScan[i])   
    
'sets pan servo to specified angle
PUB setPanServoDegree(degree)
    panServoPosition:= _panServoMin + degree*(_panServoMax-_panServoMin)/180  
    panServoPosition := _panServoMin #> panServoPosition <# _panServoMax 
    servos.set(_panServo,panServoPosition)
    
'gets pan servo position in degrees
PUB getPanServoDegree
   result:=(panServoPosition-_panServoMin)/(_panServoMax-_panServoMin)*180
    
 'clears screen and prints stuff out      
PUB clearScreenPrint
    term.cls
    'term.bin(psx.getThumbR,8)
    term.str(string("ultrasonic: "))
    'term.dec(ultrasonic.centimeters(_ultrasonicPin))
    term.str(string(" cm"))
    term.out($0D)  'CR
    term.str(string("infrared ranger: "))
    term.dec(infrared.cm)
    term.str(string(" cm"))
    term.out($0D)  'CR 
    term.str(string("accelerometer x: "))
    term.dec((acc.x))
    term.out($0D)  'CR
    term.str(string("accelerometer y: "))
    term.dec((acc.y))
    term.out($0D)  'CR
    term.str(string("accelerometer z: "))
    term.dec((acc.z))
    
    'term.dec(psx.JoyRY)
    'term.str(string(" "))
    'term.dec(psx.JoyLY)   
    
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
    setPanServoDegree(90)'panServoPosition := (_panServoMax + _panServoMin)/2
    LEDon
    dira[_LED]~~
    
    term.start(31,30)
    term.str(string("starting up"))
    if(_motorOn)
      cognew(motorPWMLoop, @stack[0]) 'start MOTOR cog
    if(_scanOn)
      cognew(scanLoop, @stack2[0]) 'for scanning
    else
      infrared.start(4,6,5)  'start(csPin, doPin, clkPin)
    
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
    
    acc.start(0,1,2)       'start(CS_,DIO_,CLK_):okay                    
    psx.start(24,25,26,27) 'ddat, cmd, att, clk
    
    term.out($0d)
    term.str(string("cog #: "))
    term.dec(cognew(readGyroLoop, @stack3[0])) 'start gyro PWM cog                  
    

    
    term.str(string("done"))
    pausems(1000)
         
    term.cls
    LEDoff
PUB INITIALIZATIONdaq
    motorLeft :=0
    motorRight :=0
    heartBeat :=0
    setPanServoDegree(90)'panServoPosition := (_panServoMax + _panServoMin)/2
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
    cognew(readGyroLoop, @stack3[0])
    acc.start(0,1,2)       'start(CS_,DIO_,CLK_):okay                    
    psx.start(24,25,26,27) 'ddat, cmd, att, clk
    
    
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

'motor control, runs on its own cog
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


                                  