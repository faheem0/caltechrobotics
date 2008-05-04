@echo off

set str=.asm
echo ==================================
echo ASSEMBLING

for %%A IN (%*) DO (
	if %%~xA==%str% echo asm86 %%A db m1 ep & asm86 %%A db m1 ep & echo ==================================
)

set str=%*
set str=%str:.asm=.obj%
set str=%str: =, %

echo LINKING: link86 %str% TO %~n1.lnk
link86 %str% TO %~n1.lnk
echo ==================================

echo DONE