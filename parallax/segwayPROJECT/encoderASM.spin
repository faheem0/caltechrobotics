
'' encoderASM.spin 
'11/22/2007
'version 1.0
'for monitoring quadrature encoder position
'works!
{{takes ~ 180 clock cyles per loop
  use 200 for margin of error
  80_000_000/200 = 400_000 pulses/second
  400_000 /400 = 1000 revolutions/second = 60_000rpm limit

 How to use it:
  OBJ
    myEncoder: "encoderASM"
  PUB main |tempVar
    myEncoder.start(<pinA>, <pinB>)

    tempVar:=myEncoder.getPos       'gets position, negative if in reverse
    tempVar:=myEncoder.getSlipCount  'gets accumulated error  

                                          }}
VAR
    long pos, slipcnt,debug       'global variables, order of these is important!
    long cog

 
PUB start(pA, pB)   'pA and pB are the pins which the encoder is connected to   

    pinA:=pA
    pinB:=pB
              
    addressPos := @pos               'have pointers to addresses of memory locations of pos, etc
    addressSlipcnt := @pos+4                 '+4 because 1 long (32 bits) = 4 bytes (8 x4 bits)
    addressDebug := @pos + 8
           
    if cog
      cogstop(cog~ - 1)   
    cog := cognew(@init, @pos) + 1       'starta  new cog running at 'init' with memory block at 'pos'
           
PUB getPos             'accessors for accessing global data
  result:=pos
PUB getSlipCount
  result:=slipcnt
PUB getDebug
 result:=debug

dat   'start of assembly language portion
              org 0        'always needed to beign ASM section
init          mov temp, #1           'initialize pin masks
              shl temp, pinA
              mov maskA, temp                                  
              
              mov temp, #1          
              shl temp, pinB
              mov maskB, temp

              mov maskAB, #0
              or maskAB, maskA
              or maskAB, maskB      

              mov maskA, #0 wz,nr   'init dira registers
              muxnz dira, maskA        'INPUT attPin

              mov maskB, #0 wz,nr      'INPUT clkPin
              muxnz dira, maskB         

preloop
              mov valA, #0         'read ina register for A, store in valA and temp
              test maskA, ina wc
              rcl valA, #1
              mov temp, valA
              shl temp, pinA
              
                                   'read ina register for B, store in valB and temp2
              mov valB, #0               'clear to 0
              test maskB, ina wc         'set c flag
              rcl valB, #1               'set valB to c-flag
              mov temp2, valB            'copy B into temp2
              shl temp2, pinB            'shift temp2 over pinB bits

              mov newAB, temp      'combine (temp OR temp2) to get newAB 
              or newAB, temp2       'newAB = %000A000B00

              mov oldAB, newAB
              
             
loop     waitpne oldAB, maskAB 'wait for position change from old position

              mov time, cnt
              
              mov valA, #0                'clear to 0   
              mov valB, #0
              mov newAB, #0             
                       
             test maskA, ina wc        'read ina register for A, store in valA and newAB
              rcl valA, #1            'store 'A' in valA
              mov newAB, valA          'copy to newAB
              shl newAB, pinA          'shift newAB left pinA bits giving: newAB = %00..A....00
              
                                   'read ina register for B, store in valB and temp2
                            
             test maskB, ina wc         'set c flag
              rcl valB, #1               'set valB to c-flag                 
              mov temp, valB            'copy B into temp
              shl temp, pinB            'shift temp over pinB bits giving: temp = %00....B..00
              or newAB, temp            'combine newAB with temp giving: newAB = %00..A..B..00
             
              'now need to increment/decrement "tempPos" accordingly given oldValA/B and valA/B
              test oldValA, #1 wc
              test oldValB, #1 wz

if_c_and_z    call #oldAB_11
if_nc_and_z   call #oldAB_01
if_c_and_nz   call #oldAB_10
if_nc_and_nz  call #oldAB_00  
'             'wrlong    newAB     ,addressDebug     'DEBUG   

              'get ready for next loop
              mov oldAB, newAB        'update old values
              mov oldValA, valA
              mov oldValB, valB

              'jmp#loop 'ADDED
              
put_data      'mov temp, addressPos     'globalize datasets   
              wrlong tempPos, addressPos
              wrlong tempSlipcnt, addressSlipcnt

              'wrlong tempPos, temp                      
              'mov temp, addressSlipcnt               
              'wrlong tempSlipcnt,temp                 

timingstuff    mov time2, cnt                '~180 clock cycles
               sub time2, time
            wrlong time2, addressDebug
                        
              jmp #loop

              
'****************** Subroutines  ********************
' takes parameter: <none>
' returns: <nothing>
' does: increments pos or slipcnt
' A | B
' 0   1
' 1   1        going down = pos++
' 1   0        if skips one, slipcnt++ 
' 0   0

                     
oldAB_11      test valA, #1 wc
              test valB,#1 wz
if_nc_and_z   subs tempPos, #1     
if_c_and_nz   adds tempPos, #1      
if_nc_and_nz  adds tempSlipCnt, #1    
                                                       
oldAB_11_ret   ret

oldAB_10      test valA, #1 wc
              test valB,#1 wz
if_c_and_z    subs tempPos, #1     
if_nc_and_z   adds tempSlipCnt, #1    
if_nc_and_nz  adds tempPos, #1      
                                                       
oldAB_10_ret   ret

oldAB_00      test valA, #1 wc
              test valB,#1 wz
if_c_and_z    adds tempSlipCnt, #1    
if_nc_and_z   adds tempPos, #1      
if_c_and_nz   subs tempPos, #1     
                                                       
oldAB_00_ret   ret

oldAB_01      test valA, #1 wc
              test valB,#1 wz
if_c_and_z    adds tempPos, #1       
if_c_and_nz   adds tempSlipCnt, #1    
if_nc_and_nz  subs tempPos, #1     
                                                       
oldAB_01_ret   ret

'******* variables
pinA        long 0      'pin masks
pinB        long 0
maskA       long 0
maskB       long 0
maskAB      long 0

oldAB       long 0       'AB values
newAB       long 0
oldValA     long 0
ValA        long 0
oldValB     long 0
ValB        long 0

temp        long 0        'temp AB values
temp2       long 0    


tempPos     long 0      'temp data
tempSlipcnt long 0

   
time          long 0       'helper stuff
time2         long 0
delay         long 0
reps          long 0

addressPos     long 0        'addresses of global data
addressSlipcnt long 0
addressDebug   long 0