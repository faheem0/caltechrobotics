'' File: balancingBotPEK.spin
'' Uses PEK to control balancing bot from serial port
''Version 1.0
{{history: 1.0 file started, ps2 controll + motors , servo, uart
Last updated: 11-1-2007
      doesn't work with txrx?    
                                                        
                                  }}
{{ PIN   Purpose    Input  Output
    0     acc-CS             X
    1     acc-DIO    X       X
    2     acc-CLK            X
    3     
    4    
    5     
    6     
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
VAR
    long motorLeft   'duty cycle, -100 to 100 indicating %
    long motorRight
    long panServoPosition '1000 to 2000
    long heartBeat  'for blinking the LED
    long stack[60] 'for motor cog
    long timer
    
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
    
    

OBJ
    term:   "PC_Interface"
    acc:    "H48C Tri-Axis Accelerometer"       
    psx:    "ps2ControllerV1p2d"
    servos: "Servo32"
    uart:   "FullDuplexSerial"
    ultrasonic: "Ping"          
PUB main

    initStuff
        
    repeat    
      mainLoop

      
PUB mainLoop

    clearScreenPrint           
    'navigatePSX   
    
    blinkLED
    'blinkLEDwithUART
    panServoStuff
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
        panServoPosition:= _panServoMin + uart.rx*(_panServoMax-_panServoMin)/180

    'transmit data    
    uart.tx(ultrasonic.Inches(_ultrasonicPin))
    uart.tx(_stopByte)
        
 'clears screen and prints stuff out      
PUB clearScreenPrint
    term.cls
    'term.bin(psx.getThumbR,8)
    term.dec(ultrasonic.Inches(_ultrasonicPin))
    'term.dec(psx.JoyRY)
    'term.str(string(" "))
    'term.dec(psx.JoyLY)   
    
'moves the servo position based on PSX controller        
PUB panServoStuff
    if psx.getThumbR & %0000_0010 == 0
      panServoPosition +=50
    elseif psx.getThumbR & %0000_0001 == 0
      panServoPosition -=50
    panServoPosition := _panServoMin #> panServoPosition <# _panServoMax 
    servos.set(_panServo,panServoPosition)



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
PUB initStuff
    motorLeft :=0
    motorRight :=0
    heartBeat :=0
    panServoPosition := (_panServoMax + _panServoMin)/2
    outa[_LED]~~
    dira[_LED]~~
    
    term.start(31,30)
   ' repeat while term.abs_x == 0    'wait for PropTerminal.exe started
    term.str(string("starting up"))
    
    cognew(startMotors, @stack[0]) 'start MOTOR cog
    uart.start(14,15, 3 , 9600 )'(rxpin, txpin, mode, baudrate) : okay
'' mode bit 0 = invert rx
'' mode bit 1 = invert tx
'' mode bit 2 = open-drain/source tx
'' mode bit 3 = ignore tx echo on rx       
    servos.set(_panServo,panServoPosition)
    servos.start
    acc.start(0,1,2) 'start(CS_,DIO_,CLK_):okay                    
    psx.start(24,25,26,27) 'ddat, cmd, att, clk             
    

    
    term.str(string("done"))
    waitcnt(cnt+clkfreq/2)        '1 sec pause before starting
    waitcnt(clkfreq*2+cnt)
         
    term.cls
    outa[_LED]~

'motor control, runs on its own cog
'updates motor speed based on variables motorLeft and motorRight

 ' pins....18,  21,  16,  17,  19,  20    
' 6 pins....enL, enR, d1L,d2L,d1R,d2R      
PUB startMotors | dt,motorLeftSpeed,motorRightSpeed, enL, enR

   
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
' 6 pins....enL, enR, d1L,d2L,d1R,d2R      
{{PUB startMotors(startPin) | dt,motorLeftSpeed,motorRightSpeed, enL, enR

    dira[startPin..startPin+5]~~   'change to output
    outa[startPin..startPin+5]~    'motors off
    enL:=startPin
    enR:=startPin+1
    dT := clkfreq / 25_000             ' 1kHz refresh rate
  
    repeat
      
      motorLeftSpeed:=motorLeft            'set local variable to current state of global one
      motorRightSpeed:=motorRight
      
      motorLeftSpeed<#=100                 'limit input from -100% to 100%
      motorLeftSpeed#>=-100
      motorRightSpeed<#=100
      motorRightSpeed#>=-100

      if motorLeftSpeed==0                      'set motor directions
        outa[startPin+2..startPin+3]:=%00              'written 2 different ways, both work
      elseif( motorLeftSpeed== (||motorLeftSpeed))
        outa[startPin+2..startPin+3]:=%01
      else
        outa[startPin+2..startPin+3]:=%10
      if motorRightSpeed < 0                      
        outa[startPin+4..startPin+5]:=%10
      elseif motorRightSpeed>0
        outa[startPin+4..startPin+5]:=%01
      elseif motorRightSpeed==0
        outa[startPin+4..startPin+5]:=%00    

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
          waitcnt(cnt+dT*(100-||motorLeftSpeed) )       }}
      
PUB heartBeatMethod
  if(heartBeat==5000)
    outa[4]:=1
    waitcnt(cnt+clkfreq/50)
    outa[4]:=0
    heartBeat:=0
  heartBeat++


PUB API  ' API of objects used
  {{
OBJECT "Ir Detector"
  PUB init(irLedPin, irReceiverPin)
  PUB object :state | pin, freq, dur
  PUB distance :dist | pin, freq, dur

                                              }}                                      