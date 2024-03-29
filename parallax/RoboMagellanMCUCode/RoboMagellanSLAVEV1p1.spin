'' File: RoboMagellanSLAVEV-p-.spin
'' For Caltech RoboMagellan 2008, code for SLAVE MCU only.
''     MASTER-has 2 ribbon cables, connects to CPU
''     SLAVE-has 1 larger ribbon cable, connects to MASTER MCU
''6/15/2008
{{history: 1.0 file copied from balancingBotPEKv4p7.spin, modified
                  Tested MCU-MCU protocol with working motor encoders.
                  Wrote encoder calibration helper method
                  Still need to test all 4 motors at once.
           1.1 simultaneously prints to debug 'terminal, sends to  master MCU
                  To test encoders, DO NOT reprogram the SLV-just connect programmer
                  trying to add autoleveling for compass
                  autolevel delaying/reseting allowed from MSTuart

Known issues: 

                   
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
    18  accX         X
    19  accY         X  
    20  servo   
    21  servo  
    22     
    23     
    24     
    25     
    26     
    27     
    
  COG usage:
     0: main cog (transmits encoder values constantly)/controls autoleveling
     1: servos
     2: uartMST-MCU
     3: encoder-left front
     4: encoder-left back           
     5: encoder-right back           
     6: encoder-right front           
     7: accelerometer      
    
                                                 }}
VAR

    long heartBeat  'for blinking the LED
    long stack[60]     
 
    long encoderLFFposition 
    long encoderLFBposition
    long encoderRFBposition
    long encoderRFFposition

    long arcsin[100]
    long arccos[100]

    long valXfilt
    long valYfilt
    long servoValRoll, servoValPitch

    long autoLevelCount
  
    
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

    _accX = 18
    _accY = 19
    _servoRoll = 20
    _servoPitch = 21

    'byte mask
    _byteMask = $FF
    'for serial protocol
    _startByte = 254
    _stopByte = 233
    _delayAutoLevel = 201
    _resetAutoLevel = 200
    _dataSendFreq = 30 'how many times per second to send all encoder data
                        


OBJ
    'term:   "PC_Interface"
  
    uartMST:   "FullDuplexSerial"
    encoderLF: "encoderCustomASM"
    encoderLB: "encoderCustomASM"
    encoderRB: "encoderCustomASM"
    encoderRF: "encoderCustomASM"
    acc: "MXD2125 Simple"
    servos: "Servo32"
  
PUB main  |temp
    
    INITIALIZATION
    {{repeat
      'term.cls
      'term.str(string("LF: "))
      'term.dec(encoderLF.getPos)
      'term.out($0d)
      'term.str(string("LB: "))
      'term.dec(encoderLB.getPos)
      'term.out($0d)
      'term.str(string("RB: "))
      'term.dec(encoderRB.getPos)
      'term.out($0d)
      'term.str(string("RF: "))
      'term.dec(encoderRF.getPos)
      'term.out($0d)
      
      pausems(100)   }}
     
     
     EncoderTest

    
    repeat                     'basic serial port test, use hyper 'terminal
      uartMST.tx(130)
      'term.dec(130)
      pausems(500)

PUB loop |count
    repeat
      count:=cnt
      'levelAccelerometer
      
      waitcnt(count+clkfreq/30)     
PUB levelAccelerometer| valX, valY,theta, phi, alpha, temp, sign 
    
      alpha:= 90
      'term.cls
      valX:=normalize(acc.x)
      valY:=normalize(acc.y)
      if(( (||valX))>200 or ( (||valY)+100)>200 )
        'term.str(string("OUT"))
        return
      ''term.dec(acc.x )
      ''term.out($0d)
      ''term.dec(acc.y)
      'return
      valXfilt:=(alpha*valXfilt+(100-alpha)*valX)/100 'low pass filter
      valYfilt:=(alpha*valYfilt+(100-alpha)*valY)/100 

      if valYfilt < 0
        sign :=1 
      else
        sign :=-1  'negative    , it's reversed
      temp:= ||valYfilt
      temp<#= 100
      temp#>=0
      theta:=arcsin[temp]*sign  'roll

      if valXfilt < 0
        sign :=-1 'negative
      else
        sign :=1
      temp:= ||valXfilt
      temp<#= 100
      temp#>=0       
      phi:=arcsin[temp]*sign    'pitch

      
      'term.str(string("valX: "))       
      'term.dec(valX)
      'term.out($0d)
      'term.str(string("valY: "))       
      'term.dec(valY)
      'term.out($0d)
      'term.str(string("valXfilt: "))       
      'term.dec(valXfilt)
      'term.out($0d)
      'term.str(string("valYfilt: "))       
      'term.dec(valYfilt)
      'term.out($0d)
      'term.str(string("theta (roll): "))       
      'term.dec(theta)
      'term.out($0d)
      'term.str(string("phi (pitch): "))
      'term.dec(phi)
      'term.out($0d) 

       {{if('term.button(0))
          if('term.abs_x < 319/2 and 'term.abs_y <216/2)
            'open
          elseif('term.abs_x < 319/2 and 'term.abs_y >216/2)    'lower left corner
            servoValRoll-=10
  
          elseif('term.abs_x > 319/2 and 'term.abs_y >216/2)      'lower right corner
            servoValPitch-=10
                 
       elseif 'term.button(1)
          if('term.abs_x < 319/2 and 'term.abs_y <216/2) 
            'open
          elseif('term.abs_x < 319/2 and 'term.abs_y >216/2)
            servoValRoll+=10
            
          elseif('term.abs_x > 319/2 and 'term.abs_y >216/2)
            servoValPitch+=10
         }}
       

       autoLevelCount--
       if autoLevelCount ==0
         servoValRoll-=theta*15    '110 is a conversion factor from degrees to PWM counts
         servoValPitch-=phi*15
         servos.set(_servoRoll, servoValRoll)
         servos.set(_servoPitch, servoValPitch)
         autoLevelCount:=5

       servoValRoll<#= 1750
       servoValRoll#>=1020
       servoValPitch<#= 1670
       servoValPitch#>=1120
       'term.str(string("RollVal: "))
       'term.dec(servoValRoll)
       'term.str(string("Pitch: "))
       'term.dec(servoValPitch)

       servos.set(_servoRoll, servoValRoll)
       servos.set(_servoPitch, servoValPitch)
      
PUB levelAccelerometerold |count, valX, valY, roll_meas, pitch_meas, theta, phi, pitch_calc ,temp_denom, temp
    initArcsin
    initArccos
    repeat
      count:=cnt
      pausems(100)
      'term.cls
      
      'acc.Get_XY(@valX, @valY)
      valX:=normalize(acc.x)
      valY:=normalize(acc.y)
      'term.str(string("x: "))
      'term.dec(valX)
      'term.out($0d)
      'term.str(string("y: "))
      'term.dec(valY)
      'term.out($0d)
      
      valY<#= 100
      valY#>=0
      valX<#= 100
      valX#>=0
      roll_meas := valY  'by definition
      pitch_meas := valX
      
      theta:=arcsin[roll_meas]                  
      'term.str(string("theta (roll): "))       
      'term.dec(theta)
      'term.out($0d)

      temp_denom:= sqrt(100*100-roll_meas*roll_meas)
      temp := 100* pitch_meas/temp_denom

      temp<#= 100
      temp #>=0
      phi := arccos[temp]
      'term.str(string("phi (pitch): "))
      'term.dec(phi)
      'term.out($0d)             
      
      
      
      waitcnt(cnt+clkfreq/30)     'MUST MULTIPLY THIS 10X???
'normalizes acceleration to % of a 1g       
PUB normalize( accVal)
    return (accVal-390000)/1000
PUB sqrt(num)  |i
    repeat i from 1 to 100
      if (i*i > num)
        return (i-1)
        
'transmits startByte, all the encoder data, then stop byte
PUB TxRx | cmdByte , counter,rx1,rx2,rx3,angle1,angle2, time, enct[4], i  ,temp
    pausems(10) 'allow time for startup
    repeat
      time:=cnt
      
      levelAccelerometer
      
      uartMST.tx(_startByte)
      'SEND ENCODER DATA HERE
      enct[0] := encoderLF.getPos
      enct[1] := encoderLB.getPos
      enct[2] := encoderRB.getPos
      enct[3] := encoderRF.getPos
      repeat i from 0 to 3
        
        ''term.dec(enct[i])
        ''term.out($0d)
        repeat 4
          uartMST.tx(enct[i] & _byteMask)
          enct[i] := enct[i] >> 8

      uartMST.tx(_stopByte)
      ''term.str(string("Current Count: "))
      temp:=uartMST.rxcheck   'check if accelerating...if so delay autoleveling
      if temp <> -1
        if temp == _delayAutoLevel
          autoLevelCount+=60
        elseif temp == _resetAutoLevel
          autoLevelCount:= 0
      waitcnt(clkfreq/_dataSendFreq+time)
      

PUB EncoderTest | i, back[4], temp[4], half, prevPos[4], _encTestSendFreq, time
    pausems(10) 'allow time for startup
    half := 0
    _encTestSendFreq := 384
    repeat i from 0 to 3
      back[i] := 0
      prevPos[i] := 0
    repeat
      time:=cnt
      temp[0] := encoderLF.getPos
      temp[1] := encoderLB.getPos
      temp[2] := encoderRB.getPos
      temp[3] := encoderRF.getPos
      repeat i from 0 to 3
        if temp[i] < prevPos[i]
          back[i]++
        prevPos[i] := temp[i]
      if(half == 40)
        'term.cls
        'term.str(string("ENCODER TEST: LF   LB   RB  RF"))
        'term.out($0d)
        'term.str(string("Current Cnt: "))
        repeat i from 0 to 3
           'term.dec(temp[i])
           'term.str(string(" "))
        'term.out($0d)
        'term.str(string("Back  Count: "))
        repeat i from 0 to 3   
           'term.dec(back[i])
           'term.str(string(" "))
        'term.out($0d)
        'term.str(string("Slip  Count: "))
        'term.dec(encoderLF.getSlipCount)
        'term.str(string(" "))
        'term.dec(encoderLB.getSlipCount)
        'term.str(string(" "))
        'term.dec(encoderRB.getSlipCount)
        'term.str(string(" "))
        'term.dec(encoderRF.getSlipCount)
        'term.out($0d)
        'term.str(string("d/dt(current) should be > 0"))
        'term.out($0d)
        'term.str(string("Back, Slip should be CONSTANT"))
        half := 0
      else
        half++ 
      if half <> 0 
        waitcnt(clkfreq/_encTestSendFreq+time)

'inits pins/objects/etc       
PUB INITIALIZATION
    encoderLFFposition:=0
    encoderLFBposition:=0
    encoderRFBposition:=0
    encoderRFFposition:=0   
    heartBeat :=0
    initArcsin
    initArccos
    autoLevelCount:=30*3
    
    LEDon
    dira[_LED]~~
    
    'term.start(31,30)     'start 'terminal COG
    'term.str(string("starting up"))
   
        
    uartMST.start(_uartMSTrx,_uartMSTtx, %0000 , 115200)'(rxpin, txpin, mode, baudrate) : okay
'' mode bit 0 = invert rx
'' mode bit 1 = invert tx
'' mode bit 2 = open-drain/source tx
'' mode bit 3 = ignore tx echo on rx

  
   
    encoderLF.start(_encLFa,_encLFb) 'starts new COG
    encoderLB.start(_encLBa,_encLBb) 'starts new COG
    encoderRB.start(_encRBa,_encRBb) 'starts new COG
    encoderRF.start(_encRFa,_encRFb) 'starts new COG

    servoValRoll:=1500
    servoValPitch:=1500 
    servos.set(_servoRoll,servoValRoll)
    servos.set(_servoPitch,servoValPitch)  
    servos.start     'start servo COG

    acc.start(_accX, _accY) 'start(xpin, ypin) : okay
    
    'term.out($0d)
    'term.str(string("cog #(0-7): "))
    ''term.dec(cognew(TxRx, @stack[0]))  'start TxRx COG   

    'term.out($0d)
    'term.str(string("done"))
    TxRx   
    
    
    
    pausems(1000)
         
    'term.cls       
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

PUB initArcsin
  arcsin  [       0       ]:=     0
  arcsin  [       1       ]:=     1
  arcsin  [       2       ]:=     1
  arcsin  [       3       ]:=     2
  arcsin  [       4       ]:=     2
  arcsin  [       5       ]:=     3
  arcsin  [       6       ]:=     3
  arcsin  [       7       ]:=     4
  arcsin  [       8       ]:=     5
  arcsin  [       9       ]:=     5
  arcsin  [       10      ]:=     6
  arcsin  [       11      ]:=     6
  arcsin  [       12      ]:=     7
  arcsin  [       13      ]:=     7
  arcsin  [       14      ]:=     8
  arcsin  [       15      ]:=     9
  arcsin  [       16      ]:=     9
  arcsin  [       17      ]:=     10
  arcsin  [       18      ]:=     10
  arcsin  [       19      ]:=     11
  arcsin  [       20      ]:=     12
  arcsin  [       21      ]:=     12
  arcsin  [       22      ]:=     13
  arcsin  [       23      ]:=     13
  arcsin  [       24      ]:=     14
  arcsin  [       25      ]:=     14
  arcsin  [       26      ]:=     15
  arcsin  [       27      ]:=     16
  arcsin  [       28      ]:=     16
  arcsin  [       29      ]:=     17
  arcsin  [       30      ]:=     17
  arcsin  [       31      ]:=     18
  arcsin  [       32      ]:=     19
  arcsin  [       33      ]:=     19
  arcsin  [       34      ]:=     20
  arcsin  [       35      ]:=     20
  arcsin  [       36      ]:=     21
  arcsin  [       37      ]:=     22
  arcsin  [       38      ]:=     22
  arcsin  [       39      ]:=     23
  arcsin  [       40      ]:=     24
  arcsin  [       41      ]:=     24
  arcsin  [       42      ]:=     25
  arcsin  [       43      ]:=     25
  arcsin  [       44      ]:=     26
  arcsin  [       45      ]:=     27
  arcsin  [       46      ]:=     27
  arcsin  [       47      ]:=     28
  arcsin  [       48      ]:=     29
  arcsin  [       49      ]:=     29
  arcsin  [       50      ]:=     30
  arcsin  [       51      ]:=     31
  arcsin  [       52      ]:=     31
  arcsin  [       53      ]:=     32
  arcsin  [       54      ]:=     33
  arcsin  [       55      ]:=     33
  arcsin  [       56      ]:=     34
  arcsin  [       57      ]:=     35
  arcsin  [       58      ]:=     35
  arcsin  [       59      ]:=     36
  arcsin  [       60      ]:=     37
  arcsin  [       61      ]:=     38
  arcsin  [       62      ]:=     38
  arcsin  [       63      ]:=     39
  arcsin  [       64      ]:=     40
  arcsin  [       65      ]:=     41
  arcsin  [       66      ]:=     41
  arcsin  [       67      ]:=     42
  arcsin  [       68      ]:=     43
  arcsin  [       69      ]:=     44
  arcsin  [       70      ]:=     44
  arcsin  [       71      ]:=     45
  arcsin  [       72      ]:=     46
  arcsin  [       73      ]:=     47
  arcsin  [       74      ]:=     48
  arcsin  [       75      ]:=     49
  arcsin  [       76      ]:=     49
  arcsin  [       77      ]:=     50
  arcsin  [       78      ]:=     51
  arcsin  [       79      ]:=     52
  arcsin  [       80      ]:=     53
  arcsin  [       81      ]:=     54
  arcsin  [       82      ]:=     55
  arcsin  [       83      ]:=     56
  arcsin  [       84      ]:=     57
  arcsin  [       85      ]:=     58
  arcsin  [       86      ]:=     59
  arcsin  [       87      ]:=     60
  arcsin  [       88      ]:=     62
  arcsin  [       89      ]:=     63
  arcsin  [       90      ]:=     64
  arcsin  [       91      ]:=     66
  arcsin  [       92      ]:=     67
  arcsin  [       93      ]:=     68
  arcsin  [       94      ]:=     70
  arcsin  [       95      ]:=     72
  arcsin  [       96      ]:=     74
  arcsin  [       97      ]:=     76
  arcsin  [       98      ]:=     79
  arcsin  [       99      ]:=     82
  arcsin  [       100     ]:=     90
PUB initArccos   
  arccos  [       0       ]:=     90
  arccos  [       1       ]:=     89
  arccos  [       2       ]:=     89
  arccos  [       3       ]:=     88
  arccos  [       4       ]:=     88
  arccos  [       5       ]:=     87
  arccos  [       6       ]:=     87
  arccos  [       7       ]:=     86
  arccos  [       8       ]:=     85
  arccos  [       9       ]:=     85
  arccos  [       10      ]:=     84
  arccos  [       11      ]:=     84
  arccos  [       12      ]:=     83
  arccos  [       13      ]:=     83
  arccos  [       14      ]:=     82
  arccos  [       15      ]:=     81
  arccos  [       16      ]:=     81
  arccos  [       17      ]:=     80
  arccos  [       18      ]:=     80
  arccos  [       19      ]:=     79
  arccos  [       20      ]:=     78
  arccos  [       21      ]:=     78
  arccos  [       22      ]:=     77
  arccos  [       23      ]:=     77
  arccos  [       24      ]:=     76
  arccos  [       25      ]:=     76
  arccos  [       26      ]:=     75
  arccos  [       27      ]:=     74
  arccos  [       28      ]:=     74
  arccos  [       29      ]:=     73
  arccos  [       30      ]:=     73
  arccos  [       31      ]:=     72
  arccos  [       32      ]:=     71
  arccos  [       33      ]:=     71
  arccos  [       34      ]:=     70
  arccos  [       35      ]:=     70
  arccos  [       36      ]:=     69
  arccos  [       37      ]:=     68
  arccos  [       38      ]:=     68
  arccos  [       39      ]:=     67
  arccos  [       40      ]:=     66
  arccos  [       41      ]:=     66
  arccos  [       42      ]:=     65
  arccos  [       43      ]:=     65
  arccos  [       44      ]:=     64
  arccos  [       45      ]:=     63
  arccos  [       46      ]:=     63
  arccos  [       47      ]:=     62
  arccos  [       48      ]:=     61
  arccos  [       49      ]:=     61
  arccos  [       50      ]:=     60
  arccos  [       51      ]:=     59
  arccos  [       52      ]:=     59
  arccos  [       53      ]:=     58
  arccos  [       54      ]:=     57
  arccos  [       55      ]:=     57
  arccos  [       56      ]:=     56
  arccos  [       57      ]:=     55
  arccos  [       58      ]:=     55
  arccos  [       59      ]:=     54
  arccos  [       60      ]:=     53
  arccos  [       61      ]:=     52
  arccos  [       62      ]:=     52
  arccos  [       63      ]:=     51
  arccos  [       64      ]:=     50
  arccos  [       65      ]:=     49
  arccos  [       66      ]:=     49
  arccos  [       67      ]:=     48
  arccos  [       68      ]:=     47
  arccos  [       69      ]:=     46
  arccos  [       70      ]:=     46
  arccos  [       71      ]:=     45
  arccos  [       72      ]:=     44
  arccos  [       73      ]:=     43
  arccos  [       74      ]:=     42
  arccos  [       75      ]:=     41
  arccos  [       76      ]:=     41
  arccos  [       77      ]:=     40
  arccos  [       78      ]:=     39
  arccos  [       79      ]:=     38
  arccos  [       80      ]:=     37
  arccos  [       81      ]:=     36
  arccos  [       82      ]:=     35
  arccos  [       83      ]:=     34
  arccos  [       84      ]:=     33
  arccos  [       85      ]:=     32
  arccos  [       86      ]:=     31
  arccos  [       87      ]:=     30
  arccos  [       88      ]:=     28
  arccos  [       89      ]:=     27
  arccos  [       90      ]:=     26
  arccos  [       91      ]:=     24
  arccos  [       92      ]:=     23
  arccos  [       93      ]:=     22
  arccos  [       94      ]:=     20
  arccos  [       95      ]:=     18
  arccos  [       96      ]:=     16
  arccos  [       97      ]:=     14
  arccos  [       98      ]:=     11
  arccos  [       99      ]:=     8
  arccos  [       100     ]:=     0
                   