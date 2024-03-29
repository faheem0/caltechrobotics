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

    long currentAng
    long angChange
    
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
    
    _startByte = $FE
    _stopByte = $FE
    
    _HM55CL= 11       'pin numbers
    _HM55EN= 10
    _HM55DA= 9
    

OBJ
    term:   "PC_Interface"
  compass :     "HM55B Compass Module Asm"
PUB main

    INITIALIZATION
        
      MAINLOOP2  
      'MAINLOOP
      


    
PUB MAINLOOP      |sum

    repeat                                       
      term.cls      'clears screen
      term.str(string("angle in degrees:"))
   
         sum := compass.theta*10/227
         
      term.dec(sum)
      
      term.out($0d)   'next line
      pausems(200)

PUB MAINLOOP2

    repeat
      
      GETANGCHANGE
      term.cls
      term.str(string("angChange:"))
      term.dec(angChange)
      term.out($0d)
  
      term.str(string("currentAng:"))
      term.dec(currentAng)
      term.out($0d)
      

      
PUB GETCURRENTANG   |ang1, ang2, ang3, ang4, sum
                'takes 150 ms
    sum := 0
                
        ang1 := compass.theta*10/227
        pausems(50)
        ang2 := compass.theta*10/227
        pausems(50)
        ang3 := compass.theta*10/227
        pausems(50)
        ang4 := compass.theta*10/227

        'special case for angs close to 0, 360
        
     if ||(ang1-ang2)=> 300 OR  ||(ang1-ang3)=> 300 OR ||(ang1-ang4)=> 300
          if ang1 > 300
                ang1 := ang1 - 360
          if ang2 > 300
                ang2 := ang2 - 360
          if ang3 > 300
                ang3 := ang3 - 360
          if ang4 > 300
                ang4 := ang4 - 360
          sum := ang1+ang2+ang3+ang4
          currentAng := sum/4
          if currentAng < 0
                currentAng := 360 + currentAng
                                  
     else
          sum := ang1+ang2+ang3+ang4
          currentAng := sum/4
          
    Return currentAng

PUB GETANGCHANGE   |ang1, ang2, ang3, ang4, ang5, ang6, change1, change2, change3

   'signed ang change over 250 ms
   'takes about 400 ms

    ang1 := GETCURRENTANG
    pausems(100)
    ang2 := GETCURRENTANG

        
    angChange := (ang2-ang1)
    if angChange > 300
          angChange := angChange - 360

    if angChange < -300
          angChange := angChange + 360      
    Return (angChange) 


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

                                    