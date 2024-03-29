'' File: 4wdControlTest.spin
'' Uses PRC to control 4wd toy RC car
''Version 1.0
''3/5/2008
{{history: 1.0 file started, untested
Known issues: untested
              

                                                        
                                  }}
{{ PIN   Purpose    Input  Output
    0     acc-CS             X
    1     acc-DIO    X       X
    2     acc-CLK            X
    3     encL       X
    4     encL       X
    5     encR       X
    6     encR       X
    7     LED                X    
    8     motL               X
    9     motR               X
    10    gyroAux            X
    11    gyroOut            X
    12    gyroIn     X
    13                               
    14     UART-rx   X
    15     UART-tx           X
    16     D1L               X    
    17     D2L               X    
    18     ENL               X   
    19     D1R               X              
    20     D2R               X
    21     ENR               X  
    22     servo             X
    23     
    24     psx-DAT   X 
    25     psx-CMD           X
    26     psx-ATT           X
    27     psx-CLK           X              }}
{{COG usage:
  X  0: main cog
     1: terminal window/DAQ/graph
     2: motor PWM (h-bridges)
     3: scanning servo + IR measurements
     4: uart (xbee?)
     5: servo PWM: servos, gyros, v883's
  
     7: psx
    (8): gyro PWM reading
   X (9): filter calculating
   X  (10): encoder #1
   X  (11): encoder #2
      (12): motor PID loop
    
                                                 }}
VAR
    long motorLeft   'duty cycle for h-bridges, -100 to 100 indicating %
    long motorRight
    
   
    long stack[60] 'for motor cog
 
    

  
    
    
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
    
   
    _motL = 8
    _motR = 9
                                
    

OBJ
    term:   "PC_Interface"
   
PUB main

    INITIALIZATION         
    repeat                   
      MAINLOOP    


PUB MAINLOOP    |temp
    
               
    
    'term.cls  
    'printScan
    
    
    
    'panServoStuff
    'TxRx     
    waitcnt(clkfreq/100+cnt)

    

'inits pins/objects/etc       
PUB INITIALIZATION
    motorLeft :=0
    motorRight :=0             
    
    term.start(31,30)     'start terminal COG
    term.str(string("starting up"))
    cognew(motorPWMLoop, @stack[0]) 'start MOTOR cog     
    
    term.str(string("done"))
    pausems(1000)
         
    term.cls


'motor control with h-bridges, runs on its own cog
'updates motor speed based on variables motorLeft and motorRight     
 ' pins....18,  21,  16,  17,  19,  20    
' 6 pins....enL, enR, d1L,d2L,d1R,d2R      
PUB motorPWMLoop | dt,motorLeftSpeed,motorRightSpeed, enL, enR

   
    dira[16..21]~~   'change to output
    outa[16..21]~~
    enL:=18
    enR:=21
    dT := 80_000_000/25_000'clkfreq / 25_000             ' 1kHz refresh rate
  
    repeat
      
      motorLeftSpeed:=motorLeft            'set local variable to current state of global one
      motorRightSpeed:=motorRight
      
      motorLeftSpeed<#=100                 'limit input from -100% to 100%
      motorLeftSpeed#>=-100
      motorRightSpeed<#=100
      motorRightSpeed#>=-100

      if motorLeftSpeed==0                      'set motor directions
        outa[16..17]:=%00              'written 2 different ways, both work
      elseif( motorLeftSpeed== (||motorLeftSpeed))
        outa[16..17]:=%10
      else
        outa[16..17]:=%01
      if motorRightSpeed < 0                      
        outa[19..20]:=%01
      elseif motorRightSpeed>0
        outa[19..20]:=%10  
      elseif motorRightSpeed==0
        outa[19..20]:=%00     

      motorLeftSpeed:=(||motorLeftSpeed)              'direction no longer needed, so abs value
      motorRightSpeed:=(||motorRightSpeed)
      
      if(motorLeftSpeed<>0)                        'start pins high
        outa[enL]:=1                               
      if(motorRightSpeed<>0)
        outa[enR]:=1

      'conditions for low duration                       
      if(motorLeftSpeed==0 and motorRightSpeed==0)           
        waitcnt(cnt+dT*100)
      elseif(motorRightSpeed<>0 and motorLeftSpeed==0)
        waitcnt(cnt+dt*(||motorRightSpeed))
        if(||motorRightSpeed<>100)
          outa[enR]:=0
          waitcnt(cnt+dT*(100-||motorRightSpeed) )
      elseif(motorLeftSpeed<>0 and motorRightSpeed==0)
        waitcnt(cnt+dt*(||motorLeftSpeed))
        if(||motorLeftSpeed<>100)
          outa[enL]:=0
          waitcnt(cnt+dT*(100-||motorLeftSpeed) )
      elseif(||motorLeftSpeed == ||motorRightSpeed)
        waitcnt(cnt+dT*(||motorLeftSpeed) )
        if(||motorRightSpeed<>100)
          outa[enL]:=0
          outa[enR]:=0
          waitcnt(cnt+dT*(100-||motorRightSpeed) )
      elseif(||motorLeftSpeed < ||motorRightSpeed)        
        waitcnt(cnt+dT*(||motorLeftSpeed) )
        outa[enL]:=0
        waitcnt(cnt+dT*(||motorRightSpeed-||motorLeftSpeed) )      
        if(||motorRightSpeed<>100)
          outa[enR]:=0             
          waitcnt(cnt+dT*(100-||motorRightSpeed) )
      elseif(||motorRightSpeed < ||motorLeftSpeed)
        waitcnt(cnt+dT*(||motorRightSpeed) )
        outa[enR]:=0
        waitcnt(cnt+dT*(||motorLeftSpeed-||motorRightSpeed) )       
        if(||motorLeftSpeed<>100)
          outa[enL]:=0
          waitcnt(cnt+dT*(100-||motorLeftSpeed) )    
PUB pausems(ms)
  waitcnt(cnt+clkfreq/1000*ms)


                                  