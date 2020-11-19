#EndiannessVersionMajor = 0
#EndiannessVersionMinor = 0
#EndiannessVersionPatch = 1
#EndiannessVersion$ = "0.0.1"

Macro EndianSwapW(Number) : EndianSwap2(Number) : EndMacro
Macro EndianSwapU(Number) : EndianSwap2(Number) : EndMacro

Macro EndianSwap(Number)
	CompilerSelect TypeOf(Number)
		CompilerCase #PB_Word
			EndianSwapW(Number)
		CompilerCase #PB_Unicode
			EndianSwapU(Number)
		CompilerDefault
			CompilerError "Unsupported value type given in '+EndianSwap(Number)' !"
	CompilerEndSelect
EndMacro
