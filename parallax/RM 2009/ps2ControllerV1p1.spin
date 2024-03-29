''********************************
''*  PS2 Controller Driver v1.1  *
''********************************
VAR
  long attPin
  long cmdPin
  long clkPin
  long datPin

  long idx   'loop counter
 ' long psxOut 'byte to controller
 ' long psxIn 'byte from controller

  long ID, ThumbL, ThumbR, Status, JoyRX, JoyRY, JoyLX, JoyLY
  
  long timer
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz
    
    startByte = %00000001  '0x01
    getDat = %01000010  '0x42
    Inverted=1
    Direct=0
    clockMode=Direct

PUB start(ddat, cmd, att, clk)

    clkPin:=clk
    attPin:=att
    cmdPin :=cmd  
    datPin:=ddat
    
    'INIT
    dira[attPin]~~
    dira[cmdPin]~~
    dira[clkPin]~~
    dira[datPin]~
    outa[attPin]~~ 'deselect PSX controller
    outa[cmdPin]~
    outa[clkPin]:=!constant(clockMode) 'release clock



    {{
   
    repeat
      'term.str(string("loop"))
      'checkIR(24)
      term.cls
      'term.bin(mouse.buttons,5)   '0 = object detected
      'term.dec(mouse.abs_x)
      'term.dec(mouse.abs_y)
      timer:=cnt
      Get_PSX_Packet
      term.dec(cnt-timer)
      term.out($0D)
      
      term.dec(Status)
      term.out($0D)
      term.dec(ID)
      term.out($0D)
      term.bin(ThumbL,8)
      term.out($0D)
      term.bin(ThumbR,8)
      term.out($0D)
      term.dec(JoyRX)
      term.out($0D)
      term.dec(JoyRY)
      term.out($0D)
      term.dec(JoyLX)
      term.out($0D)
      term.dec(JoyLY)
      term.out($0D)


      
      'term.dec(mouse.abs_z)
      waitcnt(cnt+clkfreq/10)    }}
PUB update
    Get_PSX_Packet
PUB Get_PSX_Packet
  outa[attPin]~    'select controller
   
  PSX_TxRx(constant(startByte))        'send "start"   
  ID:=PSX_TxRx(constant(getDat))   'send "get data"  and save controller type
  outa[cmdPin]~    'clear to zero for rest of packet
 
  Status := PSX_Rx   'should be $5A ("ready")
  ThumbL := PSX_Rx    'get PSX data
  ThumbR := PSX_Rx   
  JoyRX  := PSX_Rx   
  JoyRY  := PSX_Rx 
  JoyLX  := PSX_Rx   
  JoyLY  := PSX_Rx
  
  outa[attPin] ~~ 'deselect controller
       
PUB PSX_TxRx(psxOut): psxIn
  outa[cmdPin]:= (psxOut)
  outa[clkPin]:=constant(clockMode)
  psxIn&=    %1111_1110
  if(ina[datPin])
    psxIn |= %0000_0001
  outa[clkPin]:= !constant(clockMode)     
  
  outa[cmdPin]:= (psxOut>>1)
  outa[clkPin]:=constant(clockMode)
  psxIn&=    %1111_1101
  if(ina[datPin])
    psxIn |= %0000_0010
  outa[clkPin]:= !constant(clockMode)

  outa[cmdPin]:= (psxOut>>2)
  outa[clkPin]:=constant(clockMode)
  psxIn&=    %1111_1011
  if(ina[datPin])
    psxIn |= %0000_0100
  outa[clkPin]:= !constant(clockMode)

  outa[cmdPin]:= (psxOut>>3)
  outa[clkPin]:=constant(clockMode)
  psxIn&=    %1111_0111
  if(ina[datPin])
    psxIn |= %0000_1000
  outa[clkPin]:= !constant(clockMode)

  outa[cmdPin]:= (psxOut>>4)
  outa[clkPin]:=constant(clockMode)
  psxIn&=    %1110_1111
  if(ina[datPin])
    psxIn |= %0001_0000
  outa[clkPin]:= !constant(clockMode)

  outa[cmdPin]:= (psxOut>>5)
  outa[clkPin]:=constant(clockMode)
  psxIn&=    %1101_1111
  if(ina[datPin])
    psxIn |= %0010_0000
  outa[clkPin]:= !constant(clockMode)

  outa[cmdPin]:= (psxOut>>6)
  outa[clkPin]:=constant(clockMode)
  psxIn&=    %1011_1111
  if(ina[datPin])
    psxIn |= %0100_0000
  outa[clkPin]:= !constant(clockMode)

  outa[cmdPin]:= (psxOut>>7)
  outa[clkPin]:=constant(clockMode)
  psxIn&= %01111111
  if(ina[datPin])
    psxIn |= %10000000
  outa[clkPin]:= !constant(clockMode)
  
PUB PSX_Rx: psxIn
  outa[clkPin]:=constant(clockMode)
  psxIn&=    %1111_1110
  if(ina[datPin])
    psxIn |= %0000_0001
  outa[clkPin]:= !constant(clockMode)     
  
  outa[clkPin]:=constant(clockMode)
  psxIn&=    %1111_1101
  if(ina[datPin])
    psxIn |= %0000_0010
  outa[clkPin]:= !constant(clockMode)

  outa[clkPin]:=constant(clockMode)
  psxIn&=    %1111_1011
  if(ina[datPin])
    psxIn |= %0000_0100
  outa[clkPin]:= !constant(clockMode)

  outa[clkPin]:=constant(clockMode)
  psxIn&=    %1111_0111
  if(ina[datPin])
    psxIn |= %0000_1000
  outa[clkPin]:= !constant(clockMode)

  outa[clkPin]:=constant(clockMode)
  psxIn&=    %1110_1111
  if(ina[datPin])
    psxIn |= %0001_0000
  outa[clkPin]:= !constant(clockMode)

  outa[clkPin]:=constant(clockMode)
  psxIn&=    %1101_1111
  if(ina[datPin])
    psxIn |= %0010_0000
  outa[clkPin]:= !constant(clockMode)

  outa[clkPin]:=constant(clockMode)
  psxIn&=    %1011_1111
  if(ina[datPin])
    psxIn |= %0100_0000
  outa[clkPin]:= !constant(clockMode)

  outa[clkPin]:=constant(clockMode)
  psxIn&= %01111111
  if(ina[datPin])
    psxIn |= %10000000
  outa[clkPin]:= !constant(clockMode)
      
   
PUB getStatus
  result:=Status
PUB getID
  result:=ID
PUB getThumbL
  result:=ThumbL
PUB getThumbR
  result:=ThumbR
PUB getJoyRY
  result:=JoyRY
PUB getJoyRX
  result:=JoyRX
PUB getJoyLY
  result:=JoyLY
PUB getJoyLX
  result:=JoyLX   
      
      