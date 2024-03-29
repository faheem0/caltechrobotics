'' LIS3LV02DQaccTest.spin 
'12/27/2007
'use PRC and accelerometer connected to 4 pins
  'doesnt work, not sure if its the accelerometer or the code
VAR
    long address,temp
    
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
    _CS =4
    _CLK = 5
    _DI = 6
    _DO = 7
    

OBJ
    term:   "PC_Interface"
    
PUB main             
    INITIALIZATION
    temp:=1
    temp:= temp<<1
    term.bin(temp,8)
    'repeat
    dira[8]:=1
    outa[8]:=0
    outa[8]:=(3==3)      
    MAINLOOP         
    
PUB MAINLOOP
    
    repeat
      address:=%0101000  'OUTX_L
      term.cls
      term.str(string("address: "))
      term.bin(address,6)
      term.out($0d)
      term.str(string("byte read: "))
      term.bin(readByte,12)
      term.out($0d)
      term.str(string("temp: "))
      term.bin(temp,8)
      waitcnt(clkfreq/10+cnt)
PUB INITIALIZATION
    term.start(31,30)
   ' repeat while term.abs_x == 0    'wait for PropTerminal.exe started
    term.str(string("starting up"))

    outa[_CS]:=1
    outa[_CLK]:=1  
    
    dira[_CS]:=1
    dira[_CLK]:=1
    dira[_DO]:=1
    dira[_DI]:=0
    
     waitcnt(clkfreq/2 + cnt)
    term.str(string("done"))

PUB readByte |data
    outa[_CS]:=0  'enable chip
    
    outa[_DO]:=1 'read
    clkLow
    clkHigh
    
    outa[_DO]:=0
    clkLow
    clkHigh

    'term.out($0d)
    temp:=0
    repeat 6
      outa[_DO]:= (%100000 == (%100000 & address) )
      clkLow
      clkHigh
      temp:=temp<<1
      if(%100000 == (%100000 & address) )
        temp|= %1
      'term.bin((%100000 == (%100000 & address) ),8)
      
      address:= address << 1
    'term.out($0d)
    data:=0
    repeat 8
      clkLow
      clkHigh
      data:=data<<1
      if ina[_DI]
        data|=%1
      
    
    
    outa[_CS]:=1
    return data

PUB clkLow
    outa[_CLK]:=0
    waitcnt(cnt+clkfreq/10_000)
PUB clkHigh
    outa[_CLK]:=1
    waitcnt(cnt+clkfreq/10_000)     