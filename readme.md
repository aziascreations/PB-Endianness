# PB-Endianness

A x64 user library for PureBasic that allows you to easily flip the endianness of any primitive data types that are available in PB.

## Building

To build the library and the resident file, you need to follow these steps:

1. Make sure the paths that are in [Build.cmd](Build.cmd) are correct.
2. Run [Clean.cmd](Clean.cmd) to cleanup the folder.
3. Run [Build.cmd](Build.cmd) to finally compile everything

## Installing

Once you have compiled the library, or once you have downloaded a release you need to put 2 files in specific locations:

* `Endianness.res` should go into `{Your-PB-Folder}\Residents`
* `Endianness` should go into `{Your-PB-Folder}\PureLibraries`

And finally you just have to restart the PureBasic IDE to make sure the compiler is reloaded.

## Documentation

**Make sure you declare your variables with the correct data type, otherwise you WILL get invalid results !**

### Library

`NibbleSwap(Value.a | Value.b).a|b`<br>
&emsp;Returns the number given `ascii` or `byte` value with it's nibbles swapped.

`EndianSwap2(Value.w | Value.u).w|u`<br>
&emsp;Returns the number given `word` or `unicode` value with it's endianness swapped.

`EndianSwap4(Value.l).l`<br>
&emsp;Returns the number given `long` value with it's endianness swapped.

`EndianSwap8(Value.i | Value.q).i|q`<br>
&emsp;Returns the number given `integer` or `quad` value with it's endianness swapped.

### Resident File

`#EndiannessVersionMajor`<br>
&emsp;Contains the major version number of this library.

`#EndiannessVersionMinor`<br>
&emsp;Contains the minor version number of this library.

`#EndiannessVersionPatch`<br>
&emsp;Contains the patch version number of this library.

`#EndiannessVersion$`<br>
&emsp;Contains the whole version number.

`+EndianSwapW(Number)`<br>
&emsp;Calls `EndianSwap2(Number)`.

`+EndianSwapU(Number)`<br>
&emsp;Calls `EndianSwap2(Number)`.

`+EndianSwapL(Number)`<br>
&emsp;Calls `EndianSwap4(Number)`.

`+EndianSwapI(Number)`<br>
&emsp;Calls `EndianSwap8(Number)`.

`+EndianSwapQ(Number)`<br>
&emsp;Calls `EndianSwap8(Number)`.

`+EndianSwap(Number)`<br>
&emsp;Calls the appropriate `EndianSwapX()` procedure depending on which data type the given value uses.<br>
&emsp;If the data type is not supported, a `CompilerError` will be raised.

## License

[Unlicense](LICENSE)
