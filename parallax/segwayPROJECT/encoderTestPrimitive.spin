'' encoderTest.spin 
'11/22/2007
'use PEK with encoder connected to pins 10, 11
VAR
    long maxtime
    long time
    long temp,oldtemp
    
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
    
    

OBJ
    term:   "PC_Interface"
    'encoder: "encoderASM"
PUB main

    INITIALIZATION
        
    repeat
     'term.bin(ina[4..5],2)
     'term.out($0D)  
    'repeat    
      'MAINLOOP
      repeat while(ina[5..6]==temp)
      temp:=ina[5..6]
      term.bin(temp,2)
      term.out($0D)
      


    
PUB MAINLOOP
   
    waitcnt(clkfreq/10+cnt)
PUB INITIALIZATION
    term.start(31,30)
   ' repeat while term.abs_x == 0    'wait for PropTerminal.exe started
    term.str(string("starting up"))
    
    'encoder.start(_encA, _encB)
     waitcnt(clkfreq/2 + cnt)
    term.str(string("done"))
       