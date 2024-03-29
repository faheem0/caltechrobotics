'' File: myCompasTest.spin
'' Uses PRC to test HM55 Compass
''Version 1.0
{{history: 1.0 file started
Last updated: 3/1/2008
Known issues: 
              
                                                        
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
    14     
    15     
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
    
    _HM55CL= 11
    _HM55EN= 10
    _HM55DA= 9
    

OBJ
    term:   "PC_Interface"
  compass :     "HM55B Compass Module Asm"
PUB main

    INITIALIZATION
        
    repeat    
      MAINLOOP
      


    
PUB MAINLOOP

    repeat                                        
      term.cls
      'term.dec(compass.x)
      'term.str(string(" "))
      'term.dec(compass.y)
      term.dec(compass.theta*10/227)
      term.out($0d)
      waitcnt(clkfreq/10+cnt)


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
    
   ' xbee.start(14,15,%0000,9600)           ' XBee Comms - RX,TX, Mode, Baud
   ' xbee.AT_Init                     ' Initialize for fast AT command use - 5 second delay to perform
   ' xbee.AT_Config(string("ATAP 0"))            ' Set for non-API mode (AT mode)

  '  xbee.AT_Config(string("ATDL 1"))            ' Set destination address to 1
    'uart.start(14,15, 3 , 9600 )'(rxpin, txpin, mode, baudrate) : okay
'' mode bit 0 = invert rx
'' mode bit 1 = invert tx
'' mode bit 2 = open-drain/source tx
'' mode bit 3 = ignore tx echo on rx       
       
    compass.start(_HM55EN,_HM55CL,_HM55DA )'start(EnablePin,ClockPin,DataPin):okay

    
    term.str(string("done"))
    pausems(1000)
         
    term.cls
    

 
PUB pausems(ms)
  waitcnt(cnt+clkfreq/1000*ms)

                                    