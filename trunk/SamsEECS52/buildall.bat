cls
@echo off
echo XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
echo This file compiles everything!
echo XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

asm86 timer.asm m1 db ep
asm86 dma.asm m1 db ep
asm86 start.asm m1 db ep
asm86 mp3port.asm m1 db ep
asm86 keypad.asm m1 db ep
asm86 display.asm m1 db ep
asm86 lib188.asm m1 db ep
asm86 bootcode.asm m1 db ep

IC86 fatutil.c debug extend mod186 small optimize(0) noalign rom
IC86 ffrev.c debug extend mod186 small optimize(0) rom
IC86 keyupdat.c debug extend mod186 small optimize(0) rom
IC86 mainloop.c debug extend mod186 small optimize(0) rom
IC86 playmp3.c debug extend mod186 small optimize(0) rom
IC86 trakutil.c debug extend mod186 small optimize(0) rom
echo ================================
link86  bootcode.obj,c0smrom.obj, mp3port.obj, keypad.obj, display.obj, lib188.obj TO lnk1.lnk
echo ================================
link86 lnk1.lnk, timer.obj,dma.obj,fatutil.obj, ffrev.obj, IC86.lib, SCLIB.lib to lnk2.lnk
echo ================================
link86 lnk2.lnk,  mainloop.obj, playmp3.obj, keyupdat.obj, trakutil.obj  to startup.lnk
echo ================================
loc86 startup.lnk to startup noic ad(sm(code(0f8000h), data(4000h), stack(7000h),boot(0ffff0h)))
echo ================================
OH86 startup TO startup.hex  