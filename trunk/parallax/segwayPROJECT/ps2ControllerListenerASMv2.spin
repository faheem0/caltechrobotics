
'' ps2ControllerListenerASMv2.spin 
'9/10/2007
'for monitoring ps2 controller signals
'v2: compact data (uses 32 bits), exits after 5th byte if attn goes high
obj


var
        long cmdOne, cmdTwo,cmdThree, datOne, datTwo, datThree, count   
        long cog

    
pub start(ddat, cmd, att, clk)  

    clkPin:=clk
    attPin:=att
    cmdPin :=cmd  
    datPin:=ddat
          
    addressCmdOne := @cmdOne
    addressCmdTwo := @cmdOne+4
    addressCmdThree := @cmdOne+8
    addressDatOne := @cmdOne+12
    addressDatTwo := @cmdOne+16
    addressDatThree := @cmdOne+20
    addressCount := @cmdOne +24

    delay :=clkfreq/2_000_000            'half us
    delay2 :=30*delay

    
    if cog
      cogstop(cog~ - 1)   
    cog := cognew(@init, @cmdOne) + 1  
           
PUB getCmdOne
  result:=cmdOne
PUB getCmdTwo
  result:=cmdTwo
PUB getCmdThree
  result:=cmdThree  
PUB getDatOne
  result:=datOne
PUB getDatTwo
  result:=datTwo
PUB getDatThree
  result:=datThree
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
               
startMeas     mov tempCmdOne, #0   'clear old data 
              mov tempCmdTwo, #0         
              mov tempCmdThree, #0
              mov tempDatOne, #0
              mov tempDatTwo, #0      
              mov tempDatThree, #0
                                

              waitpeq attPin, attPin         'wait attPin HIGH
              waitpne attPin, attPin 'wait for att to go LOW             
                                     
              call #psxTxRx          'get Start byte
              call #psxTxRx          'get ID byte
              call #psxTxRx          'get status byte
              call #psxTxRx          'get button data bytes
              mov tempCmdOne, psxCmd
              mov tempDatOne, psxDat
              mov psxCmd, #0
              mov psxDat, #0

              
              
              call #psxTxRx


             {{ mov time, cnt     '12 us delay
              add time, delay2
              waitcnt time, #0
              
              mov temp, #0
              test attPin, ina wc
              rcr temp,#1
              tjnz temp, #put_data   'if temp!=0 (attn is HIGH) skip to end    }}
              
              call #psxTxRx     
             {{ shr psxCmd, #16     'stop after 6th byte
              shr psxDat, #16

              mov tempCmdTwo, psxCmd
              mov tempDatTwo, psxDat  }}
              call #psxTxRx
              call #psxTxRx
              mov tempCmdTwo, psxCmd
              mov tempDatTwo, psxDat
              mov psxCmd, #0
              mov psxDat, #0
              
              call #psxTxRx
              mov tempCmdThree, psxCmd
              mov tempDatThree, psxDat
              mov psxCmd, #0
              mov psxDat, #0             
          {{    mov temp, tempStartByte 'go back if equal to 0
              shr temp, #8 'isolate cmd byte
              'or temp, #1 'select bit 1
              tjz temp, #startMeas      }}
                
put_data      mov temp, addressCmdOne     'globalize datasets   
              wrlong tempCmdOne, temp                      
              mov temp, addressCmdTwo                 
              wrlong tempCmdTwo,temp                 
              mov temp, addressCmdThree
              wrlong tempCmdThree,temp 
              mov temp, addressDatOne
              wrlong tempDatOne,temp                 
              mov temp, addressDatTwo
              wrlong tempDatTwo,temp 
              mov temp, addressDatThree
              wrlong tempDatTHree,temp 
                   

              add tempCount, #1
              mov temp, addressCount
              wrLong tempCount, temp                    
              
              jmp #startMeas

'****************** Subroutine psxTxRx ********************
' takes parameter: <none>
' returns: psxCmd and psxDat                           
psxTxRx       mov reps, #8          'loop for 8 bits (1 byte)
                           
readtxrxloop  waitpne clkPin, clkPin 'wait for clk to go LOW                  

              {{mov time, cnt     'half us delay
              add time, delay
              waitcnt time, #0 }}   
              
              test cmdPin, ina wc   'store CMD bits in psxOut
              rcr psxCmd, #1              

              waitpeq clkPin, clkPin 'wait for clk to go HIGH    

              {{mov time, cnt     'half us delay
              add time, delay
              waitcnt time, #0    }}

              test datPin, ina wc   'store DAT bits in psxIn
              rcr psxDat, #1           
              
              
              djnz reps, #readtxrxloop
              
psxTxRx_ret   ret



clkPin        long 0      'pin masks
attPin        long 0
cmdPin        long 0
datPin        long 0
temp          long 0   

psxCmd        long 0      'parameter/return for psxTxRx routine
psxDat         long 0

tempCmdOne        long 0      'temp data
tempCmdTwo    long 0
tempCmdThree    long 0
tempDatOne    long 0
tempDatTwo     long 0
tempDatThree     long 0
tempCount     long 0

   
time          long 0       'helper stuff
delay         long 0
delay2        long 0
reps          long 0

addressID    long 0        
addressCmdOne long 0          'addresses of global data       
addressCmdTwo long 0 
addressCmdThree long 0 
addressDatOne long 0 
addressDatTwo long 0 
addressDatThree long 0 
addressCount long 0 