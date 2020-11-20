#EndiannessVersionMajor = 1
#EndiannessVersionMinor = 0
#EndiannessVersionPatch = 0
#EndiannessVersion$ = "1.0.0"

Macro EndianSwapW(Number) : EndianSwap2(Number) : EndMacro
Macro EndianSwapU(Number) : EndianSwap2(Number) : EndMacro
Macro EndianSwapL(Number) : EndianSwap4(Number) : EndMacro
Macro EndianSwapI(Number) : EndianSwap8(Number) : EndMacro
Macro EndianSwapQ(Number) : EndianSwap8(Number) : EndMacro

Macro EndianSwap(Number)
	CompilerSelect TypeOf(Number)
		CompilerCase #PB_Word
			EndianSwapW(Number)
		CompilerCase #PB_Unicode
			EndianSwapU(Number)
		CompilerCase #PB_Long
			EndianSwapL(Number)
		CompilerCase #PB_Integer
			EndianSwapI(Number)
		CompilerCase #PB_Quad
			EndianSwapQ(Number)
		CompilerDefault
			CompilerError "Unsupported value type given in '+EndianSwap(Number)' !"
	CompilerEndSelect
EndMacro
