
'' ps2ControllerListenerASM.spin 
'9/10/2007
'for monitoring ps2 controller signals
'works!
obj


var
        long ID, Status,ThumbL, ThumbR, JoyRX, JoyRY, JoyLX, JoyLY,startByte,count   
        long cog

    
pub start(ddat, cmd, att, clk)  

    clkPin:=clk
    attPin:=att
    cmdPin :=cmd  
    datPin:=ddat
          
    addressID := @ID
    addressStatus := @ID+4
    addressThumbL := @ID+8
    addressThumbR := @ID+12
    addressJoyRX := @ID+16
    addressJoyRY := @ID+20
    addressJoyLX := @ID+24
    addressJoyLY := @ID+28
    addressStartByte := @ID+32
    addressCount := @ID +36

    delay :=clkfreq/2_000_000            'half us

    
    if cog
      cogstop(cog~ - 1)   
    cog := cognew(@init, @ID) + 1  
           
PUB getStart
  result:=startByte
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
PUB getCount
  result:=count

dat
              org 0
init          mov temp, #1           'initialize pin masks
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

              mov attPin, #0 wz,nr   'init dira registers
              muxnz dira, attPin        'INPUT attPin

              mov clkPin, #0 wz,nr      'INPUT clkPin
              muxnz dira, clkPin         

              mov cmdPin, #0 wz, nr     'INPUT cmdPin
              muxnz dira, cmdPin

              mov datPin, #0 wz, nr     'INPUT datPin
              muxnz dira, datPin                  
                            
             ' waitpne 0,attPin        'wait attPin HIGH
              waitpeq attPin, attPin
               
startMeas     mov tempStartByte, #0   'clear old data 
              mov tempID, #0         
              mov tempStatus, #0
              mov tempThumbL, #0
              mov tempThumbR, #0      
              mov tempJoyRX, #0
              mov tempJoyRY, #0
              mov tempJoyLX, #0
              mov tempJoyLY, #0                   

              waitpeq attPin, attPin         'wait attPin HIGH
              waitpne attPin, attPin 'wait for att to go LOW             
                                     
              call #psxTxRx          'get Start byte
              mov tempStartByte, psxIn
                            
              call #psxTxRx          'get ID byte
              mov tempID, psxIn                      

              call #psxTxRx          'get status byte
              mov tempStatus, psxIn
                            
              call #psxTxRx          'get button data bytes
              mov tempThumbL, psxIn
              call #psxTxRx
              mov tempThumbR, psxIn
              call #psxTxRx

              mov tempJoyRX, psxIn   'get joystick data bytes
              call #psxTxRx
              mov tempJoyRY, psxIn
              call #psxTxRx
              mov tempJoyLX, psxIn
              call #psxTxRx
              mov tempJoyLY, psxIn                       

          {{    mov temp, tempStartByte 'go back if equal to 0
              shr temp, #8 'isolate cmd byte
              'or temp, #1 'select bit 1
              tjz temp, #startMeas      }}
                
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
              mov temp, addressStartByte
              wrLong tempStartByte, temp       

              add tempCount, #1
              mov temp, addressCount
              wrLong tempCount, temp                    
              
              jmp #startMeas

'****************** Subroutine psxTxRx ********************
' takes parameter: <none>
' returns: psxIn                           
psxTxRx
              mov psxOut, #0
              mov psxIn, #0  
              mov reps, #8          'loop for 8 bits (1 byte)
                           
readtxrxloop  waitpne clkPin, clkPin 'wait for clk to go LOW                  

              {{mov time, cnt     'half us delay
              add time, delay
              waitcnt time, #0    }}
              
              test cmdPin, ina wc   'store CMD bits in psxOut
              rcr psxOut, #1              

              waitpeq clkPin, clkPin 'wait for clk to go HIGH    

              {{mov time, cnt     'half us delay
              add time, delay
              waitcnt time, #0    }}

              test datPin, ina wc   'store DAT bits in psxIn
              rcr psxIn, #1           
              
              
              djnz reps, #readtxrxloop
              shr psxOut, #16        'combine psxOut and psxIn into psxIn
              shr psxIn, #24
              or psxIn, psxOut       'psxIn: bits 0-7 = psxIn bits 8-15=psxOut
              
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
tempStartByte long 0
tempCount     long 0

   
time          long 0       'helper stuff
delay         long 0
reps          long 0

addressID    long 0        'addresses of global data
addressStatus long 0
addressThumbL long 0
addressThumbR long 0
addressJoyRX  long 0
addressJoyRY  long 0
addressJoyLX  long 0
addressJoyLY  long 0
addressStartByte long 0
addressCount  long 0