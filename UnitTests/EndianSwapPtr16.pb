; Tests all possible permitations of a 16bit integer and validates
;  the operation with its binary string representation.
; It's a bit excessive, but I had weird issues I wanted to rule out.

EnableExplicit

XIncludeFile "_UnitTesting.pbi"
XIncludeFile "../Includes/Endianness.pbi"

Global Counter.u = 0
Global Current.u = 0
Global Result.u = 0

Global BinaryBefore.s{16}
Global BinaryAfter.s{16}

Global StartTime = ElapsedMilliseconds()
Global EndTime


LoopStart:

; Current = i ^ (i >> 1)
!MOV ax, [v_Counter]
!MOV dx, ax
!SHR dx, 1
!XOR ax, dx
!MOV [v_Current], ax


PokeS(@BinaryBefore, RSet(Bin(Current), 16, "0"), 16, #PB_Ascii | #PB_String_NoZero)

; By Ptr
Result = Current

EndianSwapPtr16(@Result)
PokeS(@BinaryAfter, RSet(Bin(Result), 16, "0"), 16, #PB_Ascii | #PB_String_NoZero)

If Not(CompareMemory(@BinaryBefore + 0, @BinaryAfter + 8, 8) And
       CompareMemory(@BinaryBefore + 8, @BinaryAfter + 0, 8))
	
	Debug "Failure for EndianSwapPtr16 (1) !"
	
	Debug "Value: 0b" + RSet(Bin(Current), 16, "0")
	
	Debug "Before: " + PeekS(@BinaryBefore + 0, 8, #PB_Ascii) + " " + PeekS(@BinaryBefore + 8, 8, #PB_Ascii)
	Debug " After: " + PeekS(@BinaryAfter + 0, 8, #PB_Ascii)  + " " + PeekS(@BinaryAfter + 8, 8, #PB_Ascii)
	
	End 1
EndIf

; Making sure a full circle works
EndianSwapPtr16(@Result)

PokeS(@BinaryAfter, RSet(Bin(Result), 16, "0"), 16, #PB_Ascii | #PB_String_NoZero)

If Not CompareMemory(@BinaryBefore, @BinaryAfter, 16)
	Debug "Failure for EndianSwapPtr16 (2) !"
	Debug "Value: 0b" + RSet(Bin(Current), 16, "0")
	End 2
EndIf

; i += 1
!INC word [v_Counter]

; If Counter = 0 : Goto LoopStart
!JNZ l_loopstart

Debug "Done !"


EndTime = ElapsedMilliseconds()
OpenConsole()
PrintN("Took " + Str(EndTime - StartTime) + "ms")

Input()
