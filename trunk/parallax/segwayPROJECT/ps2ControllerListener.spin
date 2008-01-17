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
    
    
OBJ
    term   :       "PC_Interface"
    
PUB mainMethod
    clkPin:=0
    attPin:=1
    cmdPin:=2
    datPin:=3

    dira[datPin]~ 'INPUTS
    dira[cmdPin]~ 'INPUTS
    dira[attPin]~ 'INPUTS
    dira[clkPin]~ 'INPUTS
    
    term.start(31,30)
   ' repeat while term.abs_x == 0    'wait for PropTerminal.exe started
    term.str(string("starting up"))
    waitcnt(cnt+clkfreq/2)
    timer:=cnt
    timer2:=cnt
    
    repeat
      
      term.cls
      term.dec(80_000_000/(cnt-timer))
      term.str(string(" Hz"))         
      timer:=cnt              
      term.out($0D) 
      count:=0
      
      repeat until ina[attPin]==0 'wait till low

      timer2:=cnt
      repeat until ina[attPin]==1
      term.dec(( cnt-timer2))
      waitcnt(cnt+clkfreq/10)

      {{         
      repeat while ina[attPin]==0
        repeat until ina[clkPin]==0
        term.dec(ina[cmdPin])
        count++
        if(count==7)
          count:=0
          term.out($0D)
        repeat while ina[clkPin]==0
        }}
      
    
