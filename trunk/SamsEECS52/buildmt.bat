cls
@echo off
echo XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

asm86 c0smrom.asm m1 db ep
asm86 mp3port.asm m1 db ep
asm86 keypad.asm m1 db ep
asm86 display.asm m1 db ep

echo ================================
link86 c0smrom.obj, mp3port.obj, keypad.obj, display.obj to startup.lnk
echo ================================
loc86 startup.lnk to startup noic ad(sm(code(0500h), data(3000h), stack(7000h)))
echo ================================
