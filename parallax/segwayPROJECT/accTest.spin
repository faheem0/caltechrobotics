
'' File: accTest
''  use with PEK board
''

VAR
    long temp
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
OBJ
    acc: "H48C Tri-Axis Accelerometer"
    term   :       "PC_Interface" 
PUB main
    term.start(31,30)
   ' repeat while term.abs_x == 0    'wait for PropTerminal.exe started
    term.str(string("starting up"))
    
 
      
    acc.start(0,1,2) 'start(CS_,DIO_,CLK_):okay    
   
    repeat
      waitcnt(cnt+clkfreq/5)
      'term.cls
      
      term.bin((acc.x),10)
      term.out($0D)
      
      {{temp:=acc.x
      temp:=temp&%11_1111_1111
      if temp <> 0 and temp<> 1 
        if temp >512
          term.dec(1024-temp)
        else
          term.dec(temp) 
        term.out($0D)  }} 
         {{ 
      term.dec((acc.y-acc.vref)/455)     
      term.out($0D)
      term.dec((acc.z-acc.vref)/455)
      term.out($0D)    
      term.dec(acc.thetaA)
      term.out($0D)  
      term.dec(acc.thetaB)      
      term.out($0D)
      term.dec(acc.thetaC)    
                              }}                                       