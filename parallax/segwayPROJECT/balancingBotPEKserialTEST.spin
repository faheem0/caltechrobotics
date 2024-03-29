'' File: balancingBotPEKserialTEST.spin
'' Uses PEK to control balancing bot
''Copy of Version 1.0    modified for serial test

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
    13    
    14     UART-rx   X
    15     UART-tx           X
    16     D1L               X    
    17     D2L               X    
    18     ENL               X   
    19     D1R               X              
    20     D2R               X
    21     ENR               X  
    22
    23
    24     psx-DAT   X 
    25     psx-CMD           X
    26     psx-ATT           X
    27     psx-CLK           X              }}    
VAR
    long motorLeft   'duty cycle, -100 to 100 %
    long motorRight
    

    long heartBeat,heartBeat2
    long stack[60]
    long timer
    
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
    LEDs =16

OBJ
    'term   :       "PC_Interface"
    acc: "H48C Tri-Axis Accelerometer"       
    psx: "ps2ControllerV1p2d"
    uart: "FullDuplexSerial"
PUB main

    heartBeat:=0
    motorLeft :=0
    motorRight :=0
    outa[7]~
    dira[7]~~
    
    'term.start(31,30)
   ' repeat while term.abs_x == 0    'wait for PropTerminal.exe started
   ' term.str(string("starting up"))
    
    cognew(startMotors, @stack[0]) 'start MOTOR cog
    uart.start(14,15,  ,  )'(rxpin, txpin, mode, baudrate) : okay
'' mode bit 0 = invert rx
'' mode bit 1 = invert tx
'' mode bit 2 = open-drain/source tx
'' mode bit 3 = ignore tx echo on rx
    acc.start(0,1,2) 'start(CS_,DIO_,CLK_):okay                    
    psx.start(24,25,26,27) 'ddat, cmd, att, clk             
    
    'term.str(string("done"))
    waitcnt(cnt+clkfreq/2)        '1 sec pause before starting
    waitcnt(clkfreq*2+cnt)
         
    'term.cls
    
    repeat    'MAIN LOOP
       'term.cls
       'term.bin(psx.getThumbR,8)
      ' term.dec(psx.getID)
       {{if(psx.getThumbR & %0100_0000 <> 0)
          motorLeft:=0
          motorRight:=0
       else
          motorLeft:=50
          motorRight:=50   }}
       blinkLED
       if psx.getID <> 115       'controller not in analog mode
         motorRight:=motorLeft:=0
       else
        manualControl   
      'term.cls
      'term.dec(IRDetectL.object)
      'term.str(string(" "))
      'term.dec(IRDetectR.object)
       waitcnt(clkfreq/10+cnt)
      'motorLeft:=motorRight:=-100
PUB blinkLED
    if heartBeat == 0
      LEDon
      heartBeat:=10
    else
      LEDoff
      heartBeat -= 1
PUB blinkLEDwithUART | rxbyte
    rxbyte:= uart.rxcheck
    if rxbyte <> -1
      if rxbyte == 1
        LEDon
      else
        LEDoff
      
            
PUB LEDon
    outa[7]~~
PUB LEDoff
    outa[7]~          
PUB manualControl | rightJoy, leftJoy
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
PUB heartBeat2Method
  if(heartBeat2==250)
    outa[5]:=1
    waitcnt(cnt+clkfreq/50)
    outa[5]:=0
    heartBeat2:=0
  heartBeat2++

PUB API  ' API of objects used
  {{
OBJECT "Ir Detector"
  PUB init(irLedPin, irReceiverPin)
  PUB object :state | pin, freq, dur
  PUB distance :dist | pin, freq, dur

                                              }}                                      