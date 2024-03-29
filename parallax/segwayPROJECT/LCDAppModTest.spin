'' File: LCDAppModTest.spin

VAR
   long buttons
  
   long timer
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
    
    
OBJ
    
    display    :  "LCDAppMod"
PUB mainMethod
       
    waitcnt(cnt+clkfreq/2)
    dira[9]~~
    'DECLARE PINS
    display.start(4,5,6,0,1,2,3) '(e, rw, rs, db4, db5, db6, db7)
    'display.displayOn
    'display.cursorOn
    'display.blinkOn
    display.write(%01000001)                   
    repeat
      'display.write(%01000011)
      'display.write(%01000001)
      waitcnt(clkfreq/2+ cnt)  
      display.clearScr
      'waitcnt(clkfreq/500+ cnt)
      display.num(2)
      waitcnt(clkfreq/500+ cnt) 
      'display.readButtons
      display.bin(display.readButtons,4)
      'display.moveTo(2,4)
      waitcnt(clkfreq/2+ cnt)
      
      'display.str(String("PARALLAX"))
      outa[9]:=!outa[9]
      waitcnt(cnt+clkfreq/2)