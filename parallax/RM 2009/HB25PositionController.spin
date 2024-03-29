''*******************************************
''*  Parallax 12V motor position controller *
''*  Author: Samuel Yang                    *
''*******************************************

CON
  QPOS = %00001_000
  QSPD = %00010_000
  CHFA = %00011_000
  TRVL = %00100_000
  CLRP = %00101_000
  SREV = %00110_000
  STXD = %00111_000
  SMAX = %01000_000
  SSRR = %01001_000
  'LEFT_MOTOR = %00000_001
  'RIGHT_MOTOR = %00000_010
  
  MAX_SPEED = 24
  MAX_ACCELLERATION = 10
  ARRIVAL_TOLERANCE = 10

VAR

  

OBJ
  motorUart: "FullDuplexSerial"                    


PUB start(iopin)
  motorUart.start(iopin,iopin, %1100, 19200)
  motorUart.tx(CLRP)
  motorUart.tx(CLRP)
  motorUart.tx(CLRP)
  motorUart.tx(SSRR)    'set max acceleration
  motorUart.tx(60) 
  
PUB getPosition(motor)| byteHigh, byteLow, position      
  if( motor < 1 or motor > 4)
    return 0
  motorUart.tx(QPOS+motor)
  byteHigh:=motorUart.rx
  byteLow:=motorUart.rx
  position:=256*byteHigh+byteLow
  if( position > 32767)
    position-=65536
  return position
  
PUB getVelocity(motor)| byteHigh, byteLow, velocity      
  if( motor < 1 or motor > 4)
    return 0
  motorUart.tx(QSPD+motor)
  byteHigh:=motorUart.rx
  byteLow:=motorUart.rx
  velocity:=256*byteHigh+byteLow
  if( velocity > 32767)
    velocity-=65536
  return velocity

  
PUB setPosition(motor, position)| byteHigh, byteLow, velocity      
  if( motor < 1 or motor > 4)
    return 0
  if ( position >32767 or position < -32768)
    return 0 'error!
  if( position < 0 )
    position+=65536
  motorUart.tx(TRVL+motor)
  motorUart.tx( position>> 8)
  motorUart.tx($00FF & position)
  return 1 'successful

PUB stop(motor)| timeConstant
  timeConstant := 1      
  if( motor < 1 or motor > 4)
    return 0
  setPosition(motor, getPosition(motor)+timeConstant*getVelocity(motor)  )
  return 1 'successful  
PUB clearAll(motor)
  if( motor < 1 or motor > 4)
    return 0
  motorUart.tx(CLRP+motor)       '3 times for 'soft-reset', see user manual
  motorUart.tx(CLRP+motor)
  motorUart.tx(CLRP+motor)

PUB reverseOrientation(motor)
  if( motor < 1 or motor > 4)
    return 0
  motorUart.tx(SREV+motor)

PUB setMaxSpeed(motor, speed)
  if( motor < 1 or motor > 4 or speed < 0)
    return 0
  motorUart.tx(SMAX+motor)
  motorUart.tx(speed>>8)
  motorUart.tx($00FF & speed)