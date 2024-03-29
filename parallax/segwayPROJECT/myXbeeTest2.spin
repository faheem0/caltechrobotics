'' File: myXbeeTest.spin
'' Uses PRC to test xbee
''Version 1.0
{{history: 1.0 file started, connection to xbee
Last updated: 12-17-2007
Known issues: will blink rx LED/rx LED blinks but no byte
              works without xbee init stuff
              tx($FE) does not visibly blink LED, must do several times
              
                                                        
                                  }}
{{ PIN   Purpose    Input  Output
    0     
    1     
    2     
    3
    4 
    5 
    6 
    7     
    8     
    9    
    10     
    11     
    12     
    13                            
    14     UART-rx   X
    15     UART-tx           X
    16      
    17      
    18     
    19                
    20  
    21    
    22  
    23     
    24   
    25  
    26  
    27   }}
{{COG usage:
    0: main cog
    1: 
    2: 
    3: 
    4:
    5:
    6:
    7:
                                                 }}
VAR
    byte receivedByte
    long counter
    byte temp
    
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
    
    _startByte = $FE
    _stopByte = $FE
    _scanResolution=90
    

OBJ
    term:   "PC_Interface"
    xbee: "XBee_Object"
PUB main

    INITIALIZATION
        
    repeat    
      MAINLOOP
      


    
PUB MAINLOOP
    'repeat
    '  receivedByte:=xbee.rxtime(1000)
    '  if(receivedByte<>0)
    '    term.dec(xbee.rxtime(1000))
    '
    'repeat
    temp:=0
    repeat
       repeat 2
         xbee.tx(%10101010)
         'xbee.tx($FF)
       waitcnt(clkfreq/10+cnt)
    repeat
       xbee.tx(%10101010)'temp) 170
       'xbee.tx(temp)
       'xbee.tx(temp)
       temp+=1
       if(temp==110)
         temp:=0
         repeat
    xbee.tx($FE)
    xbee.tx($FF)
    xbee.tx($FF)
    xbee.tx($FF)
    xbee.tx($FF)
    xbee.tx($FF)
    xbee.tx($FF)
    xbee.tx($FF)
    xbee.tx($FF)
    term.str(string("loop count: "))
    term.dec(counter++)
    term.str(string("received byte: "))

    term.dec(receivedByte)
    term.out($0D)
    
    waitcnt(clkfreq/2+cnt)


 'clears screen and prints stuff out      
PUB clearScreenPrint
    term.cls
    'term.bin(psx.getThumbR,8)
    term.str(string(" received: "))
    term.dec(receivedByte)

'inits pins/objects/etc       
PUB INITIALIZATION
    
    
    term.start(31,30)
   ' repeat while term.abs_x == 0    'wait for PropTerminal.exe started
    term.str(string("starting up"))
    
    xbee.start(14,15,%0000,9600)           ' XBee Comms - RX,TX, Mode, Baud
   ' xbee.AT_Init                     ' Initialize for fast AT command use - 5 second delay to perform
   ' xbee.AT_Config(string("ATAP 0"))            ' Set for non-API mode (AT mode)

  '  xbee.AT_Config(string("ATDL 1"))            ' Set destination address to 1
    'uart.start(14,15, 3 , 9600 )'(rxpin, txpin, mode, baudrate) : okay
'' mode bit 0 = invert rx
'' mode bit 1 = invert tx
'' mode bit 2 = open-drain/source tx
'' mode bit 3 = ignore tx echo on rx       
       
    

    
    term.str(string("done"))
    pausems(1000)
         
    term.cls
    

 
PUB pausems(ms)
  waitcnt(cnt+clkfreq/1000*ms)

                                    