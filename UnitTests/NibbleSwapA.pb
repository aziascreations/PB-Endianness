; Tests all possible permutations of an 8bit integer and validates
;  the operation with its binary string representation.
; It's a bit excessive, but I had weird issues I wanted to rule out.

EnableExplicit

XIncludeFile "_UnitTesting.pbi"
XIncludeFile "../Includes/Endianness.pbi"

Global Counter.a = 0
Global Current.a = 0
Global Result.a = 0

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

; .a is unsigned, but #PB_Byte is still given explicitly to Bin() to keep this test
;  consistent with Paranoid_NibbleSwapB.pb and to never rely on Bin()'s default size.
PokeS(@BinaryBefore, RSet(Bin(Current, #PB_Byte), 8, "0"), 8, #PB_Ascii | #PB_String_NoZero)

; By Value
Result = NibbleSwapA(Current)
PokeS(@BinaryAfter, RSet(Bin(Result, #PB_Byte), 8, "0"), 8, #PB_Ascii | #PB_String_NoZero)

If Not(CompareMemory(@BinaryBefore + 0, @BinaryAfter + 4, 4) And
       CompareMemory(@BinaryBefore + 4, @BinaryAfter + 0, 4))

	Debug "Failure for NibbleSwapA (1) !"

	Debug "Value: 0b" + RSet(Bin(Current, #PB_Byte), 8, "0")

	Debug "Before: " + PeekS(@BinaryBefore + 0, 4, #PB_Ascii) + " " + PeekS(@BinaryBefore + 4, 4, #PB_Ascii)
	Debug " After: " + PeekS(@BinaryAfter + 0, 4, #PB_Ascii)  + " " + PeekS(@BinaryAfter + 4, 4, #PB_Ascii)

	End 1
EndIf

; Making sure a full circle works
Result = NibbleSwapA(Result)

PokeS(@BinaryAfter, RSet(Bin(Result, #PB_Byte), 8, "0"), 8, #PB_Ascii | #PB_String_NoZero)

If Not CompareMemory(@BinaryBefore, @BinaryAfter, 8)
	Debug "Failure for NibbleSwapA (2) !"
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
