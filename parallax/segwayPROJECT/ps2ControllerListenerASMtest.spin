'' ps2ControllerListenerASMtest.spin 
'9/10/2007
'for monitoring ps2 controller signals
'USES PINS 0-3

VAR
  
  
   long count
   long time

CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
    
    
OBJ
    term   :       "PC_Interface"
    psx    :  "ps2ControllerListenerASM"
PUB mainMethod

    term.start(31,30)
    term.str(string("starting up"))
    waitcnt(cnt+clkfreq/2)
    count:=0
    
    'DECLARE PINS
    psx.start(3,2,1,0) 'ddat, cmd, att, clk
    waitcnt(cnt+clkfreq/2)                    
    repeat                     
     'if(psx.getID<>0)
      repeat until psx.getStatus<>$FFFF
        term.cls           
      
      term.dec(psx.getCount)          
      
      time:=cnt      
      term.out($0D)
      'term.str(string("start: "))
      term.hex(psx.getStart,4)
      term.out($0D) 
      
      'term.str(string("ID: "))
      term.hex(psx.getID,4)
      term.out($0D)
      'term.str(string("Status: "))
      term.hex(psx.getStatus,4)
      term.out($0D)
      
      term.hex(psx.getThumbL,4)
      term.out($0D)
      term.hex(psx.getThumbR,4)
      term.out($0D)
      term.hex(psx.getJoyRX,4)
      term.out($0D)
      term.hex(psx.getJoyRY,4)
      term.out($0D)
      term.hex(psx.getJoyLX,4)
      term.out($0D)
      term.hex(psx.getJoyLY,4)
      term.out($0D)
      term.dec((cnt-time)/80)
      term.str(string(" us"))             

      waitcnt(cnt+clkfreq/10)