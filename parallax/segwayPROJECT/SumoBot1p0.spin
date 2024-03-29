
'' File: SumoBot.spin
'' controls sumobot!
''Version 1.0  7/27/07

VAR
    byte motorLeft   'duty cycle, -100 to 100 %
    byte motorRight
    byte x 'for loops

    long heartBeat,heartBeat2
    long stack[60]
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
PUB mainMethod
    heartBeat:=0
    motorLeft :=0
    motorRight :=0  

    dira[21..23]~ 'switches
    dira[4..9]~~ 'LED's
    
    
    cognew(startMotors(10), @stack[0])
    repeat
      heartBeatMethod
      if ina[23]
        motorLeft:=50
      else
        motorLeft:=0
      if ina[21]
        motorRight:=50
      else
        motorRight:=0
      if ina[22]
        x:=5
        repeat  while (x<100 and ina[22])
          motorLeft:=x
          motorRight:=x
          x++
          waitcnt(cnt+clkfreq/10)      
      
   
' 6 pins....enL, enR, d1L,d2L,d1R,d2R      
PUB startMotors(startPin) | T,dt,motorLeftSpeed,motorRightSpeed, enL, enR

    dira[startPin..startPin+5]~~   'change to output
    outa[startPin..startPin+5]~    'motors off
    enL:=startPin
    enR:=startPin+1
    dT := clkfreq / 25_000             ' 1kHz refresh rate
    dira[4..9]~~
   {{ outa[4]:=1                     'pin4 = indicator LED
    waitcnt(cnt+80_000_000)        '**INDICATOR ON 1 SEC**
    outa[4]:=0
    waitcnt(cnt+dT*100000)}}

    T:=cnt    
    repeat
  {{    outa[4]:=1                   '**FLASH INDICATOR-NEVER HAPPENS**
      waitcnt(clkfreq/5+cnt)
      outa[4]:=0
      waitcnt(clkfreq+cnt)           }}
      heartBeat2Method
      
      motorLeftSpeed:=motorLeft
      motorRightSpeed:=motorRight
      
      motorLeftSpeed<#=100                 'limit input from -100% to 100%
      motorLeftSpeed#>=-100
      motorRightSpeed<#=100
      motorRightSpeed#>=-100
     {{ if(||motorLeftSpeed <5)   'does not work
        motorLeftSpeed:=0
      if(motorLeftSpeed-95 >0)
        motorLeftSpeed:=100
      if(motorLeftSpeed+95 <0)
        motorLeftSpeed:=-100    
        
      if(||motorRightSpeed <5)
        motorRightSpeed:=0
        if(||motorRightSpeed-95>0)
        motorRightSpeed:=100
      if(motorRightSpeed+95 <0)
        motorRightSpeed:=-100    }}
       
      if motorLeftSpeed < 0                      'set motor directions
        outa[startPin+2..startPin+3]:=%01
      elseif motorLeftSpeed>0
        outa[startPin+2..startPin+3]:=%10
      elseif motorLeftSpeed==0
        outa[startPin+2..startPin+3]:=%00
      if motorRightSpeed < 0                      
        outa[startPin+4..startPin+5]:=%01
      elseif motorRightSpeed>0
        outa[startPin+4..startPin+5]:=%10
      elseif motorRightSpeed==0
        outa[startPin+4..startPin+5]:=%00    
      motorLeftSpeed:=||motorLeftSpeed              'direction no longer needed
      motorRightSpeed:=||motorRightSpeed
      
      if(motorLeftSpeed<>0)  
        outa[enL]:=1                               'high duration
        outa[7]:=1
      if(motorRightSpeed<>0)
        outa[enR]:=1
        outa[9]:=1
                             
      if(motorLeftSpeed==0 and motorRightSpeed==0)
        waitcnt(cnt+dT*100)
      elseif(motorRightSpeed<>0 and motorLeftSpeed==0)
        waitcnt(cnt+dt*(||motorRightSpeed))
        if(||motorRightSpeed<>100)
          outa[enR]:=0
          outa[9]:=0
          waitcnt(cnt+dT*(100-||motorRightSpeed) )
      elseif(motorLeftSpeed<>0 and motorRightSpeed==0)
        waitcnt(cnt+dt*(||motorLeftSpeed))
        if(||motorLeftSpeed<>100)
          outa[enL]:=0
          outa[7]:=0
          waitcnt(cnt+dT*(100-||motorLeftSpeed) )
      elseif(||motorLeftSpeed == ||motorRightSpeed)
        waitcnt(cnt+dT*(||motorLeftSpeed) )
        if(||motorRightSpeed<>100)
          outa[enL]:=0
          outa[7]:=0
          outa[enR]:=0
          outa[9]:=0
          waitcnt(cnt+dT*(100-||motorRightSpeed) )
      elseif(||motorLeftSpeed < ||motorRightSpeed)        
        waitcnt(cnt+dT*(||motorLeftSpeed) )
        outa[enL]:=0
        outa[7]:=0
        waitcnt(cnt+dT*(||motorRightSpeed-||motorLeftSpeed) )      'low duration
        if(||motorRightSpeed<>100)
          outa[enR]:=0
          outa[9]:=0              
          waitcnt(cnt+dT*(100-||motorRightSpeed) )
      elseif(||motorRightSpeed < ||motorLeftSpeed)
        waitcnt(cnt+dT*(||motorRightSpeed) )
        outa[enR]:=0
        outa[9]:=0
        waitcnt(cnt+dT*(||motorLeftSpeed-||motorRightSpeed) )        'low duration
        if(||motorLeftSpeed<>100)
          outa[enL]:=0
          outa[7]:=0
          waitcnt(cnt+dT*(100-||motorLeftSpeed) )       
      
PUB heartBeatMethod
  if(heartBeat==5000)
    outa[4]:=1
    waitcnt(cnt+clkfreq/10)
    outa[4]:=0
    heartBeat:=0
  heartBeat++
PUB heartBeat2Method
  if(heartBeat2==1000)
    outa[5]:=1
    waitcnt(cnt+clkfreq/10)
    outa[5]:=0
    heartBeat2:=0
  heartBeat2++                                                      