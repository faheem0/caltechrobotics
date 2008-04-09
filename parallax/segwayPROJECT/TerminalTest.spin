
'' File: TerminalTest.spin
'' 4/7/2008

VAR
    
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz

OBJ
    term   :       "PC_Interface"

PUB main | temp

    term.start(31,30)
   ' repeat while term.abs_x == 0    'wait for PropTerminal.exe started
    term.str(string("starting up"))
    waitcnt(cnt+clkfreq/2)
    temp:=0
        
    repeat
      term.dec(temp++)
      waitcnt(cnt+clkfreq/10)
      

'uses startPin to startPin+4      

      
      