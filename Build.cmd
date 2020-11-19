@echo off

set PATH=%PATH%;D:\DevelopmentNew\.bin\nasm-2.15.05
set PATH=%PATH%;C:\Program Files\PureBasic\PureBasic_5.70_x64\Compilers
set PATH=%PATH%;C:\Program Files\PureBasic\PureBasic_5.70_x64\SDK

del *.obj
del *.lib
del *.res
del Endianness
del *.exe
del *.log
del *.cfg

nasm -o Endianness.obj -f win64 Endianness.asm

polib.exe /OUT:Endianness.lib Endianness.obj

LibraryMaker.exe .\ /TO .\ /ALL /COMPRESSED

pbcompiler.exe /IGNORERESIDENT "Endianness.res" /RESIDENT "Endianness.res" Endianness.pb

pause
