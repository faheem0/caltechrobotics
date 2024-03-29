
'' File: mouseTest.spin

VAR
    
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz

OBJ
    term   :       "PC_Interface"
    mouse: "Mouse"
PUB mainMethod

    term.start(31,30)
   ' repeat while term.abs_x == 0    'wait for PropTerminal.exe started
    term.str(string("starting up"))
    waitcnt(cnt+clkfreq/2)
    'dira[24..27]:= %1010
    mouse.start(13,12 )'data(green), clk (white)
    
    repeat
      'term.str(string("loop"))
      'checkIR(24)
      term.cls
      'term.bin(mouse.buttons,5)   '0 = object detected
      'term.dec(mouse.abs_x)
      term.dec(mouse.abs_y)
      'term.dec(mouse.abs_z)
      waitcnt(cnt+clkfreq/10)

'uses startPin to startPin+4      

      
      