@echo off
setlocal EnableDelayedExpansion

set board=%1
set serial=%2
set cubework=%3
set headless-bat=%4
set apploc=%5
set bl2loc=%6
set bl1loc=%7
set stlinkexe=%8

cd %headless-bat%

REM Building the file -- will delete contents first 
IF EXIST %apploc% (
    rmdir %apploc% /s /q
)

IF EXIST %bl1loc% (
    rmdir %bl1loc% /s /q
)

IF EXIST %bl2loc% (
    rmdir %bl2loc% /s /q
)

call headless-build -data %cubework% -build %board% -console
echo Built Project

REM Calling st-link utility to
call %stlinkexe% -c SN=%serial% SWD Freq=1000 -ME

set appbin=%apploc%%board%App.bin
set bl2bin=%bl2loc%%board%BL2.bin
set bl1bin=%bl1loc%%board%BL1.bin


call %stlinkexe% -c SN=%serial% SWD Freq=1000 -P %bl1bin% 0x08000000 -V
call %stlinkexe% -c SN=%serial% SWD Freq=1000 -P %bl2bin% 0x08020000 -V
call %stlinkexe% -c SN=%serial% SWD Freq=1000 -P %appbin% 0x08040000 -V

call %stlinkexe% -c SN=%serial% SWD Freq=1000 -Rst
echo Loadined binaries
