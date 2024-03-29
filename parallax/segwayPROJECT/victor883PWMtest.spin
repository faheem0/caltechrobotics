'' victor883PWMtest.spin 
'12/25/2007
'use PRC with 883 connected to pin 0   through inverting/amplifying transistor
'works! uses mouse L/R buttons to increase/decrease the PWM output from 1ms to 2ms (1.5ms neutral)
'requiers prop terminal, uses mouse buttons on computer
'1/1/2008
'encoder reading added
'1/2/2008
'signal uninverted, victor 883 data obtained:
'deadband 1471 to 1540                          1488 1556  for L: 1489 to 1558
'1130/1150 = full reverse          for 666/614  1168              1146
'1893/1886 = full forward                       1906              1915

VAR
    long PWMValue
    long encCount,slipCount
    long stack[20]
    long timer,debug,debug2
    
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
    _pin =8
    _encA = 5
    _encB = 6
    

OBJ
    term:   "PC_Interface"
  
PUB main       |clkStart, clkStop

    INITIALIZATION
    
    term.str(string("pulsing"))
    {{repeat
      outa[_pin]:=0
      waitcnt(cnt+clkfreq*3)
      outa[_pin]:=1
      waitcnt(cnt+clkfreq*1)}}
      'PWMValue:=1700
    
    cognew(encoderLoop(_encA,_encB), @stack[0])
    repeat
      term.cls
      term.str(string("encCount: "))
      term.dec(encCount)
      term.out($0d)
      term.str(string("slipCount: "))
      term.dec(slipCount)
      term.out($0d)
      term.str(string("freq: ")) 
      term.dec(clkfreq/timer)
      term.out($0d)
      term.str(string("current state: ")) 
      term.bin(debug,2)
      term.out($0d)
      term.str(string("last state: ")) 
      term.bin(debug2,2)
      waitcnt(clkfreq/10+cnt)       


 {{   dira[12]:=1             'encoder test      
    repeat                  
      'term.out($0d)
      'term.dec(ina[13])
      outa[12]:=ina[11]
      waitcnt(clkfreq/1000+cnt)       }}
   
   
      
    repeat
      outa[_pin]:=1
      waitcnt(cnt+clkfreq/1_000_000*PWMValue)
      outa[_pin]:=0                                                             
      waitcnt(cnt+clkfreq/1_000*20)
      updatePWMValue    
    repeat    
      MAINLOOP
      
''quadrature encoder loop using QRD1114 IR LED/transistor pairs and hex nut on shaft
'Description:
  'the 2 sensors need to have a 90 degree phase shift, so the second must be
     '90+360k degrees from the first (relatively), where k is an integer
  'however, since we have 6 full cycles on a hex nut, divide by 6:
     '15+60k degrees
  'if k = 2, then the angle is simply 135 degrees (90 + 45), for easy mounting
'Timing:
  'current runs at roughly 3188Hz at 80MHz
  '(3188 cycle/sec)*(1 motorRev/24 cycles)*(60 sec/min) =7970 motorRev/min limit
    '(7970 motorRev/min)*(1 wheelRev/34 motorRev)*(1*3.14 feet/1 wheelRev)*(1mph/88 feet per minute) = 8.364mph theoretical limit
  '.046 inch resolution
  '  
'LED is connected to 3.3V thru 100 ohm resistor, transistor output is pulled to 3.3V thru 10k ohm
''runs in own cog and updates encCount      
PUB encoderLoop(encA,encB) | tempA,tempB,time,exit,lastState,currentState 
    
    repeat
        time:=cnt                                       
        tempA:=0
        tempB:=0         
        repeat 10
          tempA+=ina[encA]     'sample 10 times
          tempB+=ina[encB]
        currentState:=0        'update currentState
        if tempA>7             
          currentState++
        if tempB>7
          currentState+=2
        debug:=currentState
        debug2:=lastState
        if lastState<>currentState  'if change occured, update variables
          if lastState==%00
            if currentState==%01
              encCount++
            elseif currentState==%11
              slipCount++
            elseif currentState==%10
              encCount--
          elseif lastState==%01
            if currentState==%00
              encCount--
            elseif currentState==%11
              encCount++ 
            elseif currentState==%10
              slipCount++
          elseif lastState==%11
            if currentState==%00
              slipCount++
            elseif currentState==%01
              encCount--
            elseif currentState==%10
              encCount++ 
          elseif lastState==%10
            if currentState==%00
              encCount++ 
            elseif currentState==%01
              slipCount++
            elseif currentState==%11
              encCount--       
          'exit:=1
          lastState:=currentState   'if change occured also update lastState
        timer:=cnt-time 
 


PUB updatePWMValue
    if term.button(0)
      if(term.abs_x < 319/2) 
        PWMValue+=1
      else
        PWMValue+=10
    elseif term.button(1)
      if(term.abs_x < 319/2) 
        PWMValue-=1
      else
        PWMValue-=10
    
    PWMValue<#= 2000                
    PWMValue#>=1000
    term.dec(PWMValue)
    term.out($0d)    
PUB MAINLOOP
    term.str(string("pos: "))
    
    term.str(string(" slipcnt: "))
   

    
    term.str(string(" t: "))
    
    term.out($0D)
    waitcnt(clkfreq/10+cnt)
PUB INITIALIZATION
    term.start(31,30)
   ' repeat while term.abs_x == 0    'wait for PropTerminal.exe started
    term.str(string("starting up"))
    outa[_pin]:=1
    dira[_pin]:=1
    PWMValue:=1500
     waitcnt(clkfreq/2 + cnt)
    term.str(string("done"))
       