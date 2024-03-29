'' File: balancingBotPEKv2p8.spin
'' Uses PEK to control balancing bot/segway, adjust PID values and setPoint thru terminal
''Version 4.2
''3/28/2008
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
           2.7 does it work?  gyro output drifts some...need to remount gyro
           2.8 fixing oscillation after remounted gyro,motor PID?
           3.0 24v, motorPIDloop added, needs tuning
           3.1 graph!
           3.2 working on graph, multiple channels supported
           4.0 segway controlled from playstation controller, will tune PID motor loop, h-bridges removed, cleaned up
           4.1 PSX no longer uses own cog, motor PID testing using psx using serialPlot (java)
           4.2 PID tuning...
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
    16     
    17        
    18     
    19             
    20     
    21    
    22     servo             X
    23     
    24     psx-DAT   X 
    25     psx-CMD           X
    26     psx-ATT           X
    27     psx-CLK           X              }}
{{COG usage:
  X  0: main cog
  X  1: terminal window/DAQ/graph
     
     
     4: uart (xbee?)
  X  5: servo PWM: servos, gyros, v883's

  X (8): gyro PWM reading
  X (9): filter calculating
  X  (10): encoder #1
  X  (11): encoder #2
      (12): motor PID loop
    
                                                 }}
VAR
    long motorLeft   'duty cycle for h-bridges, -100 to 100 indicating %
    long motorRight
    
    long heartBeat  'for blinking the LED
    long stack[60] 'for motor cog
    'long stack2 [100] 'for scan cog, 100 is sufficient for 2 deg resolution
    long stack3[30] 'for gyro PWM reading cog
    long stack4[30] 'for filter cog
    long timer
    

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
    long filtAngle,filtAngle2,filtAngle3,filtAngle4    'filtered angle
    long debug
    long _kP,_kD,_kI
    byte myByte
    
    
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
    
    _motLFullReverse = 1146    'experimentally determined v883 PWM values
    _motLMinReverse = 1489+20
    _motLMinForward =  1558-20
    _motLFullForward =  1915
    _motRFullReverse = 1168
    _motRMinReverse = 1488+20
    _motRMinForward =  1556-20
    _motRFullForward =  1906

    'encoder has resolution of 24, gearbox has raio of 32, 24*32=768 counts/wheel rev
        '1mp ~= 88 feet per minute, wheel circumference= 3.14*(1 foot) = 3.14 feet
        '
    _motMaxSpeed=1100'430 'counts/second
    
    _startByte = $FE
    _stopByte = $FE
    _scanResolution=10
    

    _NEXT_TIME_BYTE=254

    '_kP =40'10'12 'for 7.2V
    '_kD =-5'5'7  'for 7.2V
    '_kI = 0
    

OBJ
    term:   "PC_Interface"
    PDAQ : "PLX-DAQ"
    acc:    "H48C Tri-Axis AccelerometerNoNewCog"       
    psx:    "ps2ControllerV1p1" '"ps2ControllerV1p2d"
    servos: "Servo32"
    uart:   "FullDuplexSerial"
    encoderL: "encoderCustomASM"
    encoderR: "encoderCustomASM"
    graph:  "FullDuplexSerial"
PUB main
    
    INITIALIZATION
    'v883motorPWMTest
    'v883motorPWMTestPSX
    PIDmotorLoop(1)
    'printAngle
    'printAngleDAQ
     printAngleGraph
    'printGyro
    'angleBalanceLoop  



'tests v883 and encoders         
PUB v883motorPWMTest| refreshPerSec,PWMValue,cntStart,cntFinish,temp,lastPosR, currentPosR,rpmR,lastPosL, currentPosL,rpmL
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
        
    servos.set(_motR,PWMValue)
    servos.set(_motL,PWMValue) 
    PWMValue<#= 2000                
    PWMValue#>=1000

    currentPosR:=encoderR.getPos
    currentPosL:=encoderL.getPos
    rpmR:= (currentPosR-lastPosR)*refreshPerSec*60/24/32
    rpmL:= (currentPosL-lastPosL)*refreshPerSec*60/24/32
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
    term.str(string("countsL: "))
    term.dec(currentPosL-lastPosL)
    term.str(string("countsR: "))
    term.dec(currentPosR-lastPosR)
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
    {{'768/24=32          'for use with wheel rotation IR sensor on pin 23
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
PUB v883motorPWMTestPSX| motorLeftRamped,ramp, motorRightRamped,refreshPerSec,cntStart,cntFinish,temp,lastPosR, currentPosR,rpmR,lastPosL, currentPosL,rpmL
 
 refreshPerSec:=5
 ramp:=80
 motorRightRamped:=0
 motorLeftRamped:=0
 repeat
    temp:=cnt+clkfreq/refreshPerSec

    
    navigatePSX                
    motorRightRamped:= (ramp*motorRightRamped+ (100-ramp)*motorRight)/100
    motorLeftRamped:= (ramp*motorLeftRamped+ (100-ramp)*motorLeft)/100    
    setMotorLeft(motorLeftRamped)
    setMotorRight(motorRightRamped) 


    currentPosR:=encoderR.getPos
    currentPosL:=encoderL.getPos
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
        term.str(string("dgyro: "))
        term.dec(dGyroAngle)
        term.out($0d)
        term.str(string("Filtered angle: "))
        term.dec(filtAngle)
        term.out($0d)        
             
        waitcnt(delayTime)        

pub printAngleGraph |delayTime , tmp,counter
    'term.str(string("waiting for gyro to init..."))  
    repeat until accReading <> 0
      blinkLED
      waitcnt(clkfreq/1000+cnt)

    counter:=-100
    myByte:=0
    repeat 'until myByte ==$FF     'test code
      graph.tx(counter)
      graph.tx(counter*3/2)
      graph.tx(counter*2) 
      graph.tx(-1*counter)
      graph.tx(_NEXT_TIME_BYTE)
      'graph.tx(myByte)' counter)
      'graph.tx(myByte)' counter)
      counter++
      myByte++
      if counter == 50
        counter:=-100
       'myByte>>=1
       'if(myByte==0)
       '  myByte:=%1000_0000
      waitcnt(cnt+clkfreq/100)'50)
    repeat   
    repeat    
        delayTime:=cnt+clkfreq/50'10
        tmp:=filtAngle/100
        if(tmp<0)
          tmp:= ||tmp
        else
          tmp+=128
        graph.tx(tmp)
        'graph.tx(counter & $FF)
        
        counter:=(counter+1) // 256
        
        {{term.str(string("Gyro angle (deg): "))
        term.dec(intGyroAngleDegrees)
        term.out($0d)
        term.str(string("gyro reading: "))
        term.dec(gyroReading)
        term.out($0d)
        term.str(string("dgyro: "))
        term.dec(dGyroAngle)
        term.out($0d)
        term.str(string("Filtered angle: "))
        term.dec(filtAngle)
        term.out($0d)      }}  
             
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
'updates accReading, accAngle, intGyroAngleDegrees, dGyroAngle, and filtAngle
'runs at 100Hz, actual loop takes 1.8ms out of 10ms
PUB filterLoop |a,delayTime,lastGyroAngle,myTimer
    a:=80'98                  'adjust complementary filter,0-100
    
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
      filtAngle2:=90*(filtAngle+dGyroAngle)/100 + (100-90)*accAngle/100     'ANGLE CALCULATION HERE
      filtAngle3:=98*(filtAngle+dGyroAngle)/100 + (100-98)*accAngle/100     'ANGLE CALCULATION HERE
      filtAngle4:=99*(filtAngle+dGyroAngle)/100 + (100-99)*accAngle/100     'ANGLE CALCULATION HERE
      '388us
      'debug:=myTimer-cnt
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
      debug:=time
      if(time==1508 or time==1509 or time ==1510 or time ==1511)
        time:=0
      else
        time:=-1*(time-1509)  'change direction to match acc
      intGyroAngle+=time
      gyroReading:=time


      
'uses both gyro and accelerometer data through filtered angle to balance
PUB angleBalanceLoop | speed,dT,delayTime, freq,myFiltAngle,error
    freq:=20 'Hz
    dT:=clkfreq/(freq) 
    setPoint:=2300'7400      'more positive = lean backwards

                 
    term.str(string("waiting for gyro to init..."))
    repeat until accReading <> 0  'wait for gyro to initialize
      blinkLED
      waitcnt(clkfreq/1000+cnt)
    waitcnt(clkfreq + cnt)

    _kP:=10
    _kD:=0
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
      term.dec(debug)
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
    setSegwayLeft(val)
    'motorLeft:=smoothMotorValue(val)
PUB setMotorRight(val)
    setSegwayRight(val)
    'motorRIght:=smoothMotorValue(val)
PUB setSegwayLeft(val)
    if ||val < 3
      val:=0
    val<#=100                
    val#>=-100
    if(val==0)  'stopped
      servos.set(_motL,(_motLMinReverse+_motLMinForward)/2)
    elseif val< 0 'reverse
      servos.set(_motL,_motLMinReverse -(_motLMinReverse-_motLFullReverse)*-1*val/100)
    else 'forward
      servos.set(_motL,(_motLFullForward-_motLMinForward)*val/100+_motLMinForward)
PUB setSegwayRight(val)
    if ||val < 3
      val:=0
    val<#=100                
    val#>=-100
    if(val==0)  'stopped
      servos.set(_motR,(_motRMinReverse+_motRMinForward)/2)
    elseif val< 0 'reverse
      servos.set(_motR,_motRMinReverse -(_motRMinReverse-_motRFullReverse)*-1*val/100)
    else 'forward
      servos.set(_motR,(_motRFullForward-_motRMinForward)*val/100+_motRMinForward)   
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

 
'control drive motors with PSX     
PUB navigatePSX
    psx.update
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
    
    LEDon
    dira[_LED]~~
    
    term.start(31,30)     'start terminal COG
    term.str(string("starting up"))
    graph.start(14,15,%0010,9600)                              ' Rx,Tx, Mode, Baud
        
    'uart.start(14,15, %0000 , 9600 )'(rxpin, txpin, mode, baudrate) : okay
'' mode bit 0 = invert rx
'' mode bit 1 = invert tx
'' mode bit 2 = open-drain/source tx
'' mode bit 3 = ignore tx echo on rx       
    
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
    psx.start(24,25,26,27) 'ddat, cmd, att, clk
    
    term.out($0d)
    term.str(string("cog #(0-7): "))      
    term.dec(cognew(filterLoop,@stack4[0])) 'start filter calculating COG, acc COG
    
    term.dec(cognew(readGyroLoop, @stack3[0])) 'start gyro PWM COG            

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
PUB PIDmotorLoop(debugGraph) | motorRightRamped, motorLeftRamped, ramp,avgVelLeft,avgVelRight,freq, delay,motorLeftSpeed,motorRightSpeed,errorL,errorR , kmPr,kmDr,kmPl,kmDl ,velLeft,lastVelLeft,lastVelRight, velRight, accLeft, accRight,encCountLeft, encCountRight,valLeft, valRight,temp
    '1.2mph=33.6 wheel rpm = 430 encoder counts/second
    'at 24V, 80 cnts/sample
    '20Hz ~21 counts/sample
    freq:=20 'Hz
    ramp:=80
    
    kmPr:=7  'proportionality gain
    kmDr:=-6'-2   'derivative gain (make negative)
    kmPl:=4
    kmDl:=-6
    
    'initialize variables
    valLeft:=0
    valRight:=0
    lastVelLeft:=0
    lastVelRight:=0
    motorRightRamped:=0
    motorLeftRamped:=0
    
    
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
      temp:=encoderL.getPos          'update position counter and current velocity
      velLeft:=encCountLeft-temp
      encCountLeft:=temp      
      temp:=encoderR.getPos
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
       

      setMotorLeft(valLeft)        'actually set motor speed here
      setMotorRight(valRight)

      avgVelRight:= (8*avgVelRight+velRight*100*freq/_motMaxSpeed*2)/10   'put motor speed thru low pass, make more readable
      avgVelLeft:= (8*avgVelLeft+velLeft*100*freq/_motMaxSpeed*2)/10

      'graph data to serialPlot (java)
      if debugGraph==1
        if( 1==0)   'graph right side
          graph.tx(motorRightSpeed)           'setpoint
          graph.tx(avgVelRight)   'actual velocity
          graph.tx(valRight)                    ' signal output to motor
          graph.tx(kmPr*10)
          graph.tx(kmDr*10)
        else       'or graph left side
          graph.tx(motorLeftSpeed)           'setpoint
          graph.tx(avgVelLeft)   'actual velocity
          graph.tx(valLeft)                    ' signal output to motor
          graph.tx(kmPl*10)
          graph.tx(kmDl*10)
         
        graph.tx(_NEXT_TIME_BYTE)
         
        term.cls                               'print PID constants for tuning
        term.str(string("kmPr: "))
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
        term.dec(valRight)
      {{
      
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
      term.str(string("us left"))    }}
      
      waitcnt(delay)                        'wait to achieve desired update frequency

 
PUB pausems(ms)
  waitcnt(cnt+clkfreq/1000*ms)


                                  