'' File: ps2ControllerTest.spin

VAR
  
  
   long timer
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
    
    
OBJ
    term   :       "PC_Interface"
    psx    :  "ps2Controller"
PUB mainMethod

    term.start(31,30)
   ' repeat while term.abs_x == 0    'wait for PropTerminal.exe started
    term.str(string("starting up"))
    waitcnt(cnt+clkfreq/2)
    
    'DECLARE PINS
    psx.startUp(24,25,26,27) 'ddat, cmd, att, clk
    'psx.Init_Controller                     
    repeat
      
      term.cls           
      timer:=cnt
      psx.Get_PSX_Packet(((psx.getThumbR & %0010_0000)==0),psx.getJoyLY)
      term.dec(80_000_000/(cnt-timer))
      term.str(string(" Hz"))                         
      'term.out($0D)

      term.str(string(" Status: "))
      term.dec(psx.getStatus)
      'term.out($0D)
      term.str(string(" ID: "))
      term.dec(psx.getID)
      term.out($0D)
      term.bin(psx.getThumbL,8)
      term.str(string(" "))
      term.bin(psx.getThumbR,8)
      term.out($0D)       
      term.dec(psx.getJoyRX)
      term.str(string(" "))     
      term.dec(psx.getJoyRY)
      term.str(string(" "))     
      term.dec(psx.getJoyLX)
      term.str(string(" "))     
      term.dec(psx.getJoyLY)
      term.out($0D)

      
      term.dec(psx.extra0)
      term.str(string(" "))   
      term.dec(psx.extra1)
      term.out($0D)
      term.dec(psx.extra2)
      term.str(string(" "))   
      term.dec(psx.extra3)
      term.out($0D)
      term.dec(psx.extra4)
      term.str(string(" "))   
      term.dec(psx.extra5)
      term.out($0D)
      term.dec(psx.extra6)
      term.str(string(" "))   
      term.dec(psx.extra7)
      term.out($0D)
      term.dec(psx.extra8)
      term.str(string(" "))
      term.dec(psx.extra9)
      term.out($0D)
      term.dec(psx.extra10)
      term.str(string(" "))
      term.dec(psx.extra11)


      waitcnt(cnt+clkfreq/5)