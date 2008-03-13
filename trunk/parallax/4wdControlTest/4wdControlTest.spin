'' File: 4wdControlTest.spin
'' Uses PRC to control 4wd toy RC car
''Version 1.0
''3/5/2008
{{history: 1.0 file started, untested
           1.1 pin 4 socket broken, pin 4,5 switched to 5,6
Known issues: untested
              

                                                        
                                  }}
{{ PIN   Purpose    Input  Output
    0    LMotorEN 
    1    LMotorD1
    2    LMotorD2 
    3    RMotorEN 
    4    <broken socket>
    5    RMotorD1 
    6    RMotorD2 
    7     LED                X    
    8    
    9     CompassDA  X       X 
    10    CompassEN          X
    11    CompassCL          X
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
    27                                    }}
{{COG usage:
  X  0: main cog
     1: motor PWM (h-bridges)
     2: 
     3: 
     4: 
     5: 
     6:
     7: 
    
                                                 }}
VAR
    long motorLeft   'duty cycle for h-bridges, -100 to 100 indicating %
    long motorRight
    
   
    long stack[60] 'for motor cog
 
    long heading
    long initialHeading
    long angleCount

    long currentAng
    long initialAng
    long angFromDesired
    long angChange
    
    
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
    

    _LMotorEN = 0
    _LMotorD1 = 1
    _LMotorD2 = 2

    _RMotorEN = 3
    _RMotorD1 = 5
    _RMotorD2 = 6
                                
    _HM55CL= 11
    _HM55EN= 10
    _HM55DA= 9

    _TURNINTERVAL = 90
    _EASEIN = _TURNINTERVAL - 10

    _DesiredTurnAng = 90
    _NearTarget = 10                    
    _DeadBand = 2               '2 degrees
    _ThresholdAngChange = 3     '3 degrees per 500 ms
    _MotorChangeStep = 10       'max is 100

OBJ
    term:   "PC_Interface"
    compass:    "HM55B Compass Module Asm"
   
PUB main

    INITIALIZATION         
    MAINLOOP         'turns 90 degrees clockwise from initialAng

PUB mainloop2     |key, speedIncrement
    speedIncrement:=10
    repeat
      term.cls
      term.str(string("compass reading: "))
      term.dec(compass.theta*10/227)
      term.out($0d)

      if term.gotkey
        key:=term.getkey
        
        case key
          119: 
            term.str(string("w"))
            motorLeft:=motorLeft+speedIncrement
            motorRight:=motorRight+speedIncrement
          97:
            term.str(string("a"))
            motorLeft:=motorLeft-speedIncrement
            motorRight:=motorRight+speedIncrement
          115:
            term.str(string("s"))
            motorLeft:=motorLeft-speedIncrement
            motorRight:=motorRight-speedIncrement
          100: 
            term.str(string("d"))
            motorLeft:=motorLeft+speedIncrement
            motorRight:=motorRight-speedIncrement
          32:
            term.str(string("space"))
            motorLeft:=0
            motorRight:=0
          194:
            term.str(string("up"))
            speedIncrement++
            speedIncrement<#=25
          195:
            term.str(string("down"))
            speedIncrement--
            speedIncrement#>=1
        motorLeft<#=100
        motorRight<#=100
        motorLeft#>=-100
        motorRight#>=-100

      term.str(string("mLeft: "))
      term.dec(motorLeft)
      term.str(string(" mRight: "))
      term.dec(motorRight)
      term.out($0d)
      term.str(string("speedIncrement: "))
      term.dec(speedIncrement)
      pausems(100)          


PUB MAINLOOP    | temp

     term.cls 
     initialAng := GETCURRENTANG
     term.str(string("initialAng: "))
     term.dec(initialAng)
     term.out($0d)
     
     'get car to start turning
     REPEAT UNTIL (GETANGCHANGE => _ThresholdAngChange) OR (GETCURRENTANG => initialAng + _desiredTurnAng - _nearTarget)
        motorLeft := motorLeft + _MotorChangeStep
        motorRight := motorRight - _MotorChangeStep
        term.str(string("angChange: "))   
        term.dec(angChange)
        term.out($0d)
        term.str(string("currentAng: "))   
        term.dec(currentAng)
        term.out($0d)
        term.str(string("motorLeft: "))   
        term.dec(motorLeft)
        term.out($0d)
        term.str(string("motorRight: "))   
        term.dec(motorRight)
        term.out($0d)
        term.out($0d)
        term.out($0d)

     term.cls
     
     'stops motors when nearTarget
     REPEAT WHILE (temp := 0)
        temp := 0
        if (GETCURRENTANG => initialAng + _desiredTurnAng - _nearTarget)
          motorLeft := 0
          motorRight := 0
          temp := 1
        term.str(string("currentAng: "))   
        term.dec(currentAng)
        term.out($0d)
        term.out($0d)
        term.out($0d)

     term.cls
     
     'inch till within deadBand
     REPEAT UNTIL ||GETANGFROMDESIRED =< _deadBand  
        if angFromDesired > 0
           motorLeft := 100
           motorRight := -100
        else
           motorLeft := -100
           motorRight := 100   
        pausems(100)
        motorLeft := 0
        motorRight := 0
        term.str(string("angFromDesired: "))   
        term.dec(angFromDesired)
        term.out($0d)
        term.out($0d)
        term.out($0d)
        
     
     
    
    'panServoStuff
    'TxRx     
    pausems(100)

PUB GETANGFROMDESIRED
                                'takes at least 50ms
    angFromDesired := (InitialAng + _desiredTurnAng - GETCURRENTANG)
    RETURN  angFromDesired    

PUB GETCURRENTANG   |sum

    sum := 0
      repeat 5                          'takes 50 ms
        sum := sum + compass.theta*10/227
        pausems(10)
    currentAng := sum/5
    Return currentAng

PUB GETANGCHANGE   |ang1, ang2          'signed ang change over 500 ms

    ang1 := GETCURRENTANG
    pausems(400)
    ang2 := GETCURRENTANG
    angChange := ang2 - ang1
    Return (angChange)         

'inits pins/objects/etc      
PUB INITIALIZATION
    motorLeft :=0
    motorRight :=0            
    
    term.start(31,30)     'start terminal COG
    term.str(string("starting up"))
    cognew(motorPWMLoop, @stack[0]) 'start MOTOR cog
       
    compass.start(_HM55EN,_HM55CL,_HM55DA )'start(EnablePin,ClockPin,DataPin):okay
    heading := compass.theta*10/227
    angleCount := 0
    initialHeading := heading
           
    term.str(string("done"))
    pausems(1000)
         
    term.cls


'motor control with h-bridges, runs on its own cog
'updates motor speed based on variables motorLeft and motorRight     
 ' pins....18,  21,  16,  17,  19,  20    
' 6 pins....enL, enR, d1L,d2L,d1R,d2R      
PUB motorPWMLoop | dt,motorLeftSpeed,motorRightSpeed, enL, enR

   
    dira[_LMotorEN.._RMotorD2]~~   'change to output
    outa[_LMotorEN.._RMotorD2]~~

    dT := 80_000_000/25_000'clkfreq / 25_000             ' 1kHz refresh rate
  
    repeat
      
      motorLeftSpeed:=motorLeft            'set local variable to current state of global one
      motorRightSpeed:=motorRight
      
      motorLeftSpeed<#=100                 'limit input from -100% to 100%
      motorLeftSpeed#>=-100
      motorRightSpeed<#=100
      motorRightSpeed#>=-100

      if motorLeftSpeed==0                      'set motor directions
        outa[_LMotorD1.._LMotorD2]:=%00              'written 2 different ways, both work
      elseif( motorLeftSpeed== (||motorLeftSpeed))
        outa[_LMotorD1.._LMotorD2]:=%10
      else
        outa[_LMotorD1.._LMotorD2]:=%01
      if motorRightSpeed < 0                      
        outa[_RMotorD1.._RMotorD2]:=%01
      elseif motorRightSpeed>0
        outa[_RMotorD1.._RMotorD2]:=%10  
      elseif motorRightSpeed==0
        outa[_RMotorD1.._RMotorD2]:=%00     

      motorLeftSpeed:=(||motorLeftSpeed)              'direction no longer needed, so abs value
      motorRightSpeed:=(||motorRightSpeed)
      
      if(motorLeftSpeed<>0)                        'start pins high
        outa[_LMotorEN]:=1                               
      if(motorRightSpeed<>0)
        outa[_RMotorEN]:=1
        
      'conditions for low duration                       
      if(motorLeftSpeed==0 and motorRightSpeed==0)           
        waitcnt(cnt+dT*100)
      elseif(motorRightSpeed<>0 and motorLeftSpeed==0)
        waitcnt(cnt+dt*(||motorRightSpeed))
        if(||motorRightSpeed<>100)
          outa[_RMotorEN]:=0
          waitcnt(cnt+dT*(100-||motorRightSpeed) )
      elseif(motorLeftSpeed<>0 and motorRightSpeed==0)
        waitcnt(cnt+dt*(||motorLeftSpeed))
        if(||motorLeftSpeed<>100)
          outa[_LMotorEN]:=0
          waitcnt(cnt+dT*(100-||motorLeftSpeed) )
      elseif(||motorLeftSpeed == ||motorRightSpeed)
        waitcnt(cnt+dT*(||motorLeftSpeed) )
        if(||motorRightSpeed<>100)
          outa[_LMotorEN]:=0
          outa[_RMotorEN]:=0
          waitcnt(cnt+dT*(100-||motorRightSpeed) )
      elseif(||motorLeftSpeed < ||motorRightSpeed)        
        waitcnt(cnt+dT*(||motorLeftSpeed) )
        outa[_LMotorEN]:=0
        waitcnt(cnt+dT*(||motorRightSpeed-||motorLeftSpeed) )      
        if(||motorRightSpeed<>100)
          outa[_RMotorEN]:=0             
          waitcnt(cnt+dT*(100-||motorRightSpeed) )
      elseif(||motorRightSpeed < ||motorLeftSpeed)
        waitcnt(cnt+dT*(||motorRightSpeed) )
        outa[_RMotorEN]:=0
        waitcnt(cnt+dT*(||motorLeftSpeed-||motorRightSpeed) )       
        if(||motorLeftSpeed<>100)
          outa[_LMotorEN]:=0
          waitcnt(cnt+dT*(100-||motorLeftSpeed) )    
PUB pausems(ms)
  waitcnt(cnt+clkfreq/1000*ms)


                                  