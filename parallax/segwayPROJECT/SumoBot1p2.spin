
'' File: SumoBot.spin
'' controls sumobot!
''Version 1.2
{{history: 1.0 file started, pushbuttons run motors
           1.1 terminal added, checkLine
           1.2 motor cog works w/ negative functional wandering sumo 
                                  }}
{{ PIN   Purpose    Input  Output
    0     RlinePWR           X
    1     RlineIN    X       X
    2     LlinePWR           X
    3     LlineIN    X       X
    4
    5     D1L                X
    6     D2L                X
    7     D1R                X
    8
    9      
    10     EN1               X
    11     EN2               X
    12     DEAD?   -->5      -
    13     DEAD?   -->6      -
    14     DEAD?   -->7      -
    15     D2R
    16
    17
    18
    19
    20
    21
    22
    23
    24     ADC
    25     ADC
    26     ADC
    27                              }}    
VAR
    long motorLeft   'duty cycle, -100 to 100 %
    long motorRight
    long lineStatus

    long heartBeat,heartBeat2
    long stack[60]
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz

OBJ
    term   :       "PC_Interface"
PUB mainMethod

    heartBeat:=0
    motorLeft :=0
    motorRight :=0

    term.start(31,30)
   ' repeat while term.abs_x == 0    'wait for PropTerminal.exe started
    term.str(string("starting up"))
    'dira[5..15]~~
    'outa[5..15]~
    'repeat
    cognew(startMotors, @stack[0]) 'start MOTOR cog
    waitcnt(cnt+clkfreq/5)        '1 sec pause before starting      
    term.cls
    
    repeat    'MAIN LOOP
      
      lineStatus:= checkLine
      
      'motorLeft:=motorRight:=-100
      if(lineStatus==0) 
        motorLeft:=motorRight:=50
      elseif lineStatus== %11
        motorLeft:=motorRight:=-50
        waitcnt(cnt+clkfreq)
        motorLeft:=-70
        motorRight:=70
        waitcnt(cnt+clkfreq/2)
      elseif lineStatus== %10 'turnRight
        motorLeft:=motorRight:=-50
        waitcnt(cnt+clkfreq/2)
        motorLeft:=50
        motorRight:=-50
        waitcnt(cnt+clkfreq/2)
      elseif lineStatus== %01 'turnLeft
        motorLeft:=motorRight:=-50
        waitcnt(cnt+clkfreq/2)
        motorRight:=50
        motorLeft:=-50
        waitcnt(cnt+clkfreq/2)    
       
    
PUB checkIR
    {{ BS2 code:
    FREQOUT leftIRTrans,1,38500
    IRDetectLeft=IN11
    FREQOUT rightIRTrans,1,38500
    IRDetectRight=IN5}}
    
'1 to 1.5 M counts execution time      
PUB checkLine: result |clkStart, clkStop, totalL, totalR
    totalL:=totalR:=0
    'Right line sensor
    repeat 5
      dira[0..1]~~
      outa[0..1]~~                      'HIGH pwr and in
      waitcnt(cnt+clkfreq/1000)         'PAUSE 1
      'rctime routine
      dira[1]~                          'change in back to input
      clkStart := cnt                                                    
      waitpne(1 << 1, |< 1, 0)          'waitpne(State << pin, |< Pin, 0)                     
      clkStop := cnt
      if((clkStop-clkStart )< 15_000)
        totalR++
    outa[0]~

    'LEFT line sensor
    repeat 5
      dira[2..3]~~
      outa[2..3]~~

      waitcnt(cnt+clkfreq/1000)
      'rctime routine
      dira[3]~
      clkStart := cnt
                                             
      waitpne(1 << 3, |< 3, 0)                        
      clkStop := cnt
      if((clkStop-clkStart )< 15_000)
        totalL++
    outa[2]~
    
    term.cls
    if(totalL>2)    'if more than 3/5, then LINE
      term.dec(1)   'print states
    else
      term.dec(0)
    if(totalR>2)
      term.dec(1)
    else
      term.dec(0)
      
    if( totalL>2 and totalR>2)
      result:=%11
    elseif totalL>2
      result:=%10
    elseif totalR>2
      result:=%01
    else
      result:=%00
''MODIFIED
 ' pins....10,  11,  5,  6,  7,  15    
' 6 pins....enL, enR, d1L,d2L,d1R,d2R      
PUB startMotors | dt,motorLeftSpeed,motorRightSpeed, enL, enR

    dira[5..7]~~
    dira[10..11]~~
    dira[15]~~   'change to output
    outa[5..7]~
    outa[10..11]~
    outa[15]~
    enL:=10
    enR:=11
    dT := clkfreq / 25_000             ' 1kHz refresh rate
  
    repeat
      
      motorLeftSpeed:=motorLeft            'set local variable to current state of global one
      motorRightSpeed:=motorRight
      
      motorLeftSpeed<#=100                 'limit input from -100% to 100%
      motorLeftSpeed#>=-100
      motorRightSpeed<#=100
      motorRightSpeed#>=-100

      if motorLeftSpeed==0                      'set motor directions
        outa[5..6]:=%00              'written 2 different ways, both work
      elseif( motorLeftSpeed== (||motorLeftSpeed))
        outa[5..6]:=%10
      else
        outa[5..6]:=%01
      if motorRightSpeed < 0                      
        outa[7]:=1
        outa[15]:=0
      elseif motorRightSpeed>0
        outa[7]:=0
        outa[15]:=1
      elseif motorRightSpeed==0
        outa[7]:=0
        outa[15]:=0    

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