{
*******************************************************************
 Control up to 32-Servos on any pin assignment
 Version1.2                                             05-30-2006 
*******************************************************************
 Coded by Beau Schwabe (Parallax).                                            
*******************************************************************

 Revision History:
  Version 1.0   -               Created a Working concept to control 32 servos
                                
  Version 1.1   -               Fixed a "glitch" due to 'cnt' roll over

  Version 1.2   -               Better "glitch" detection routine implemented
                                Fixed improper allocation of reserved variable space
      *************MODIFIED FOR LARGER RANGE


Theory of Operation:

Each servo requires a pulse that varies from 1mS to 2mS with a period of 20mS.
To prevent a current surge nightmare, I have broken the 20mS period into four
groups or Zones of 8 servos each with a period of 5mS. What this does, is to
ensure that at any given moment in time, a maximum of only 8 servos are receiving
a pulse.

 Zone1  Zone2  Zone3  Zone4          In Zone1, servo pins  0- 7 are active
         In Zone2, servo pins  8-15 are active
│─5mS│─5mS│─5mS│─5mS│        In Zone3, servo pins 16-23 are active
│──────────20mS───────────│        In Zone4, servo pins 24-31 are active
                
  1-2mS servo pulse 
            
The preferred circuit of choice is to place a 4.7K resistor on each signal input
to the servo.  If long leads are used, place a 1000uF cap at the servo power
connector.  Servo's seem to be happy with a 5V supply receiving a 3.3V signal.

}
CON 
    _1uS = 1_000_000 /        1                                                 'Divisor for 1 uS

    ZonePeriod = 5_000                                                          '5mS (1/4th of typical servo period of 20mS)

VAR
        long          ZoneClocks
        long          ServoPinDirection
        long          ServoData[32]                                             '0-31 Servo Pulse Width information

PUB Start
    ZoneClocks := (clkfreq / _1uS * ZonePeriod)                                 'calculate # of clocks per ZonePeriod
    cognew(@ServoStart,@ZoneClocks)                                             

PUB Set(Pin, Width)                                                             'Set Servo value
      Width := 400 #> Width <# 3000                                            'limit Width value between 1000uS and 2000uS
        Pin :=    0 #>   Pin <# 31                                              'limit Pin value between 0 and 31
      ServoData[Pin] := clkfreq / _1uS * Width                                  'calculate # of clocks for a specific Pulse Width
      dira[Pin] := 1                                                            'set selected servo pin as an OUTPUT
      ServoPinDirection := dira                                                 'Read I/O state of ALL pins
    
DAT

'*********************
'* Assembly language *
'*********************
                        org
'------------------------------------------------------------------------------------------------------------------------------------------------
ServoStart              mov     Index,                  par                     'Set Index Pointer
                        rdlong  _ZoneClocks,            Index                   'Get ZoneClock value
                        add     Index,                  #4                      'Increment Index to next Pointer
                        rdlong  _ServoPinDirection,     Index                   'Get I/O pin directions
                        add     Index,                  #32                     'Increment Index to END of Zone1 Pointer
                        mov     Zone1Index,             Index                   'Set Index Pointer for Zone1
                        add     Index,                  #32                     'Increment Index to END of Zone2 Pointer
                        mov     Zone2Index,             Index                   'Set Index Pointer for Zone2
                        add     Index,                  #32                     'Increment Index to END of Zone3 Pointer
                        mov     Zone3Index,             Index                   'Set Index Pointer for Zone3
                        add     Index,                  #32                     'Increment Index to END of Zone4 Pointer
                        mov     Zone4Index,             Index                   'Set Index Pointer for Zone4
                        mov     dira,                   _ServoPinDirection      'Set I/O directions
'------------------------------------------------------------------------------------------------------------------------------------------------
Zone1                   mov     ZoneIndex,              Zone1Index              'Set Index Pointer for Zone1
                        mov     ZoneShift,              #0
                        call    #ZoneCore
Zone2                   mov     ZoneIndex,              Zone2Index              'Set Index Pointer for Zone2
                        mov     ZoneShift,              #8
                        call    #ZoneCore
Zone3                   mov     ZoneIndex,              Zone3Index              'Set Index Pointer for Zone3
                        mov     ZoneShift,              #16
                        call    #ZoneCore
Zone4                   mov     ZoneIndex,              Zone4Index              'Set Index Pointer for Zone4
                        mov     ZoneShift,              #24
                        call    #ZoneCore
                        jmp     #Zone1
'------------------------------------------------------------------------------------------------------------------------------------------------
ZoneCore                mov     SyncPoint,              cnt                     'Create a Sync Point with the system counter for current Zone
                        mov     temp,                   SyncPoint               'No "Glitch"... detect cnt rollover
                        add     temp,                   _ZoneClocks             'If a rollover was to occur, at this point temp would be less than _ZoneClocks
                        sub     temp,                   _ZoneClocks           wc
              if_C      jmp     #ZoneCore                                       'If rollover detected, wait a bit and get new sync point
        ZoneLoop        mov     ServoByte,              #0                      'Clear ServoByte
                        mov     LoopCounter,            #8                      'Set LoopCounter
                        mov     Index,                  ZoneIndex               'Set Index Pointer for proper Zone
        ServoLoop       rdlong  ServoWidth,             Index                   'Get Servo Data
                        add     ServoWidth,             SyncPoint               'Determine system counter location where pulse should end
                        sub     ServoWidth,             cnt                  wc 'subtract system counter from ServoWidth ; write result in C flag
                        rcl     ServoByte,              #1                      'Rotate "C Flag" right into ServoByte
                        sub     Index,                  #4                      'Decrement Index pointer to next address
                        djnz    LoopCounter,            #ServoLoop              'Decrement LoopCounter; Jump to ServoLoop if not "0"
                        xor     ServoByte,              #$FF                    'Invert ServoByte variable
                        shl     ServoByte,              ZoneShift               'Shift data to proper port or Zone location.
                        mov     outa,                   ServoByte               'Send ServoByte to Zone Port
                        mov     temp,                   _ZoneClocks             'Move _ZoneClocks into temp
                        add     temp,                   SyncPoint               'Add SyncPoint to _ZoneClocks
                        sub     temp,                   cnt                  wc 'Determine if cnt has exceeded width of _ZoneClocks ; write result in C flag
              if_NC     jmp     #ZoneLoop                                       'if the "C Flag" is not set stay in the current Zone
ZoneCore_RET            ret
'------------------------------------------------------------------------------------------------------------------------------------------------
temp                    res     1
Index                   res     1
ZoneShift               res     1
ZoneIndex               res     1
Zone1Index              res     1
Zone2Index              res     1
Zone3Index              res     1
Zone4Index              res     1
SyncPoint               res     1
ServoWidth              res     1
ServoByte               res     1
LoopCounter             res     1
'------------------------------------------------------------------------------------------------------------------------------------------------
_ZoneClocks             res     1
_ServoPinDirection      res     1