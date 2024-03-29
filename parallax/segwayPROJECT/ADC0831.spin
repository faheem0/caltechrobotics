''********************************
''*  ADC0831 Driver v1.0  *
''********************************
VAR

  long CS
  long DO
  long CLK


CON
    
  

PUB start(csPin, doPin, clkPin)
      
    CS:=csPin
    DO:=doPin
    CLK:=clkPin
    
    'INIT
    dira[CS]~~
    dira[DO]~ '10k resistor from 5V to 3.3V
    dira[CLK]~~
    
    outa[CS]~~ 'deselect 
    outa[CLK]~                                 
  
'n: num samples avg'd
PUB value(n) |i, sum, val
  sum~
  repeat n
    val~
    outa[CS]~ 'select
    outa[CLK]~~
    outa[CLK]~
    outa[CLK]~~
    outa[CLK]~
    repeat i from 6 to 0
      if(ina[DO])
        val|= (1<<i)
      outa[CLK]~~
      outa[CLK]~
    outa[CS]~~ 'deselect 
    sum+=val
    waitcnt(clkfreq/1000+cnt)
  return (sum / n)

   
PUB cm |raw, conv
  raw:=value(5)
  conv := lookup(raw:80,80,80,80,80,80,80,80,80,80, 80,80,80,80,80,74,70,65,59,54, 50,47,45,43,42,40,38,37,36,34, 33,32,31,30,29,28,27,27,26,26, 25,25,24,24,23,22,22,21,21,21, 20,20,19,19,18,18,17,17,16,16, 15,15,15,15,15,14,14,14,14,14, 13,13,13,13,13,13,12,12,12,12, 12,12,12,12,11,11,11,11,11,11,  10,10,10,9,9,9,9,8,8,8,8,8,8,8,8) 
                   
  result:=conv


                     