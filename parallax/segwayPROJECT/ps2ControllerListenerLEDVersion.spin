'' File: ps2ControllerListener.spin
     'DOESNT WORK-TOO SLOW
  'August 2007
VAR
   long datPin    '3
   long cmdPin    '2
   long attPin    '1
   long clkPin    '0
   
   long timer,timer2
   long count
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
    
    
    
PUB mainMethod
    clkPin:=0
    attPin:=1
    cmdPin:=2
    datPin:=3

    dira[datPin]~ 'INPUTS
    dira[cmdPin]~ 'INPUTS
    dira[attPin]~ 'INPUTS
    dira[clkPin]~ 'INPUTS
    
    dira[4..11]~~ 'outputs
    outa[4..11]~~
    waitcnt(cnt+clkfreq/2)
    timer:=cnt
    timer2:=cnt
    outa[4..11]~
    
    repeat
      count~          
      repeat until ina[attPin]==0 'wait till low  
      'repeat while ina[attPin]==0
      if ina[attPin==0]
        repeat until ina[clkPin]==0
        outa[cnt+4]:=ina[cmdPin]
        count++
        repeat while ina[clkPin]==0
        
      
    
