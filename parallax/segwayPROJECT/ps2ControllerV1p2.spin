
'' PS2 Controller Driver v1.2  
' not working yet!

obj


var
        long ID, ThumbL, ThumbR, Status, JoyRX, JoyRY, JoyLX, JoyLY
        long cog
con
    start  = %00000001  '0x01
    getDat = %01000010  '0x42
    
pub startUp(ddat, cmd, att, clk)  

    clkPin:=clk
    attPin:=att
    cmdPin :=cmd  
    datPin:=ddat
    
    'INIT
    outa[attPin]~~ 'deselect PSX controller
    outa[cmdPin]~
    outa[clkPin]~~ 'release clock 
    dira[attPin]~~
    dira[cmdPin]~~
    dira[clkPin]~~
    dira[datPin]~
   
  
    uS    := clkfreq / 1_000_000
    uS2   := 2 * uS
  
    addressID := @ID
    addressThumbL := @ThumbL
    addressThumbR := @ThumbR
    addressJoyRX := @JoyRX
    addressJoyRY := @JoyRY
    addressJoyLX := @JoyLX
    addressJoyLY := @JoyLY
  
    speed := clkfreq / 1000
    if cog
      cogstop(cog~ - 1)   
    cog := cognew(@psx, @ID) + 1  
           
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
dat
              org 0
psx           mov temp, #1          'initialize pin mask
              shl temp, clkPin
              mov clkPin, temp

              mov temp, #1          
              shl temp, attPin
              mov attPin, temp

              mov temp, #1          
              shl temp, cmdPin
              mov cmdPin, temp

              mov temp, #1          
              shl temp, datPin
              mov datPin, temp       'clkPin, attPin,cmdPin, datPin are now masks             
              
loop          mov tempID, #0          'clear old data
              mov tempStatus, #0
              mov tempThumbR, #0
              mov tempThumbL, #0
              mov tempJoyRX, #0
              mov tempJoyRY, #0
              mov tempJoyLX, #0
              mov tempJoyLY, #0 

              mov attPin, #0 wz,nr   'set attn LOW to select controller             
              muxnz outa, attPin 

              mov psxOut, #start     'send 'start' command
              call #psxTxRx

              mov psxOut, #getDat    'send 'getDat' command, get ID
              call #psxTxRx
              mov tempID, psxIn

              mov psxOut, #0         'clear command out byte for rest of transmission

              call #psxTxRx          'get status
              mov tempStatus, psxIn

              call #psxTxRx          'get buttons
              mov tempThumbR, psxIn
              call #psxTxRx
              mov tempThumbL, psxIn
              call #psxTxRx

              mov tempJoyRX, psxIn   'get joysticks
              call #psxTxRx
              mov tempJoyRY, psxIn
              call #psxTxRx
              mov tempJoyLX, psxIn
              call #psxTxRx
              mov tempJoyLY, psxIn                       

              mov attPin, #0 wz,nr    'set attn HIGH to deselect controller             
              muxz outa, attPin 
              
put_data      wrlong tempID, addressID        'globalize datasets
              wrlong tempStatus, addressStatus
              wrlong tempThumbL, addressThumbL
              wrlong tempThumbR, addressThumbR
              wrlong tempJoyRX, addressJoyRX
              wrlong tempJoyRY, addressJoyRY
              wrlong tempJoyLX, addressJoyLX
              wrlong tempJoyLY, addressJoyLY

              
              mov time, cnt
              add time, speed
              waitcnt time, #0        'wait for next update period
              jmp #loop

'************ Subroutine psxTxRx ************
' takes parameter: psxOut
' returns: psxIn                           
psxTxRx       mov clkPin, #0 wz,nr  'use Z Flag for clk
              mov psxIn, #0         'clear byte
              mov reps, #8          'loop for 8 bits (1 byte)
              
txrxloop      muxz outa, clkPin     'clk HIGH

              test psxOut, #1 wc    'place bit from psxOut on cmdPin
              muxc outa, cmdPin
              shr psxOut, #1        'prep for next bit
                                    
              muxnz outa, clkPin    'clk LOW

              test datPin, ina wc   'read data bit
              rcl psxIn, #1         'store bit in psxIn

              djnz reps, #txrxloop
psxTxRx_ret   ret



clkPin        long 0      'pin masks
attPin        long 0
cmdPin        long 0
datPin        long 0
temp          long 0   

psxOut        long 0      'parameter/return for psxTxRx routine
psxIn         long 0

tempID        long 0      'temp data
tempStatus    long 0
tempThumbL    long 0
tempThumbR    long 0
tempJoyRX     long 0
tempJoyRY     long 0
tempJoyLX     long 0
tempJoyLY     long 0

uS            long 0      'helper stuff
uS2           long 0           
time          long 0
reps          long 0
speed         long 0            

addressID     long 0      'addresses of global data
addressStatus long 0
addressThumbL long 0
addressThumbR long 0
addressJoyRX  long 0
addressJoyRY  long 0
addressJoyLX  long 0
addressJoyLY  long 0 

