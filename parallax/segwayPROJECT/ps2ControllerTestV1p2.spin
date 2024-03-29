'' File: ps2ControllerTestV1p2.spin

VAR
  
  
   long count
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
    
    
OBJ
    term   :       "PC_Interface"
    psx    :  "ps2ControllerV1p2d"
PUB mainMethod

    term.start(31,30)
   ' repeat while term.abs_x == 0    'wait for PropTerminal.exe started
    term.str(string("starting up"))
    waitcnt(cnt+clkfreq/2)
    count:=0
    
    'DECLARE PINS
    psx.start(24,25,26,27) 'ddat, cmd, att, clk
    waitcnt(cnt+clkfreq/2)                    
    repeat                     
      term.cls           
      count++
      term.dec(count)
                  
      term.out($0D)

      term.str(string("ID: "))
      term.dec(psx.getID)
      term.out($0D)
      term.str(string("Status: "))
      term.dec(psx.getStatus)
      term.out($0D)
      
      term.bin(psx.getThumbL,8)
      term.out($0D)
      term.bin(psx.getThumbR,8)
      term.out($0D)
      term.dec(psx.getJoyRX)
      term.out($0D)
      term.dec(psx.getJoyRY)
      term.out($0D)
      term.dec(psx.getJoyLX)
      term.out($0D)
      term.dec(psx.getJoyLY)
      term.out($0D)             

      waitcnt(cnt+clkfreq/10)