
'' PS2 Controller Driver v1.2d  
'b: does not freeze anymore, but doesn't work
'c: LSB!!     works with wired, still not wireless...
'd: trying to get wireless, config routines added
obj


var
        long ID, Status,ThumbL, ThumbR, JoyRX, JoyRY, JoyLX, JoyLY   
        long cog
con
    startByte  = %00000001  '0x01
    getDat = %01000010  '0x42
    
pub start(ddat, cmd, att, clk)  

    clkPin:=clk
    attPin:=att
    cmdPin :=cmd  
    datPin:=ddat
    
    'INIT
{{    outa[attPin]~~ 'deselect PSX controller
    outa[cmdPin]~
    outa[clkPin]~~ 'release clock 
    dira[attPin]~~
    dira[cmdPin]~~
    dira[clkPin]~~
    dira[datPin]~                }}
   
  
    uS    := clkfreq / 1_000_000
    uS2   := 2 * uS
    uS10  := 10*uS
    uS20  := 20*uS
    ms    := clkfreq/1000
    speed := clkfreq / 1000
  
    addressID := @ID
    addressStatus := @ID+4
    addressThumbL := @ID+8
    addressThumbR := @ID+12
    addressJoyRX := @ID+16
    addressJoyRY := @ID+20
    addressJoyLX := @ID+24
    addressJoyLY := @ID+28
    
    if cog
      cogstop(cog~ - 1)   
    cog := cognew(@psx, @ID) + 1  
           

PUB getID
  result:=ID
PUB getStatus
  result:=Status  
PUB getThumbL
  result:=ThumbL
PUB getThumbR
  result:=ThumbR
PUB getJoyRX
  result:=JoyRX
PUB getJoyRY
  result:=JoyRY
PUB getJoyLX
  result:=JoyLX
PUB getJoyLY
  result:=JoyLY

dat
              org 0
psx           mov temp, #1           'initialize pin masks
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

              mov attPin, #0 wz,nr   'init outa registers
              muxz outa, attPin         'HIGH attPin

              mov clkPin, #0 wz,nr      'HIGH clkPin
              muxz outa, clkPin         

              mov cmdPin, #0 wz, nr      'HIGH cmdPin
              muxz outa, cmdPin  

              mov attPin, #0 wz,nr   'init dira registers
              muxz dira, attPin         'OUTPUT attPin

              mov clkPin, #0 wz,nr      'OUTPUT clkPin
              muxz dira, clkPin         

              mov cmdPin, #0 wz, nr      'OUTPUT cmdPin
              muxz dira, cmdPin

              mov datPin, #0 wz, nr      'INPUT datPin
              muxnz dira, datPin

              'jmp #loop
              
EnterConfig   mov attPin, #0 wz,nr   'set attn LOW to select controller             
              muxnz outa, attPin            
              
              mov time, cnt           'delay
              add time, us20
              add time, us20 
              waitcnt time, #0

              mov psxOut, #$01     
              call #psxTxRx
              mov psxOut, #$43     
              call #psxTxRx
              mov psxOut, #$00     
              call #psxTxRx
              mov psxOut, #$01     
              call #psxTxRx        
              mov psxOut, #$00     
              call #psxTxRx                 

              mov attPin, #0 wz,nr   'set attn HIGH to deselect controller             
              muxz outa, attPin

              mov time, cnt           'delay
              add time, ms
              waitcnt time, #0

SetAnalog     mov attPin, #0 wz,nr   'set attn LOW to select controller             
              muxnz outa, attPin            
              
              mov time, cnt           'delay
              add time, us20
              add time, us20 
              waitcnt time, #0

              mov psxOut, #$01     
              call #psxTxRx
              mov psxOut, #$4F     
              call #psxTxRx
              mov psxOut, #$00     
              call #psxTxRx
              mov psxOut, #$FF     
              call #psxTxRx        
              mov psxOut, #$FF     
              call #psxTxRx
              mov psxOut, #$03     
              call #psxTxRx                

              mov attPin, #0 wz,nr   'set attn HIGH to deselect controller             
              muxz outa, attPin

              mov time, cnt           'delay
              add time, ms
              waitcnt time, #0              
              
SetDS2Native  mov attPin, #0 wz,nr   'set attn LOW to select controller             
              muxnz outa, attPin            
              
              mov time, cnt           'delay
              add time, us20
              add time, us20 
              waitcnt time, #0

              mov psxOut, #$01     
              call #psxTxRx
              mov psxOut, #$44     
              call #psxTxRx
              mov psxOut, #$00     
              call #psxTxRx
              mov psxOut, #$01     
              call #psxTxRx        
              mov psxOut, #$03     
              call #psxTxRx                    

              mov attPin, #0 wz,nr   'set attn HIGH to deselect controller             
              muxz outa, attPin

              mov time, cnt           'delay
              add time, ms
              waitcnt time, #0

EnterVib      mov attPin, #0 wz,nr   'set attn LOW to select controller             
              muxnz outa, attPin            
              
              mov time, cnt           'delay
              add time, us20
              add time, us20 
              waitcnt time, #0

              mov psxOut, #$01     
              call #psxTxRx
              mov psxOut, #$4D     
              call #psxTxRx
              mov psxOut, #$00     
              call #psxTxRx
              mov psxOut, #$00     
              call #psxTxRx        
              mov psxOut, #$01     
              call #psxTxRx
              mov psxOut, #$FF     
              call #psxTxRx
              mov psxOut, #$FF     
              call #psxTxRx
              mov psxOut, #$FF     
              call #psxTxRx
              mov psxOut, #$FF     
              call #psxTxRx
              mov psxOut, #$FF     
              call #psxTxRx                   

              mov attPin, #0 wz,nr   'set attn HIGH to deselect controller             
              muxz outa, attPin

              mov time, cnt           'delay
              add time, ms
              waitcnt time, #0                           

ExitDS2Native mov attPin, #0 wz,nr   'set attn LOW to select controller             
              muxnz outa, attPin            
              
              mov time, cnt           'delay
              add time, us20
              add time, us20 
              waitcnt time, #0

              mov psxOut, #$01     
              call #psxTxRx
              mov psxOut, #$43     
              call #psxTxRx
              mov psxOut, #$00     
              call #psxTxRx
              mov psxOut, #$00     
              call #psxTxRx        
              mov psxOut, #$5A    
              call #psxTxRx
              mov psxOut, #$5A    
              call #psxTxRx
              mov psxOut, #$5A    
              call #psxTxRx
              mov psxOut, #$5A    
              call #psxTxRx
              mov psxOut, #$5A    
              call #psxTxRx                     

              mov attPin, #0 wz,nr   'set attn HIGH to deselect controller             
              muxz outa, attPin

              mov time, cnt           'delay
              add time, ms
              waitcnt time, #0
              
ExitConfig    mov attPin, #0 wz,nr   'set attn LOW to select controller             
              muxnz outa, attPin            
              
              mov time, cnt           'delay
              add time, us20
              add time, us20 
              waitcnt time, #0

              mov psxOut, #$01     
              call #psxTxRx
              mov psxOut, #$43     
              call #psxTxRx
              mov psxOut, #$00     
              call #psxTxRx
              mov psxOut, #$00     
              call #psxTxRx
              mov psxOut, #$00     
              call #psxTxRx                     

              mov attPin, #0 wz,nr   'set attn HIGH to deselect controller             
              muxz outa, attPin

              mov time, cnt           'delay
              add time, ms
              waitcnt time, #0                    
                            
loop          mov attPin, #0 wz,nr   'set attn LOW to select controller             
              muxnz outa, attPin

              mov tempID, #0         'clear old data
              mov tempStatus, #0
              mov tempThumbL, #0
              mov tempThumbR, #0      
              mov tempJoyRX, #0
              mov tempJoyRY, #0
              mov tempJoyLX, #0
              mov tempJoyLY, #0                   

              mov time, cnt           'delay
              add time, us20 
              waitcnt time, #0

              mov psxOut, #$01'#startByte     'send 'start' command
              call #psxTxRx

              'mov time, cnt           'delay
              'add time, us20 
              'waitcnt time, #0
              
              mov psxOut, #getDat    'send 'getDat' command, get ID
              call #psxTxRx
              mov tempID, psxIn

              mov psxOut, #0         'clear command out byte for rest of transmission

              call #psxTxRx          'get status
              mov tempStatus, psxIn

              'mov psxOut, #$01 'ADDED 4 vib
              call #psxTxRx          'get buttons
              mov tempThumbL, psxIn
              call #psxTxRx
              mov tempThumbR, psxIn
              call #psxTxRx

              mov tempJoyRX, psxIn   'get joysticks
              call #psxTxRx
              mov tempJoyRY, psxIn
              call #psxTxRx
              mov tempJoyLX, psxIn
              call #psxTxRx
              mov tempJoyLY, psxIn                       

              mov attPin, #0 wz,nr   'set attn HIGH to deselect controller             
              muxz outa, attPin 
                
put_data      mov temp, addressID     'globalize datasets   
              wrlong tempID, temp                      
              mov temp, addressStatus                 
              wrlong tempStatus,temp                 
              mov temp, addressThumbL
              wrlong tempThumbL,temp 
              mov temp, addressThumbR
              wrlong tempThumbR,temp                 
              mov temp, addressJoyRX
              wrlong tempJoyRX,temp 
              mov temp, addressJoyRY
              wrlong tempJoyRY,temp 
              mov temp, addressJoyLX
              wrlong tempJoyLX,temp 
              mov temp, addressJoyLY
              wrlong tempJoyLY,temp 
                                          
              
              mov time, cnt
              add time, speed
              waitcnt time, #0       'wait for next update period
              jmp #loop

'****************** Subroutine psxTxRx ********************
' takes parameter: psxOut
' returns: psxIn                           
psxTxRx
              mov clkPin, #0 wz,nr  'use Z Flag for clkmov psxIn, #0         'clear byte
              mov reps, #8          'loop for 8 bits (1 byte)

              mov time, cnt         'delay  14us
              add time, uS10
              add time, uS2
              add time, uS2
              waitcnt time, #0
              add time, uS
              
txrxloop      test psxOut, #1 wc    'place bit from psxOut on cmdPin
              muxc outa, cmdPin                 

              waitcnt time, #0       'delay 1us                
              muxnz outa, clkPin     'clk LOW
              
              mov time, cnt
              add time, uS
              waitcnt time, #0       'delay 1us
              add time, uS
              
                               'AA 

              shr psxOut, #1         'prep for next bit
              waitcnt time, #0       'delay 1us

              muxz outa, clkPin      'clk HIGH

              test datPin, ina wc    'read data bit        AA
              rcr psxIn, #1          'store bit in psxIn
              
              mov time, cnt
              add time, uS
              waitcnt time, #0       'delay 1us
              add time, uS
              
              djnz reps, #txrxloop
              shr psxIn, #24
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
uS10          long 0
uS20          long 0
ms            long 0   
time          long 0
reps          long 0
speed         long 0            

addressID    long 0         'addresses of global data
addressStatus long 0
addressThumbL long 0
addressThumbR long 0
addressJoyRX  long 0
addressJoyRY  long 0
addressJoyLX  long 0
addressJoyLY  long 0 