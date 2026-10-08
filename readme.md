# PureBasic - Endianness Swapper
An include that allows you to easily and efficiently swap the endianness of your values in PureBasic.

This project is a "continuation" of my old "*[PB-Utils/Endianness.pbi](/aziascreations/PB-Utils/)*" include.


## Features
* Endian swap for `.u`, `.w`, `.l`, `.i`, `.q`
* Nibble swap for `.a`, `.b`


## Usage



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
...


## Credits
* djes
  * Endianness - Original `EndianSwapL(Number.l)` procedure idea 
  ([Thread](https://www.purebasic.fr/english/viewtopic.php?f=19&t=17427))


## Submodules
Adding submodule:
```shell
git submodule add https://github.com/aziascreations/PB-Endianness.git Includes/PB-Endianness
```

Pull latest submodule version:
```shell
git submodule update --init --recursive
```


## License
All the code in this repo is released in the [Public Domain](LICENSE).
