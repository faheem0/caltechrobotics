{{
  This program starts a cog to read the heading from a PNI Corp.
  V2XE compass module using a Parallax Propeller chip. Note that
  Martin Hebol's BS2 Functions are required to use this program,
  as well as "FullDuplexSerial" and "SPI engine", so make sure
  they are in the same directory as this file.
  
  Jonathan Peakall, 2007.
  Contact jpeakall@madlabs.info  
}}

CON
  ' Make sure to change to suit
  '_clkmode = xtal1 + pll8x  
 ' _xinfreq = 10_000_000

    ' Compass Pins
    sclk        = 14
    miso        = 13
    mosi        = 12
    ssnot       = 11
    sync        = 10
    pwr         = 4            'unused?
    ' Compass Cons
    datComps    = $3
    getData     = $4      
    flag        = $AA
    datComp     = $3
    vHead       = $5
    term        = $0
    
    'Used for SHIFTIN routines
    #0,MSBPRE,LSBPRE,MSBPOST,LSBPOST 
    #4,LSBFIRST,MSBFIRST

VAR
  long compassStack[50], heading, tempHeading, truncHeading , origHeading
  byte flagIn, frameIn, countIn, termIn
  byte headingVal[4], headingIn, exponent 
 
OBJ
    BS2         : "BS2_Functions"
    btSerial    : "FullDuplexSerial"
    spi         : "SPI Engine"
    fMath       : "FloatMath"
    
pub init

BS2.Start(22,23) '(31,30) ' Start BS2 functions
cognew(compass_cog, @compassStack) ' Start compass cog

{{
  Once the cog is started, the variable heading will contain
  the current compass heading in degrees. Note that to perform
  any other compass function, such as calibration or changing
  configuration require stopping the compass cog first. Failure
  to do so will cause the program to hang.
}}
PUB getHeading
   return heading
PUB gettruncHeading
   return truncHeading
PUB getOrigHeading
   return origHeading
PUB compass_cog
  ' Set up pins
  dira[ssnot] := 1   ' Make sure that SPI is closed
  outa[ssnot] := 0    ' Init SPI 
  outa[sync] := 0     ' Send synch low
  BS2.Pulsout(sync,2) ' Send a 2uS pulse
  ' Set the compass up for reading the heading
  spi.shiftout(mosi,sclk,msbfirst,8,flag)
  spi.shiftout(mosi,sclk,msbfirst,8,datComps)
  spi.shiftout(mosi,sclk,msbfirst,8,$1)
  spi.shiftout(mosi,sclk,msbfirst,8,vHead)
  spi.shiftout(mosi,sclk,msbfirst,8,term)
  bs2.pause(1)
  outa[ssnot] := 1     ' Terminate SPI
  ' Now that the compass is initialized
  ' start the loop to read.
  repeat
    flagin := 99 ' Make sure that flag <> $AA
    tempHeading := 999 ' Put out of range number
    bytefill(@headingVal,0,4)' Flush data buffer
    outa[ssnot] := 0    ' Start SPI
    outa[sync] := 0     ' Send synch low
    BS2.Pulsout(sync,2) ' Sync pulse
    ' Request heading
    spi.shiftout(mosi,sclk,msbfirst,8,flag)
    spi.shiftout(mosi,sclk,msbfirst,8,getData)
    spi.shiftout(mosi,sclk,msbfirst,8,term)
    repeat while flagIn <> $AA ' Wait until we receive the flag byte
      flagIn := SPI.shiftin(miso,sclk,msbpre,8)
    frameIn := SPI.shiftin(miso,sclk,msbpre,8) 
    countIn := SPI.shiftin(miso,sclk,msbpre,8)
    HeadingIn := SPI.shiftin(miso,sclk,msbpre,8)
    HeadingVal[0] := SPI.shiftin(miso,sclk,msbpre,8)
    HeadingVal[1] := SPI.shiftin(miso,sclk,msbpre,8)
    HeadingVal[2] := SPI.shiftin(miso,sclk,msbpre,8)
    HeadingVal[3] := SPI.shiftin(miso,sclk,msbpre,8)
    outa[ssnot] :=1 ' Terminate SPI
    ' Take the float heading and convert to integer. Note that
    ' a temp variable is used for calculations. This is to make sure
    ' that the variable contains valid data when read by other cogs.
    truncHeading:=fMath.FTrunc ((HeadingVal[0]<<24)+(HeadingVal[1]<<16)+(HeadingVal[3]<<8)+(HeadingVal[4])) 
    heading := fMath.FRound( (HeadingVal[0]<<24)+(HeadingVal[1]<<16)+(HeadingVal[3]<<8)+(HeadingVal[4]) )
    
    headingVal[0] := headingVal[0] * 2    'there is a bug with this float to integer conversion
    if headingVal[1] => 128                        'that causes the value to jump around the following
      headingVal[0] := headingVal[0] + 1           'values: 143, 191, 271, 319, 335
    exponent := headingVal[0]
    tempheading := 1
    if exponent =< 126
      tempheading := 0
      exponent := 127
    repeat until exponent == 127
      tempheading := tempheading * 2
      headingVal[1] := headingVal[1] * 2
      if headingVal[1] => 128
        tempheading := tempheading + 1
      if headingVal[2] => 128
        headingVal[1] := headingVal[1] + 1
      headingVal[2] := headingVal[2] * 2
      exponent := exponent - 1
   ' Here we take the temp variable and
   ' and put it into heading. Heading now
   ' contains the compass heading.   
    origHeading := tempHeading              