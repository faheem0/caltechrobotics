'' File: ddddfsf
'' For Caltech sdf1 larger ribbon cable, connects to MASTER MCU
''5/1/2008
{{history: 1.0 file copied from balancingBotPEKv4p7.spin, modified
                  Tested MCU-MCU protocol with working motor encoders.
                  Wrote encoder calibration helper method
                  Stilsf need to test all 4 motors at once.

Known issues: 

                   
   PIN   Purpose    Input  Output
    0    enc                 X
    1    enc                 X

    26     
    27     
    
  COG usage:
     0: main cog (transmits encoder values constantly)
     1: debuight front           
     7:       
    
                                                 }}
VAR

    long heartBeat  'for blinking the LED
    long stack[60]     
 
    long encoderLFFposition 
    long encoderLFBposition
    long encoderRFBposition
    long encoderRFFposition
          
    
CON
    _xinfreq = 5_000_000                     ' 5 MHz external crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crystal multiplied → 80 MHz

  


OBJ
    term:   "PC_Interface"
  
  
  
PUB main  |temp
    
    INITIALIZATION

    repeat
      term.dec(ina[4])
      pausems(200)
'inits pins/objects/etc       
PUB INITIALIZATION
    
    term.start(31,30)     'start terminal COG
    term.str(string("starting up"))
   
     
    
    term.out($0d)
    term.str(string("done"))
    pausems(1000)
         
    term.cls       

 
PUB pausems(ms)
  waitcnt(cnt+clkfreq/1000*ms)

                 