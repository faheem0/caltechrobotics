'' encoderTest.spin 
'11/22/2007
'use PEK with encoder connected to pins ??,??
VAR
    long maxtime
    long time
    
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
    _encA = 13
    _encB = 3
    

OBJ
    term:   "PC_Interface"
    encoder: "encoderCustomASM"
PUB main

    INITIALIZATION
        
    repeat    
      MAINLOOP
      


    
PUB MAINLOOP
    term.str(string("pos: "))
    term.dec(encoder.getPos)
    term.str(string(" slipcnt: "))
    term.dec(encoder.getSlipcount)

    time := encoder.getDebug
    term.str(string(" time: "))
    term.dec(time)
    if(maxtime < time)
      maxtime:=time
    term.str(string(" max: "))
    term.dec(maxtime)
    
    ' term.bin(encoder.getDebug, 20)

    term.out($0D)
    waitcnt(clkfreq/10+cnt)
PUB INITIALIZATION
    term.start(31,30)
   ' repeat while term.abs_x == 0    'wait for PropTerminal.exe started
    term.str(string("starting up"))
    
    encoder.start(_encA, _encB)
     waitcnt(clkfreq/2 + cnt)
    term.str(string("done"))
       