; Tests all possible permutations of a 16bit integer and validates
;  the operation with its binary string representation.
; It's a bit excessive, but I had weird issues I wanted to rule out.

EnableExplicit

XIncludeFile "../_UnitTesting.pbi"
XIncludeFile "../../Includes/Endianness.pbi"

Global Counter.q = 0
Global Current.w = 0
Global Result.w = 0

Global BinaryBefore.s{16}
Global BinaryAfter.s{16}

Global StartTime = ElapsedMilliseconds()
Global EndTime


For Counter = 0 To $FFFF
	
	; Gray code algo
	Current = (Counter ! (Counter >> 1)) & $FFFF
	
	PokeS(@BinaryBefore, RSet(Bin(Current, #PB_Word), 16, "0"), 16, #PB_Ascii | #PB_String_NoZero)
	
	; By Value
	Result = EndianSwapW(Current)
	PokeS(@BinaryAfter, RSet(Bin(Result, #PB_Word), 16, "0"), 16, #PB_Ascii | #PB_String_NoZero)
	
	If Not(CompareMemory(@BinaryBefore + 0, @BinaryAfter + 8, 8) And
	       CompareMemory(@BinaryBefore + 8, @BinaryAfter + 0, 8))
	
		Debug "Failure for EndianSwapW (1) !"
	
		Debug "Value: 0b" + RSet(Bin(Current, #PB_Word), 16, "0")
	
		Debug "Before: " + PeekS(@BinaryBefore + 0, 8, #PB_Ascii) + " " + PeekS(@BinaryBefore + 8, 8, #PB_Ascii)
		Debug " After: " + PeekS(@BinaryAfter + 0, 8, #PB_Ascii)  + " " + PeekS(@BinaryAfter + 8, 8, #PB_Ascii)
	
		End 1
	EndIf
	
	; Making sure a full circle works
	Result = EndianSwapW(Result)
	
	PokeS(@BinaryAfter, RSet(Bin(Result, #PB_Word), 16, "0"), 16, #PB_Ascii | #PB_String_NoZero)
	
	If Not CompareMemory(@BinaryBefore, @BinaryAfter, 16)
		Debug "Failure for EndianSwapW (2) !"
		Debug "Value: 0b" + RSet(Bin(Current, #PB_Word), 16, "0")
		End 2
	EndIf
Next

Debug "Done !"


EndTime = ElapsedMilliseconds()
OpenConsole()
PrintN("Took " + Str(EndTime - StartTime) + "ms")

Input()
