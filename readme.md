# PureBasic - Endianness Swapper
An include that allows you to easily and efficiently swap the endianness of your values in PureBasic.

This project is a "continuation" of my old "*[PB-Utils/Endianness.pbi](/aziascreations/PB-Utils/)*" include.


## Features
* Endian swap for `.u`, `.w`, `.l`, `.i`, `.q`
* Nibble swap for `.a`, `.b`
* Swap by value/pointer
* Supports x86/x64/arm64
* Supports asm/c backends


## Usage
Adding as a submodule:
```shell
git submodule add https://github.com/aziascreations/PB-Endianness.git Includes/PB-Endianness
```

Pulling the latest version:
```shell
git submodule update --init --recursive
```


## Example

### By Value
```purebasic
XIncludeFile "Endianness.pbi"

Define MyValue.l = $EFBEADDE

MyValue = EndianSwapL($MyValue)

Debug Hex(MyValue, #PB_Long)
; Prints: DEADBEEF
```

### By Pointer
```purebasic
XIncludeFile "Endianness.pbi"

Define MyValue.l = $EFBEADDE

EndianSwapPtr32(@MyValue)

Debug Hex(MyValue, #PB_Long)
; Prints: DEADBEEF
```


## Configuration
When using the C backend, the include will use the GCC builtins for endianness swapping.

If you want to disable it for some reason, you can define the
`#Endianness_UseGccBuiltins` to `#False` in your projects or source code.


## Credits & Special Thanks
* djes
  * Endianness - Original `EndianSwapL(Number.l)` procedure idea 
  ([Thread](https://www.purebasic.fr/english/viewtopic.php?f=19&t=17427))
* [AndyMK](https://www.purebasic.fr/english/memberlist.php?mode=viewprofile&u=2587) / [agorangetek](https://github.com/agorangetek)
  * PureBasic Visual Studio Code Extension ([GitHub repository](https://github.com/agorangetek/purebasic-vscode-extension))

## License
All the code in this repo is released in the [Public Domain](LICENSE).
