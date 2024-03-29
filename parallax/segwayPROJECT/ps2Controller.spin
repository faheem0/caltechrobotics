''********************************
''*  PS2 Controller Driver v1.0  *
''********************************
'button preasure readings: 12 extra bytes
'small motor vibrate
VAR
  long attPin
  long cmdPin
  long clkPin
  long datPin     

  long ID, ThumbL, ThumbR, Status, JoyRX, JoyRY, JoyLX, JoyLY
  long extra[12]
  
  long timer
CON
   
    start = %00000001  '0x01
    getDat = %01000010  '0x42
    Inverted=1
    Direct=0
    clockMode=Direct

PUB startUp(ddat, cmd, att, clk)

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
    outa[clkPin]:=!clockMode 'release clock
    waitcnt(clkfreq/1000+cnt)

 
PUB Get_PSX_Packet(vibSmall, vibLarge)
  outa[attPin]~    'select controller
   
  PSX_TxRx($01)        'send "start"   
  ID:=PSX_TxRx($43)   'send "get data"  and save controller type
   
  Status := PSX_TxRx(0)   'should be $5A ("ready")
  ThumbL := PSX_TxRx(vibSmall)    'get PSX data
  ThumbR := PSX_TxRx(vibLarge)   
  JoyRX  := PSX_TxRx(0)   
  JoyRY  := PSX_TxRx(0) 
  JoyLX  := PSX_TxRx(0)   
  JoyLY  := PSX_TxRx(0)
  if ID == 65
    extra[0] := PSX_TxRx(0)
    extra[1] := PSX_TxRx(0)
    extra[2] := PSX_TxRx(0)
    extra[3] := PSX_TxRx(0)
    extra[4] := PSX_TxRx(0)
    extra[5] := PSX_TxRx(0)
    extra[6] := PSX_TxRx(0)
    extra[7] := PSX_TxRx(0)
    extra[8] := PSX_TxRx(0)
    extra[9] := PSX_TxRx(0)
    extra[10] := PSX_TxRx(0)
    extra[11] := PSX_TxRx(0)
  
    
  outa[attPin] ~~ 'deselect controller
PUB Init_Controller
  Enter_Config_Mode
  'Set_Mode_Analog
  SET_DS2_NATIVE_MODE '2 soesnt work
  Enter_Vibrate_Mode
  EXIT_DS2_NATIVE_MODE
  Exit_Config_Mode
PUB Enter_Config_Mode                                               
  outa[attPin]~    'select controller
  PSX_TxRx($01) 
  PSX_TxRx($43)
  PSX_TxRx(0)
  PSX_TxRx($01)
  PSX_TxRx(0)
  outa[attPin] ~~ 'deselect controller 

PUB Set_Mode_Analog
  outa[attPin]~    'select controller
  PSX_TxRx($01) 
  PSX_TxRx($4F)
  PSX_TxRx(0)
  PSX_TxRx($FF)
  PSX_TxRx($FF)
  PSX_TxRx($03)
  outa[attPin] ~~ 'deselect controller
PUB Set_Mode_Digital
  outa[attPin]~    'select controller
  PSX_TxRx($01) 
  PSX_TxRx($44)
  PSX_TxRx(0)
  PSX_TxRx(0)
  PSX_TxRx($03)
  outa[attPin] ~~ 'deselect controller  
PUB SET_DS2_NATIVE_MODE
  outa[attPin]~    'select controller
  PSX_TxRx($01) 
  PSX_TxRx($44)
  PSX_TxRx(0)
  PSX_TxRx($01)
  PSX_TxRx($03)
  outa[attPin] ~~ 'deselect controller
PUB SET_DS2_NATIVE_MODE2
  outa[attPin]~    'select controller
  PSX_TxRx($01) 
  PSX_TxRx($4F)
  PSX_TxRx(0)
  PSX_TxRx($FF)
  PSX_TxRx($FF)
  PSX_TxRx($03)
  PSX_TxRx(0)
  PSX_TxRx(0)
  PSX_TxRx(0)
  outa[attPin] ~~ 'deselect controller  
PUB Enter_Vibrate_Mode
  outa[attPin]~    'select controller
  PSX_TxRx($01) 
  PSX_TxRx($4D)
  PSX_TxRx(0)
  PSX_TxRx(0)
  PSX_TxRx($01)
  PSX_TxRx($FF)
  PSX_TxRx($FF)
  PSX_TxRx($FF)
  PSX_TxRx($FF)
  outa[attPin] ~~ 'deselect controller
PUB EXIT_DS2_NATIVE_MODE
  outa[attPin]~    'select controller
  PSX_TxRx($01) 
  PSX_TxRx($43)
  PSX_TxRx(0)
  PSX_TxRx(0)
  PSX_TxRx($5A)
  PSX_TxRx($5A)
  PSX_TxRx($5A)
  PSX_TxRx($5A)
  PSX_TxRx($5A) 
  outa[attPin] ~~ 'deselect controller
PUB Exit_Config_Mode
  outa[attPin]~    'select controller
  PSX_TxRx($01) 
  PSX_TxRx($43)
  PSX_TxRx(0)
  PSX_TxRx(0)
  PSX_TxRx(0)
  outa[attPin] ~~ 'deselect controller   
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
PUB extra0
  result:=extra[0]
PUB extra1
  result:=extra[1]
PUB extra2
  result:=extra[2]
PUB extra3
  result:=extra[3]
PUB extra4
  result:=extra[4]
PUB extra5
  result:=extra[5]
PUB extra6
  result:=extra[6]
PUB extra7
  result:=extra[7]
PUB extra8
  result:=extra[8]
PUB extra9
  result:=extra[9]
PUB extra10
  result:=extra[10]
PUB extra11
  result:=extra[11]   
  
PUB PSX_TxRx(psxOut):psxIn |idx
  repeat idx from 0 to 7
    outa[cmdPin]:= (((psxOut>>idx)&1)==1)
    outa[clkPin]:=clockMode
    psxIn&= !(1<<idx)
    if(ina[datPin])
      psxIn |= (1<<idx)
    outa[clkPin]:= !clockMode    

      
      