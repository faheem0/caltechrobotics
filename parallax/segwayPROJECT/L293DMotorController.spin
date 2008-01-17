
'' L293DMotorController.spin 
'12/1/2007
'version 1.0
'for using wtih L293D or equilalent motor controller, with the 2 sides wired in parallel
{{  DOES NTO WORK

 How to use it:
  OBJ
    motor: "L293DMotorController"
  PUB main 
    motor.start(<pinD1>, <pinD1>,<pinEnable>)
    motor.setSpeed(-100)    'full speed backwards
    motor.setSpeed(0)       'stop
    motor.setSpeed(100)     'full speed forwards
    

                                          }}
VAR
    long D1,D2,En      'global variables, order of these is important!
    long motorSpeed
    long cog

 
PUB start(pD1, pD2,pEnable)      

    D1:=pD1
    D2:=pD2
    En:=pEnable
               
    if cog
      cogstop(cog~ - 1)   
    cog := cognew(motorPWMLoop, @D1) + 1       'starta  new cog running at 'init' with memory block at 'pos'
PUB setSpeed(newSpeed)
    newSpeed<#=100                 'limit input from -100% to 100%
    newSpeed#>=-100
    motorSpeed:=newSpeed   
           
PUB motorPWMLoop | dt,mSpeed,motorRightSpeed

    outa[D1]:=0   'set output value to 0
    outa[D2]:=0
    outa[En]:=0
    dira[D1]:=1   'set to output
    dira[D2]:=1
    dira[En]:=1 
    
    dT := 80_000_000/25_000  'clkfreq / 25_000             ' 1kHz refresh rate
  
    repeat
      
      mSpeed:=motorSpeed            'set local variable to current state of global one   
      if ( mSpeed == 0 )                     'set motor directions
        outa[D1]:=0
        outa[D2]:=0 
      elseif( mSpeed > 0)
        outa[D1]:=1
        outa[D2]:=0
      else
        outa[D1]:=0
        outa[D2]:=1

      mSpeed:=(||mSpeed)              'direction no longer needed, so abs value
            
      if(mSpeed<>0)                        'start pins high
        outa[En]:=1

      'conditions for low duration                       
      if(mSpeed==0 )         
        waitcnt(cnt+dT*100)  
      else 'if(mSpeed<>0 and motorRightSpeed==0)
        waitcnt(cnt+dt*(mSpeed))
        if(mSpeed<>100)
          outa[En]:=0
          waitcnt(cnt+dT*(100-||mSpeed) )
      