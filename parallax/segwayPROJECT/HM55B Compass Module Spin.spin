{SPIN VERSION,untested
                                ********************************************
                                         HM55B Compass Module      V1.0
                                ********************************************
                                      coded by Beau Schwabe (Parallax) 
                                ********************************************

         ┌────┬┬────┐
  P2 ──│1  6│── +3.3V     P0 = Enable
         │  ├┴──┴┤  │               P1 = Clock
  P2 ──│2 │ /\ │ 5│── P0        P2 = Data
         │  │/  \│  │
 VSS ──│3 └────┘ 4│── P1
         └──────────┘
                               
}
CON
  Reset         =    %0000
  Measure       =    %1000
  Report        =    %1100

  DataMask      =    %00000000_00000000_00000111_11111111

TestMask      =    %00000000_00000000_00000010_00000000
NegMask       =    %11111111_11111111_11111100_00000000
VAR
long    cog,Enable,Clock,Data,HM55B_x,HM55B_y,HM55B_theta

PUB stop
    'does nothing, just here for compatibility

PUB start(EnablePin,ClockPin,DataPin):okay
    Enable := EnablePin
    Clock := ClockPin   
    Data := DataPin          

PUB x
    runCompass
    return HM55B_x 

PUB y
    runCompass
    return HM55B_y

PUB theta
    'runCompass
    return 1'HM55B_theta  not implemented yet
PUB runCompass
    HM55B_x:=0
    HM55B_y:=0
    HM55B_theta:=0
    outa[Enable]:=1   'Pre-Set Enable pin HIGH
    dira[Enable]:=1   'Set Enable pin as an OUTPUT
    ClockTheEnable
    SHIFTOUT(Reset,4)
    ClockTheEnable
    SHIFTOUT(Measure,4)
    checkStatus     'wait until status is ready
    'mainCompassStuff
    'do cartesian to polar conversion HERE
PUB checkStatus
    ClockTheEnable
    SHIFTOUT(Report,4)                    
    if ((Report-(SHIFTIN(4) & $0F)) <>0 )
      'dira[7]:=1
      'outa[7]:=1          'gets stuck here???
      checkStatus
PUB mainCompassStuff
    HM55B_x:=SHIFTIN(11)     'Read Compass x value 
    HM55B_y:=SHIFTIN(11)     'Read Compass y value 
    ClockTheEnable
    if (HM55B_x & TestMask <> 0)
      HM55B_x|=NegMask
    if (HM55B_y & TestMask <> 0)
      HM55B_y|=NegMask
    HM55B_y*= -1
PUB ClockTheEnable
    outa[Enable]:=1      'enable high
    outa[Enable]:=0      'enable low
PUB Clk
    outa[Clock]:=1
    outa[Clock]:=0
PUB SHIFTOUT(outByte,numBits)  |t5
    outa[Data]:=0
    dira[Data]:=1
    outa[Clock]:=0
    dira[Clock]:=1

    t5:=1
    t5<<=numBits-1
    repeat until numBits==0
      
      if(t5 & outByte <> 0)
        outa[Data]:=1
      else
        outa[Data]:=0
      outByte>>=1
      Clk
      numBits--
    outa[Data]:=0
     

PUB SHIFTIN(numBits)
    dira[Data]:=0
    outa[Clock]:=0
    dira[Clock]:=1
    repeat until numBits==0
      'stuff
      Clk
      result<<=1
      if(ina[Data])
        result++
      numBits--     
{{DAT          assembly code still needed to translate
HM55B         org               
   

 
              mov       cx,                     x_
              mov       cy,                     y_
              call      #cordic
              shr       ca,                     #19
              mov       Theta_,                 ca

                              

'------------------------------------------------------------------------------------------------------------------------------
' Perform CORDIC cartesian-to-polar conversion

cordic        abs       cx,cx           wc 
        if_c  neg       cy,cy             
              mov       ca,#0             
              rcr       ca,#1

              movs      :lookup,#table
              mov       t1,#0
              mov       t2,#20

:loop         mov       dx,cy           wc
              sar       dx,t1
              mov       dy,cx
              sar       dy,t1
              sumc      cx,dx
              sumnc     cy,dy
:lookup       sumc      ca,table

              add       :lookup,#1
              add       t1,#1
              djnz      t2,#:loop
cordic_ret    ret

table         long    $20000000
              long    $12E4051E
              long    $09FB385B
              long    $051111D4
              long    $028B0D43
              long    $0145D7E1
              long    $00A2F61E
              long    $00517C55
              long    $0028BE53
              long    $00145F2F
              long    $000A2F98
              long    $000517CC
              long    $00028BE6
              long    $000145F3
              long    $0000A2FA
              long    $0000517D
              long    $000028BE
              long    $0000145F
              long    $00000A30
              long    $00000518    }}
'------------------------------------------------------------------------------------------------------------------------------
