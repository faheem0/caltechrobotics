{
                                ********************************************
                                        H48C Tri-Axis Accelerometer    MODIFIED
                                ********************************************
                                      coded by Beau Schwabe (Parallax) 
                                ********************************************
                                MODIFIED to use SPIN only and not run in another cog
                                 takes 3400 clock ticks (1.7ms @ 80MHz) for each sample
                                 works!

         ┌──────────┐
  P2 ──│1 ‣‣••6│── +5V       P0 = CS
         │  ┌°───┐  │               P1 = DIO
  P1 ──│2 │ /\ │ 5│── P0        P2 = CLK
         │  └────┘  │
 VSS ──│3  4│── Zero-G  
         └──────────┘


G = ((axis-vRef)/4095)x(3.3/0.3663)

        or

G = (axis-vRef)x0.0022

        or

G = (axis-vRef)/ 455
                               
}
VAR
long    CS,DIO,CLK,H48C_vref,H48C_x,H48C_y,H48C_z



PUB start(CS_,DIO_,CLK_):okay
    CS  := CS_
    DIO := DIO_
    CLK := CLK_
  
PUB update(dataOut):data
    outa[CLK]:=0   'preset clock low
    dira[CLK]:=1
    outa[CS]:=0    'select chip
    dira[CS]:=1

    outa[DIO]:=0    'set data output low
    dira[DIO]:=1
    repeat 5
      outa[DIO]:= (dataOut & %10000) == %10000
      outa[CLK]:=1   'clock high
      outa[CLK]:=0   'clock low
      dataOut:=dataOut<<1 
    outa[DIO]:=0  


    data:=0
    dira[DIO]:=0  'set data input
    repeat 13
      outa[CLK]:=1   'clock high
      outa[CLK]:=0   'clock low
      if ina[DIO]'==1
        data:=data | %0001
      data:=data<<1
    'return (data>>1)
    data:=data>>1
     
    outa[CS]:=1    'deselect chip

                 '     ┌───── Start Bit              
                 '     │┌──── Single/Differential Bit
                 '     ││┌┳┳─ Channel Select         
                 '     
'Xselect       long    %11000    'DAC Control Code
'Yselect       long    %11001    'DAC Control Code
'Zselect       long    %11010    'DAC Control Code
'VoltRef       long    %11011    'DAC Control Code              
PUB vref
    'H48C_vref  :=update(%11011)
    return update(%11011) 'H48C_vref
PUB x
    'H48C_x := update(%11000)
    return update(%11000) - vref 'H48C_x - vref    
PUB y
    'H48C_y:=update(%11001)
    return update(%11001) - vref 'H48C_y - vref    
PUB z
    'H48C_z:=update(%11010)
    return update(%11010) - vref 'H48C_z - vref
