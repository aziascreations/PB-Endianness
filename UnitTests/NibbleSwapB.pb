; Tests all possible permutations of an 8bit integer and validates
;  the operation with its binary string representation.
; It's a bit excessive, but I had weird issues I wanted to rule out.

EnableExplicit

XIncludeFile "_UnitTesting.pbi"
XIncludeFile "../Includes/Endianness.pbi"

Global Counter.b = 0
Global Current.b = 0
Global Result.b = 0

Global BinaryBefore.s{8}
Global BinaryAfter.s{8}

Global StartTime = ElapsedMilliseconds()
Global EndTime


LoopStart:

; Current = i ^ (i >> 1)
!MOV al, [v_Counter]
!MOV dl, al
!SHR dl, 1
!XOR al, dl
!MOV [v_Current], al

; .b is signed, so Bin() must be given #PB_Byte explicitly, otherwise PureBasic
;  sign-extends negative values to a Quad before converting, giving way more than 8 digits.
PokeS(@BinaryBefore, RSet(Bin(Current, #PB_Byte), 8, "0"), 8, #PB_Ascii | #PB_String_NoZero)

; By Value
Result = NibbleSwapB(Current)
PokeS(@BinaryAfter, RSet(Bin(Result, #PB_Byte), 8, "0"), 8, #PB_Ascii | #PB_String_NoZero)

If Not(CompareMemory(@BinaryBefore + 0, @BinaryAfter + 4, 4) And
       CompareMemory(@BinaryBefore + 4, @BinaryAfter + 0, 4))

	Debug "Failure for NibbleSwapB (1) !"

	Debug "Value: 0b" + RSet(Bin(Current, #PB_Byte), 8, "0")

	Debug "Before: " + PeekS(@BinaryBefore + 0, 4, #PB_Ascii) + " " + PeekS(@BinaryBefore + 4, 4, #PB_Ascii)
	Debug " After: " + PeekS(@BinaryAfter + 0, 4, #PB_Ascii)  + " " + PeekS(@BinaryAfter + 4, 4, #PB_Ascii)

	End 1
EndIf

; Making sure a full circle works
Result = NibbleSwapB(Result)

PokeS(@BinaryAfter, RSet(Bin(Result, #PB_Byte), 8, "0"), 8, #PB_Ascii | #PB_String_NoZero)

If Not CompareMemory(@BinaryBefore, @BinaryAfter, 8)
	Debug "Failure for NibbleSwapB (2) !"
	Debug "Value: 0b" + RSet(Bin(Current, #PB_Byte), 8, "0")
	End 2
EndIf

; i += 1
!INC byte [v_Counter]

; If Counter = 0 : Goto LoopStart
!JNZ l_loopstart

Debug "Done !"


EndTime = ElapsedMilliseconds()
OpenConsole()
PrintN("Took " + Str(EndTime - StartTime) + "ms")

Input()
