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
    27     
    
  COG usage:
     0: main cog
     1: terminal window/DAQ/graph
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
    _LED = 7            
    _uartMSTrx = 14
    _uartMSTtx = 15

    _encLFa = 0
    _encLFb = 1
    _encLBa = 2
    _encLBb = 3
    _encRBa = 4
    _encRBb = 5
    _encRFa = 6
    _encRFb = 7
    
    'for serial protocol
    _startByte = 254
    _stopByte = 233
    _cmdSetSpeed =217
    _cmdAck =218
    _cmdTurnAbs=220
    _cmdTurnRel=221
    _cmdStop=999
                        


OBJ
    term:   "PC_Interface"
  
    uartMST:   "FullDuplexSerial"
    encoderLF: "encoderCustomASM"
    encoderLB: "encoderCustomASM"
    encoderRB: "encoderCustomASM"
    encoderRF: "encoderCustomASM"
  
PUB main  |temp
    
    INITIALIZATION
    {{repeat                     'basic serial port test, use hyper terminal
      temp:=uartMST.rx
      if temp <>0
        term.dec(temp)
        term.out($0d)
        'uartMST.tx(temp+1)      }}
    'repeat
    '  term.dec(compass.theta)
    '  waitcnt(cnt+clkfreq/5)
    '  term.out($0d)
    'repeat
     ' term.dec(compass.theta*10/227)
      
      'term.out($0d)
      'term.cls
   
                           
    term.str(string("done turning"))
    repeat
      
      
      term.out($0d)
      pausems(100)
      term.cls
    'repeat
    repeat
      
      'term.cls
      TxRx
      pausems(100)
    'v883motorPWMTest
    'v883motorPWMTestPSX
    'PIDmotorLoop(1)
    'printAngle
    'printAngleDAQ
     'printAngleGraph
    'printGyro
    'angleBalanceLoop  


    

'receives 3 bytes: start, command, data    
PUB TxRx | cmdByte , counter,rx1,rx2,rx3,angle1,angle2
    'receive data
    counter :=0
    repeat while (uartMST.rxtime(1000) <> _startByte)  'wait for start byte
      'term.cls
      'otorLeft:=motorRight:=0
      'term.str(string("waiting for byte..."))
      'term.dec(counter++)
    cmdByte :=uartMST.rx
    case  cmdByte                                   'get and parse command byte
      _cmdSetSpeed:
        term.str(string("set speed: "))
        rx1:= uartMST.rx-100 
        rx2:=uartMST.rx-100 
        rx3:=uartMST.rx
        if rx3 <> _stopByte
          term.str(string("invalid data packet"))
        else
          term.dec(rx1)
          term.str(string(" "))
          term.dec(rx2)
          'motorLeft:=rx1
          'motorRight:=rx2
      _cmdTurnAbs:
          term.str(string("turn abs: "))
          angle1:=uartMST.rx
          angle2:=uartMST.rx
          if rx3 <> _stopByte
            term.str(string("invalid data packet"))
          else
            angle1:=angle1+angle2
            term.dec(angle1)
            term.str(string(" degrees"))
            uartMST.tx(_cmdTurnAbs)   'confirm command
            'TURNTOANGLE(angle1)
            uartMST.tx(_cmdAck)       'done turning
      _cmdTurnRel:   'fill in
           term.str(string("turn rel: "))
      _cmdStop:
          term.str(string("stop: "))
          
                                
          
          
      other:
        term.str(string("invalid command"))
    term.out($0d)  

    'transmit data    
    '
    uartMST.tx(_stopByte)
      


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
   
        
    uartMST.start(_uartMSTrx,_uartMSTtx, %0011 , 9600)'(rxpin, txpin, mode, baudrate) : okay
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
    'term.dec(cognew(PIDmotorLoop(0), @stack5[0]))  'start motor PID control loop COG
    term.out($0d)
       
    
    
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

                 