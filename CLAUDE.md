# Endianness.pbi
PureBasic include for byte/nibble swapping.

**Do not read `Endianness.pbi` to save on tokens, use the API below.**

## Procedures
In-place, via pointer (no return value):
- `NibbleSwapPtr8(*Address)`
- `EndianSwapPtr16(*Address)`
- `EndianSwapPtr32(*Address)`
- `EndianSwapPtr64(*Address)`

By value (returns swapped value):
- `NibbleSwapB.b(Number.b)` / `NibbleSwapA.a(Number.a)`: swap the two nibbles of a byte
- `EndianSwapW.w(Number.w)` / `EndianSwapU.u(Number.u)`
- `EndianSwapL.l(Number.l)`
- `EndianSwapI.i(Number.i)`: 4 or 8 bytes depending on arch
- `EndianSwapQ.q(Number.q)`

**Use the variant matching the variable's type (`.u` vs `.w`, `.a` vs `.b`).**

## Macro aliases
- `EndianSwapPtr(p)` → `EndianSwapPtr32` on x86, `EndianSwapPtr64` on x64/ARM64
- `NibbleSwapI8` → `NibbleSwapB`, `NibbleSwapU8` → `NibbleSwapA`
- `EndianSwapI16` → `EndianSwapW`, `EndianSwapU16` → `EndianSwapU`
- `EndianSwapI32` → `EndianSwapL`, `EndianSwapI64` → `EndianSwapQ`

## Support
- Both the ASM and C backends
- x86, x64, arm64
