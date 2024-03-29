'' File: balancingBotPEKv1p2.spin
'' Uses PEK to control balancing bot from serial port
''Version 1.1
{{history: 1.0 file started, ps2 controll + motors , servo, uart
           1.1 acc support, ADC + IR ranger, scanning cog added
           1.2 xbee support?
Last updated: 11-8-2007
Known issues: acc doesn't return proportional/continuous data
              ping returns 15cm/5in
                                                        
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
    10     
    11     
    12     
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
    1: controls motor PWM
    2: actuates scanning servo + measurements
    3: controls servos
    4:
    5:
    6:
    7:
                                                 }}
VAR
    long motorLeft   'duty cycle, -100 to 100 indicating %
    long motorRight
    long panServoPosition '1000 to 2000
    long heartBeat  'for blinking the LED
    long stack[60] 'for motor cog
    long stack2 [100] 'for scan cog, 100 is sufficient for 2 deg resolution
    long timer
    long infraredScan[_scanResolution]
    
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
    _LED = 7
    _ultrasonicPin = 13
    _panServo = 22
    _panServoMin = 600    '0 degrees
    _panServoMax = 2450    '180 degrees
    _startByte = $FE
    _stopByte = $FE
    _scanResolution=90
    

OBJ
    term:   "PC_Interface"
    acc:    "H48C Tri-Axis Accelerometer"       
    psx:    "ps2ControllerV1p2d"
    servos: "Servo32"
    uart:   "FullDuplexSerial"
    ultrasonic: "Ping"
    infrared: "ADC0831"    
PUB main

    INITIALIZATION
        
    repeat    
      'mainLoop2
      MAINLOOP
      

PUB mainLoop2  |counter
    counter:=cnt + clkfreq/2
    repeat  while cnt< counter
      uart.tx($FF)
    counter:=cnt + clkfreq/2    
    repeat  while cnt< counter
      
    
PUB MAINLOOP

    clearScreenPrint           
    'navigatePSX   
    
    blinkLED
    
    'panServoStuff
    'TxRx     
    waitcnt(clkfreq/10+cnt)

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
PUB scan | i,d,_servoTransitTime
   'setPanServoDegree(0)
   'pausems(1000)
   _servoTransitTime:=800
   if getPanServoDegree <>0
     repeat i from (_scanResolution) to 0
       d:=infrared.cm
       if d<20 'if d < 20cm
         infraredScan[i]:=1
       else
         infraredScan[i]:=0
       setPanServoDegree(i*180/_scanResolution)
       pausems(_servoTransitTime/_scanResolution)
     setPanServoDegree(0)
   else
     repeat i from 0 to (_scanResolution)
       d:=infrared.cm
       if d<20 'if d < 20cm
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
    term.dec(ultrasonic.centimeters(_ultrasonicPin))
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
    
{{'moves the servo position based on PSX controller        
PUB panServoStuff
    if psx.getThumbR & %0000_0010 == 0
      panServoPosition +=50
    elseif psx.getThumbR & %0000_0001 == 0
      panServoPosition -=50
    panServoPosition := _panServoMin #> panServoPosition <# _panServoMax 
    servos.set(_panServo,panServoPosition)  }}


         

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
   ' repeat while term.abs_x == 0    'wait for PropTerminal.exe started
    term.str(string("starting up"))
    
    cognew(motorPWMLoop, @stack[0]) 'start MOTOR cog
    cognew(scanLoop, @stack2[0]) 'for scanning
    uart.start(14,15, 3 , 9600 )'(rxpin, txpin, mode, baudrate) : okay
'' mode bit 0 = invert rx
'' mode bit 1 = invert tx
'' mode bit 2 = open-drain/source tx
'' mode bit 3 = ignore tx echo on rx       
    servos.set(_panServo,panServoPosition)
    servos.start
    acc.start(0,1,2)       'start(CS_,DIO_,CLK_):okay                    
    psx.start(24,25,26,27) 'ddat, cmd, att, clk             
    

    
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

'motor control, runs on its own cog
'updates motor speed based on variables motorLeft and motorRight     
 ' pins....18,  21,  16,  17,  19,  20    
' 6 pins....enL, enR, d1L,d2L,d1R,d2R      
PUB motorPWMLoop | dt,motorLeftSpeed,motorRightSpeed, enL, enR

   
    dira[16..21]~~   'change to output
    outa[16..21]~~
    enL:=18
    enR:=21
    dT := clkfreq / 25_000             ' 1kHz refresh rate
  
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


PUB API  ' API of objects used
  {{
OBJECT "Ir Detector"
  PUB init(irLedPin, irReceiverPin)
  PUB object :state | pin, freq, dur
  PUB distance :dist | pin, freq, dur

                                              }}                                      