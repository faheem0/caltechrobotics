
'' encoderCustomASM.spin 
'1/1/2008
'version 1.0
'for monitoring quadrature encoder position on custom encoders!
'works! runs in own cog, currently @ 144,286Hz @ 80MHz
{{With "shl dT, #10" takes ~ 10716 clock cyles per loop   
  use 11000 for margin of error
  80_000_000/11000 = 7,273 pulses/second   =7,273Hz @ 80MHz
  7273 /24 = 303 revolutions/second = 18,180 rpm limit  @ 80MHz

  With "shl dT, #4" takes ~ 636 clock cyles per loop   
  use 700 for margin of error
  80_000_000/700 = 114,286 pulses/second   =114,286Hz @ 80MHz
  114,286 /24 = 4762 revolutions/second = 285,720 rpm limit  @ 80MHz

 How to use it:
  OBJ
    myEncoder: "encoderCustomASM"
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

              mov maskA, #0 wz,nr   'init dira registers
              muxnz dira, maskA        'INPUT attPin

              mov maskB, #0 wz,nr      'INPUT clkPin
              muxnz dira, maskB         
              
              mov dT, #1  
              shl dT, #4 'N=4, 2^N/80 = time delay in us, running at 80MHz
loop          mov time, cnt 'start timer to measure loop performance
              
              mov valA, #0                'clear to 0   
              mov valB, #0
              
             call #incA               'sample A 5 times
             call #incA
             call #incA
             call #incA
             call #incA
             
              shr valA, #2            'if valA>3, valA=1, else valA=0

             call #incB               'sample B 5 times
             call #incB
             call #incB
             call #incB
             call #incB
            
              shr valB, #2            'if valB>3, valB=1, else valB=0

              'now need to increment/decrement "tempPos" accordingly given oldValA/B and valA/B
              test oldValA, #1 wc
              test oldValB, #1 wz

if_c_and_z    call #oldAB_11
if_nc_and_z   call #oldAB_01
if_c_and_nz   call #oldAB_10
if_nc_and_nz  call #oldAB_00  
'             
              'get ready for next loop
              mov oldValA, valA
              mov oldValB, valB
             
put_data      wrlong tempPos, addressPos       'globalize datasets
              wrlong tempSlipcnt, addressSlipcnt
                             
timingstuff    mov time2, cnt                
               sub time2, time
            wrlong time2, addressDebug
               jmp #loop          
              

              
'****************** Subroutines  ********************
' takes parameter: <none>
' returns: <nothing>
' does: increments valA or valB
incA         call #pause
              mov temp, #0           
             test maskA, ina wc        'read ina register for A      take 5 samples of A
              rcl temp, #1            'store 'A' in temp
              add valA, temp

incA_ret      ret

incB          call #pause
               mov temp, #0
              test maskB, ina wc        'read ina register for B      take 5 samples of B
              rcl temp, #1            'store 'B' in temp
              add valB, temp

incB_ret      ret              

pause         mov delay,cnt
              add delay, dT
           waitcnt delay, #0

pause_ret      ret

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

oldValA     long 0      'A/B states
ValA        long 0
oldValB     long 0
ValB        long 0

temp        long 0

delay         long 0    'timing
dT            long 0     

tempPos     long 0      'temp data
tempSlipcnt long 0                   
   
time          long 0       'helper stuff
time2         long 0

addressPos     long 0        'addresses of global data
addressSlipcnt long 0
addressDebug   long 0