'' File: SumoBot.spin
'' controls sumobot!
'simple motor controller test 7/27/07

VAR
    byte motorLeft   'duty cycle, -100 to 100 %
    byte motorRight
    
    long stack[60]
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
PUB mainMethod

    motorLeft :=0
    motorRight :=0  

    dira[21..23]~ 'switches
    dira[8]~~ 'LED's
    'outa[4..9]~  'LED's off
    
   startMotors(10)
 {{   repeat                              '**THIS LOOP WORKS**
      if ina[23]
        motorLeft:=90
        outa[8]:=0
        'waitcnt(cnt+79_000_000)
      else
        outa[8]:=0
        motorLeft:=1
      if ina[21]
        motorRight:=90
        outa[8]:=0
        'waitcnt(cnt+79_000_000)
      else
        outa[8]:=0
        motorRight:=1
      {{outa[8]:=1
      waitcnt(cnt+1_000_000)
      outa[8]:=0
      waitcnt(cnt+79_000_000)    }}  
     

' 6 pins....enL, enR, d1L,d2L,d1R,d2R       
PUB startMotors(startPin) | T,dt,motorLeftSpeed,motorRightSpeed

    dira[startPin..startPin+5]~~   'change to output
    outa[startPin..startPin+5]:=%110000    'motors off
    
    dira[4..9]~~
   
        
    repeat
      if ina[23]
        outa[startPin+2..startPin+3]:=%10
      else 
        outa[startPin+2..startPin+3]~
      if ina[21]                      
        outa[startPin+4..startPin+5]:=%10
      else 
        outa[startPin+4..startPin+5]~    
      if(ina[22])
        outa[startPin..startPin+1]~
        waitcnt(cnt+clkfreq/100)
      outa[startPin..startPin+1]~~
      waitcnt(cnt+clkfreq/100)
   
      
                                                       