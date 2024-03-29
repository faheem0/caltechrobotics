
'' File: IRDetectTest.spin

VAR
    
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz

OBJ
    term   :       "PC_Interface"
    IRDetect: "Ir Detector"
PUB mainMethod

    term.start(31,30)
   ' repeat while term.abs_x == 0    'wait for PropTerminal.exe started
    term.str(string("starting up"))
  
    'dira[24..27]:= %1010
    IRDetect.init(26,27)
    repeat
      'term.str(string("loop"))
      'checkIR(24)
      term.cls
      term.dec(IRDetect.distance)   '0 = object detected
      waitcnt(cnt+clkfreq/10)

'uses startPin to startPin+4      
PUB checkIR(startPin): result |T,temp
    {{ BS2 code:
    FREQOUT leftIRTrans,1,38500
    IRDetectLeft=IN11
    FREQOUT rightIRTrans,1,38500
    IRDetectRight=IN5}}
    '38500 ~ 26 us
    '400-600 us at least
    term.str(string("checkIR"))
    temp:=cnt
    repeat 10
      'T:=cnt
      outa[startPin]~ 'on cycle
      'term.str(string("flag"))
      waitcnt(381+cnt)'1039)
      'term.str(string("flag"))
      'T:=cnt
      outa[startPin]~~   'off cycle
      waitcnt(381+cnt)'1039)
   
    term.dec(cnt-temp)

  {{  term.cls  
    if(ina[startPin+1])
      term.dec(1)
    else
      term.dec(0)}}
  {{  if(ina[startPin+3])
      term.dec(1)
    else
      term.dec(0)     }}
      
      
      