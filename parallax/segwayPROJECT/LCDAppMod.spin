''********************************
''*  LCD AppMod translated from LcdTerminal,java  *
''********************************
VAR
    long writeOnly            ' read and write

    long ePin                              ' enable pin
    long rwPin                             ' read (1) or write (0)
    long rsPin                             ' register select
    long db4Pin                            ' 4-bit data bus
    long db5Pin 
    long db6Pin 
    long db7Pin 

  ' buffer for scrolling messages
  'private StringBuffer scrollMsg = new StringBuffer() 
CON
    _xinfreq = 5_000_000                     ' 5 MHz externa' crystal 
    _clkmode = xtal1 + pll16x                ' 5 MHz crysta' multiplied → 80 MHz
    TC = 694 'TimeConstant: 80MHz clock on prop to 8.68us Javelin increment
    
    CLR_LCD     = $01     ' clear the LCD
    CRSR_HOME   = $02     ' move the cursor home
    CRSR_LF     = $10     ' move the cursor left
    CRSR_RT     = $14     ' move the cursor right
    DISP_LF     = $18     ' shift display left
    DISP_RT     = $1C     ' shift display right

    ENTRY_MODE  = $04     ' entry mode set
    INC         = $02     ' increment DDRAM address
    DEC         = $00     ' decrement DDRAM address
    SHIFT_DISP  = $01     ' shift display

    DISP_CTRL   = $08     ' display on/off control
    DISP_ON     = $04     ' display on
    DISP_OFF    = $00     ' display off
    CRSR_ON     = $02     ' underline cursor on
    CRSR_OFF    = $00     ' underline cursor off
    BLINK_ON    = $01     ' blink cursor position
    BLINK_OFF   = $00     ' no blink of cursor position

    CRSR_DISP   = $10     ' cursor or display shift
    DISP_SHIFT  = $08     ' shift display
    CRSR_MOVE   = $00     ' move the cursor
    SHIFT_RIGHT = $04  
    SHIFT_LEFT  = $00  

    FUNC_SET    = $20     ' function set (interface)
    BUS_4       = $00     ' 4-bit bus
    LINES_2     = $08     ' for multi-line LCDs
    LINES_1     = $00     ' single-line display
    FONT_5X10   = $04     ' 5x10 font
    FONT_5X8    = $00     ' 5x8 font (standard)

    DDRAM       = $80  
    CGRAM       = $40  
    LINE1       = DDRAM + $00  
    LINE2       = DDRAM + $40  
    LINE3       = DDRAM + $14  
    LINE4       = DDRAM + $54

    'private static fina' int[] LINE_NUM = {LINE1, LINE2}  

     DESC_G     = $E7     ' descended characters in
     DESC_J     = $EA     '  5x10 mode
     DESC_P     = $F0  
     DESC_Q     = $F1  
     DESC_Y     = $F9  

     SCROLL_TM  = 2500     ' 250 ms scrol' delay

{{*
   * Creates new LCD Termina' object using specified pins
   }}     
PUB start(e, rw, rs, db4, db5, db6, db7)
    writeOnly~
    
    
    ePin:=e
    rwPin:= rw
    rsPin:= rs
    db4Pin:=db4
    db5Pin:=db5
    db6Pin:=db6
    db7Pin:=db7

    dira[ePin]~~
    dira[rwPin]~~
    dira[rsPin]~~
    dira[db4Pin]~~
    dira[db5Pin]~~
    dira[db6Pin]~~
    dira[db7Pin]~~
    
    outa[ePin]~
    initMultiLine
    
     
  {{
   * Sends four-bit value to bus
   }}
PUB putNibble(n)
   outa[db4Pin] :=((n & $01) == $01)   ' bit 0
   outa[db5Pin] :=((n & $02) == $02)   ' bit 1
   outa[db6Pin] :=((n & $04) == $04)   ' bit 2
   outa[db7Pin] :=((n & $08) == $08)   ' bit 3
   dira[ePin]~~
   pulseOut(1,ePin) 

  {{
   * Sends eight-bit value to bus
   }}
PUB putByte(b)
  putNibble(b>>4)        ' output high nibble
  putNibble(b)            ' output low nibble                        
 

  {{*
   * Initializes display for single-line operation
   }}
PUB initSingleLine 
    waitcnt(150*constant(TC)+cnt) 
    outa[rsPin]~
    dira[rsPin]~~ 
    if (!writeOnly)
      outa[rwPin]~
      dira[rwPin]~~
    putNibble($03)                             ' 8-bit interface
    waitcnt(50*constant(TC)+cnt)
    pulseOut(1,ePin)
    waitcnt(5*constant(TC)+cnt) 
    pulseOut(1,ePin)
    putNibble($02)                             ' 4-bit interface
    command(FUNC_SET | LINES_1 | FONT_5X8) 
    command(DISP_CTRL | DISP_ON | CRSR_OFF | BLINK_OFF) 
    command(ENTRY_MODE | INC)                   ' move cursor, no display shift
    command(CLR_LCD) 
  


  {{*
   * Initializes display for multi-line operation
   }}
PUB initMultiLine
    waitcnt(150*constant(TC)+cnt) 
    outa[rsPin]~
    if (!writeOnly)
      outa[rwPin]~
    putNibble($03)                             ' 8-bit interface
    waitcnt(50*constant(TC)+cnt)
    pulseOut(1,ePin)
    waitcnt(5*constant(TC)+cnt) 
    pulseOut(1,ePin)
    putNibble($02)                             ' 4-bit interface
    command(FUNC_SET | LINES_2 | FONT_5X8) 
    command(DISP_CTRL | DISP_ON | CRSR_OFF | BLINK_OFF) 
    command(ENTRY_MODE | INC)                   ' move cursor, no display shift
    command(CLR_LCD) 
  

  {{*
   * Initializes display for 5x10 font
   }}
PUB init5x10
    waitcnt(150*constant(TC)+cnt) 
    outa[rsPin]~
    dira[rsPin]~~ 
    if (!writeOnly)
      outa[rwPin]~
      dira[rwPin]~~
    putNibble($03)                             ' 8-bit interface
    waitcnt(50*constant(TC)+cnt)
    pulseOut(1,ePin)
    waitcnt(5*constant(TC)+cnt) 
    pulseOut(1,ePin)
    putNibble($02)                             ' 4-bit interface
    command(FUNC_SET | LINES_1 | FONT_5X10) 
    command(DISP_CTRL | DISP_ON | CRSR_OFF | BLINK_OFF) 
    command(ENTRY_MODE | INC)                   ' move cursor, no display shift
    command(CLR_LCD) 
  


  {{*
   * Sends command byte to LCD
   *
   * @param cmd Command to send to LCD
   }}
PUB command(cmd) 
    if (!writeOnly)
      outa[rwPin]~ ' set write mode
    outa[rsPin]~                         ' command mode
    putByte(cmd) 
    outa[rsPin]~~                 ' return to data mode
    waitcnt(clkfreq/500+cnt)


  {{*
   * Writes character on LCD at cursor position
   *
   * @param c Character to write on LCD
   }}
PUB write(c) 
    if (!writeOnly)
      outa[rwPin]~    ' set write mode
    outa[rsPin]~~                ' character mode
    putByte(c)
PUB num(d)
    if (!writeOnly)
      outa[rwPin]~    ' set write mode
    outa[rsPin]~~                ' character mode
    if d==0
      putByte($30)
    else
      repeat while (d) <>0
        putByte((d // 10)|$30)
        d:=d/10    
PUB bin(b, n) |i
    home
    repeat i from (n - 1) to 0 
      num((b& (1<<i))>>i)
PUB str(stringptr)  'added method

'' Print a zero-terminated string

  repeat strsize(stringptr)
    write(byte[stringptr++])

  {{*
   * Writes string on LCD at cursor position
   *
   * @param s String to write on LCD
   }}
{{PUB write(String s)  | temp, i
  temp:=STRSIZE(@s)
  repeat i from 0 to temp
    write(s.charAt(i))     }}


  {{*
   * Writes string on LCD at cursor position
   *
   * @param sb StringBuffer to write on LCD
   
  public void write(StringBuffer sb) {
    for (int i = 0  i < sb.length()  i++)
      write(sb.charAt(i)) 
  }
  }


  {{*
   * Scrolls string on LCD on designated line
   *
   * @param msg String to scrol' across LCD
   }}
{{PUB scroll(line, String msg) 

    int lastStart 

    ' pad ends of message with spaces to clear window
    scrollMsg.clear() 
    scrollMsg.append("        ") 
    scrollMsg.append(msg) 
    scrollMsg.append("        ") 

    ' set last start position of substring
    lastStart = scrollMsg.length() - 8 

    ' scrol' the message
    for (int start = 0  start <= lastStart  start++) {
      moveTo(line, 0) 
      for (int offset = 0  offset < 8  offset++) {
        write(scrollMsg.charAt(start + offset)) 
      }
      CPU.delay(SCROLL_TM) 
    }                          }}
  


  {{*
   * Scrolls stringbuffer on LCD on designated line
   *
   * @param msg StringBuffer to scrol' across LCD
   }}
 {{ public void scroll(int line, StringBuffer msg) {

    int lastStart 

    ' pad ends of message with spaces to clear window
    scrollMsg.clear() 
    scrollMsg.append("        ") 
    ' scrollMsg.append(msg.toString()) 
    for (int pos = 0  pos < msg.length()  pos++) {
      scrollMsg.append(msg.charAt(pos)) 
    }
    scrollMsg.append("        ") 

    ' set last start position of substring
    lastStart = scrollMsg.length() - 8 

    ' scrol' the message
    for (int start = 0  start <= lastStart  start++) {
      moveTo(line, 0) 
      for (int offset = 0  offset < 8  offset++) {
        write(scrollMsg.charAt(start + offset)) 
      }
      CPU.delay(SCROLL_TM) 
    }
  }        }}


  {{*
   * Scrolls integer on LCD on designated line
   *
   * @param num Integer to scrol' across LCD
   }}
 {{ public void scroll(int line, int num) {

    int lastStart 

    ' pad ends of message with spaces to clear window
    scrollMsg.clear() 
    scrollMsg.append("        ") 
    scrollMsg.append(num) 
    scrollMsg.append("        ") 

    ' set last start position of substring
    lastStart = scrollMsg.length() - 8 

    ' scrol' the message
    for (int start = 0  start <= lastStart  start++) {
      moveTo(line, 0) 
      for (int offset = 0  offset < 8  offset++) {
        write(scrollMsg.charAt(start + offset)) 
      }
      CPU.delay(SCROLL_TM) 
    }
  }             }}


  {{*
   * Clears LCD  returns cursor to line 1, position 0
   }}
PUB clearScr 
    command(CLR_LCD) 
    waitcnt(20*constant(TC)+cnt)   

  {{*
   * Moves cursor to home positon (line 1, position 0) -- DDRAM unchanged
   }}
PUB home 
    command(CRSR_HOME) 
    waitcnt(20*constant(TC)+cnt)  

  {{*
   * Moves LCD cursor to specified line and cursor position
   *
   * @param line Line number (LINE1 ... LINE4)
   * @param column Position on line (0 .. 7)
   }}
PUB moveTo( line,  column)
    command(line + column)   

  {{*
   * Read byte from LCD at cursor position ($00 if write-only LCD)
   *
   * @return Data at current cursor position
   }}
PUB read: lcdChar 

    lcdChar := $00 

    if (!writeOnly) 
      ' make bus pins inputs before commanding read
      dira[db4Pin]~ 
      dira[db5Pin]~ 
      dira[db6Pin]~ 
      dira[db7Pin]~ 
      ' read the bus
      outa[rwPin]~~ 
      outa[rsPin]~~ 
      ' get high nibble
      outa[ePin]~~  
      if (ina[db4Pin])
        lcdChar |= $10 
      if (ina[db5Pin])
        lcdChar |= $20 
      if (ina[db6Pin])
        lcdChar |= $40 
      if (ina[db7Pin])
        lcdChar |= $80 
      outa[ePin]~   
      waitcnt(constant(TC)+cnt)
      ' get low nibble
      outa[ePin]~~   
      if (ina[db4Pin])
        lcdChar |= $01 
      if (ina[db5Pin])
        lcdChar |= $02 
      if (ina[db6Pin])
        lcdChar |= $04 
      if (ina[db7Pin])
        lcdChar |= $08 
      outa[ePin]~  
      outa[rwPin]~  


  {{*
   * Read byte from LCD at specified address
   *
   * @param address Address to read from LCD
   * @return Data at current cursor position
   }}
{{PUB read( address)
    command(address)  
    result:=read }}
  


  {{*
   * Sends custom character data to LCD
   *
   * @param cNum Customer character number (0 - 7)
   * @param cData[] Custom character data
   }}
{{PUB createChar5x7(int cNum, char cData[]) {
    command(CGRAM + (8 * cNum))                 ' point to character RAM
    for (int i = 0  i < 8  i++) {
      write(cData[i])                           ' download character data
    }
  }       }}


  {{*
   * Sends custom character data to LCD
   *
   * @param cNum Customer character number (0 - 3)
   * @param cData[] Custom character data
   }}
{{PUB createChar5x10(int cNum, char cData[]) {
    command(CGRAM + (16 * cNum))                ' point to character RAM
    for (int i = 0  i < 11  i++) {
      write(cData[i])                           ' download character data
    }
  }
         }}

  {{*
   * Displays underline cursor on LCD
   }}
PUB cursorOn  
    command(DISP_CTRL | DISP_ON | CRSR_ON)   

  {{*
   * Removes underline cursor from LCD
   }}
PUB cursorOff  
    command(DISP_CTRL | DISP_ON)       

  {{*
   * Displays blinking [block] cursor on LCD
   }}
PUB blinkOn 
    command(DISP_CTRL | DISP_ON | BLINK_ON)  
                                               
  {{*
   * Removes blinking cursor from LCD
   }}
PUB blinkOff 
    command(DISP_CTRL | DISP_ON)  
  
  {{*
   * Restores display -- cursors are removed
   }}
PUB displayOn  
    command(DISP_CTRL | DISP_ON)        

  {{*
   * Blanks display without changing contents
   }}
PUB displayOff  
    command(DISP_CTRL | DISP_OFF)    

  {{*
   * Reads LCD Termina' AppMod buttons
   *
   * This method causes the LCD bus pins to become inputs, ensures that the
   * LCD is in Write mode (so that its bus pins remain tri-stated), then
   * debounces the buttons with a simple loop.  It is not necessary to return
   * the LCD bus pins to outputs as this wil' be handled by the next LCD
   * write.
   }}          
PUB readButtons:buttons  |i

    buttons := $0F                           ' assume al' pressed

    ' make bus pins inputs before commanding read
    dira[db4Pin]~
    dira[db5Pin]~
    dira[db6Pin]~
    dira[db7Pin]~  

    'if (!writeOnly)
      outa[rwPin]~     ' force LCD bus pins to inputs
    waitcnt(clkfreq/500+cnt)
    ' read pushbuttons on shared LCD bus
    repeat i from 0 to 5
      ' clear bit(s) if not pressed
      if (!ina[db4Pin])
        buttons &= $0E  
      if (!ina[db5Pin])
        buttons &= $0D  
      if (!ina[db6Pin])
        buttons &= $0B  
      if (!ina[db7Pin])
        buttons &= $07  
      waitcnt(50*constant(TC)+cnt)        

    dira[db4Pin]~~
    dira[db5Pin]~~
    dira[db6Pin]~~
    dira[db7Pin]~~                  
  
PUB pulseOut(time, pin)
  outa[pin]:= !outa[pin]
  waitcnt(time*constant(TC)+cnt)
  outa[pin]:= !outa[pin]      
      