
VAR


CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000


OBJ

  
  gps  : "GPS_IO_mini"
  term:   "PC_Interface"  

pub main | gmt
 gps.start
 repeat
  term.str((string("Latitude ")))
  term.str(gps.latitude)
  term.out($0D)
  term.str((string("Longitude ")))
  term.str(gps.longitude)
  term.out($0D)
  term.str((string("GPS Altitude ")))
  term.str(gps.GPSaltitude)
  term.out($0D)
  term.str((string("Speed ")))
  term.str(gps.speed)
  term.out($0D)
  term.str((string("Satellites ")))
  term.str(gps.satellites)
  term.out($0D)
  term.str((string("Time GMT ")))
  term.str(gps.time)
  term.out($0D)
  term.str((string("Date ")))
  term.str(gps.date)
  term.out($0D)
  term.str((string("Heading ")))
  term.str(gps.heading)
  term.str((string(" ")))
  term.str(gps.N_S)
  term.str(gps.e_w)    
  term.out($0D)
  waitcnt(1_000_000_0 + cnt)