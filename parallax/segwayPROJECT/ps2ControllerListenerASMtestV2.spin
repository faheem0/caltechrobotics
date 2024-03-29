'' ps2ControllerListenerASMtestV2.spin 
'9/10/2007
'for monitoring ps2 controller signals
'USES PINS 0-3
'V2: more compact data, triggers and prints up to 20 packets

VAR
  
  
   long count
   long time
   long temp
   long last

CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
    
    
OBJ
    term   :       "PC_Interface"
    psx    :  "ps2ControllerListenerASMv2"
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
      term.cls           
      repeat while (psx.getDatOne & $FF0000) <> $5A0000      'trigger on 5A status
      'repeat while (psx.getCmdOne & $FF00) <>$4200         'trigger on 42 "getDat" cmd
        term.str(string("no signal"))
        temp:=psx.getCount
        term.cls
        'printOneCommandDataBlock
        'printOneCommandBlock
        'printTwoCommandBlocks
      time:=cnt        'start timer

      repeat 10
        'printOneCommandDataBlock
        'printOneCommandBlock
        'printTwoCommandBlocks
        printThreeCommandBlocks
      term.dec((cnt-time)/80)
      term.str(string(" us"))     'stop timer, print time        

      repeat while (psx.getDatOne & $FF0000) == $5A0000
      waitcnt(cnt+clkfreq/10)
PUB printThreeCommandBlocks
        'term.dec(psx.getCount-temp)            
        'term.str(string(" "))             
        'term.hex(psx.getCmdThree,2)
        term.hex(psx.getCmdTwo,4)
        term.hex(psx.getCmdOne,8)
        term.str(string(" "))
          
        last:=psx.getCount
        repeat while psx.getCount==last     

        'term.hex(psx.getCmdThree,2)
        term.hex(psx.getCmdTwo,4)
        term.hex(psx.getCmdOne,8)
        term.str(string(" "))
          
        last:=psx.getCount
        repeat while psx.getCount==last   
        'term.hex(psx.getCmdThree,2)
        term.hex(psx.getCmdTwo,4)
        term.hex(psx.getCmdOne,8)
        term.out($0D)        
        last:=psx.getCount
        repeat while psx.getCount==last
PUB printTwoCommandBlocks
        term.dec(psx.getCount-temp)            
        term.str(string(" "))             
        'term.hex(psx.getCmdThree,2)
        term.hex(psx.getCmdTwo,4)
        term.hex(psx.getCmdOne,8)
        term.str(string(" "))
          
        last:=psx.getCount
        repeat while psx.getCount==last

           
        'term.hex(psx.getCmdThree,2)
        term.hex(psx.getCmdTwo,4)
        term.hex(psx.getCmdOne,8)
        term.out($0D)        
        last:=psx.getCount
        repeat while psx.getCount==last
PUB printOneCommandBlock
        term.dec(psx.getCount-temp)            
        term.str(string(" "))             
        'term.hex(psx.getCmdThree,2)
        term.hex(psx.getCmdTwo,4)
        term.hex(psx.getCmdOne,8)
        {{Pterm.str(string(" "))
          
        last:=psx.getCount
        repeat while psx.getCount==last

           
        'term.hex(psx.getCmdThree,2)
        term.hex(psx.getCmdTwo,4)
        term.hex(psx.getCmdOne,8) }}
        term.out($0D)        
        last:=psx.getCount
        repeat while psx.getCount==last
PUB printOneCommandDataBlock
        term.dec(psx.getCount-temp)            
        term.str(string(" "))             
        'term.hex(psx.getCmdThree,2)
        term.hex(psx.getCmdTwo,4)
        term.hex(psx.getCmdOne,8)
        term.str(string(" "))
          
        
           
        'term.hex(psx.getDatThree,2)
        term.hex(psx.getDatTwo,4)
        term.hex(psx.getDatOne,8)
        term.out($0D)        
        last:=psx.getCount
        repeat while psx.getCount==last                        