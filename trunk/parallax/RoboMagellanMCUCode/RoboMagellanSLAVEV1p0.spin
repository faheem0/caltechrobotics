'' File: RoboMagellanSLAVEV-p-.spin
'' For Caltech RoboMagellan 2008, code for SLAVE MCU only.
''     MASTER-has 2 ribbon cables, connects to CPU
''     SLAVE-has 1 larger ribbon cable, connects to MASTER MCU
''4/25/2008
{{history: 1.0 file copied from balancingBotPEKv4p7.spin, modified UNTESTED

Known issues: UNTESETD

                   
   PIN   Purpose    Input  Output
    0    enc                 X
    1    enc                 X
    2    enc                 X
    3    enc                 X
    4    enc                 X
    5    enc                 X
    6    enc                 X
    7    enc                 X
    8    LED                 X
    9     
    10    
    11    
    12    
    13                               
    14     
    15     
    16  uartMSTrx    X
    17  uartMSTtx            X
    18     
    19             
    20     
    21    
    22     
    23     
    24     
    25     
    26     
    27     
    
  COG usage:
     0: main cog (transmits encoder values constantly)
     1: debug: terminal window/DAQ/graph
     2: uartMST-MCU
     3: encoder-left front
     4: encoder-left back           
     5: encoder-right back           
     6: encoder-right front           
     7:       
    
                                                 }}
VAR

    long heartBeat  'for blinking the LED
    long stack[60]     
 
    long encoderLFFposition 
    long encoderLFBposition
    long encoderRFBposition
    long encoderRFFposition             
    
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz

    'pins 
    _LED = 8            
    _uartMSTrx = 16
    _uartMSTtx = 17

    _encLFa = 0
    _encLFb = 1
    _encLBa = 2
    _encLBb = 3
    _encRBa = 4
    _encRBb = 5
    _encRFa = 6
    _encRFb = 7

    'byte mask
    _byteMask = $FF
    'for serial protocol
    _startByte = 254
    _stopByte = 233
    _dataSendFreq = 200 'how many times per second to send all encoder data
                        


OBJ
    term:   "PC_Interface"
  
    uartMST:   "FullDuplexSerial"
    encoderLF: "encoderCustomASM"
    encoderLB: "encoderCustomASM"
    encoderRB: "encoderCustomASM"
    encoderRF: "encoderCustomASM"
  
PUB main  |temp
    
    INITIALIZATION
    TxRx
    repeat                     'basic serial port test, use hyper terminal
      uartMST.tx(130)
      term.dec(130)
      pausems(500)

    

'transmits startByte, all the encoder data, then stop byte
PUB TxRx | cmdByte , counter,rx1,rx2,rx3,angle1,angle2, time, enct[4], i
    pausems(2000) 'allow time for startup
    repeat
      time:=cnt
       
      uartMST.tx(_startByte)
      'SEND ENCODER DATA HERE
      enct[0] := $11223344'encoderLF.getPos
      enct[1] := $55667788'encoderLB.getPos
      enct[2] := $99AABBCC'encoderRB.getPos
      enct[3] := $DDFFAAEE'encoderRF.getPos
      repeat i from 0 to 3   
        repeat 4
          uartMST.tx(enct[i] & _byteMask)
          enct[i] := enct[i] >> 8

      uartMST.tx(_stopByte)
       
      waitcnt(clkfreq/_dataSendFreq+time)



'inits pins/objects/etc       
PUB INITIALIZATION
    encoderLFFposition:=0
    encoderLFBposition:=0
    encoderRFBposition:=0
    encoderRFFposition:=0   
    heartBeat :=0
    
    LEDon
    dira[_LED]~~
    
    term.start(31,30)     'start terminal COG
    term.str(string("starting up"))
   
        
    uartMST.start(_uartMSTrx,_uartMSTtx, %0000 , 115200)'(rxpin, txpin, mode, baudrate) : okay
'' mode bit 0 = invert rx
'' mode bit 1 = invert tx
'' mode bit 2 = open-drain/source tx
'' mode bit 3 = ignore tx echo on rx

  
   
    encoderLF.start(_encLFa,_encLFb) 'starts new COG
    encoderLB.start(_encLBa,_encLBb) 'starts new COG
    encoderRB.start(_encRBa,_encRBb) 'starts new COG
    encoderRF.start(_encRFa,_encRFb) 'starts new COG
  
    term.out($0d)
    term.str(string("cog #(0-7): "))
    'term.dec(cognew(TxRx, @stack[0]))  'start TxRx cog
       
    
    
    term.out($0d)
    term.str(string("done"))
    pausems(1000)
         
    term.cls       
    LEDoff

'blinks LED using counter    
PUB blinkLED
    if heartBeat == 0
      LEDon
      heartBeat:=10
    else
      LEDoff
      heartBeat -= 1

PUB LEDon
    outa[_LED]~~
PUB LEDoff
    outa[_LED]~
 
PUB pausems(ms)
  waitcnt(cnt+clkfreq/1000*ms)

                 