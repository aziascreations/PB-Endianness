; Tests a selection of representative 32bit values and validates the operation
;  against their expected byte-reversed result.
; Unlike the 8 and 16bit tests, the full 32bit range can't be brute-forced in a
;  reasonable amount of time, so a fixed set of patterns is used instead.

EnableExplicit

XIncludeFile "_UnitTesting.pbi"
XIncludeFile "../Includes/Endianness.pbi"

Procedure TestEndianSwapPtr32(In.l, Out.l, TestName.s)
	Protected Tmp.l

	Tmp = In
	EndianSwapPtr32(@Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @Out, 4), TestName + " (Single)",
	             RSet(Bin(In, #PB_Long), 32, "0") + " -> " + RSet(Bin(Tmp, #PB_Long), 32, "0"))

	EndianSwapPtr32(@Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @In, 4), TestName + " (Full circle)")

	EndianSwapPtr32(@Tmp)
	EndianSwapPtr32(@Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @In, 4), TestName + " (Double circle)")
EndProcedure

Global StartTime = ElapsedMilliseconds()
Global EndTime


Debug "All bits at 0"
TestEndianSwapPtr32($00000000, $00000000, "All bits at 0")
Debug ""

Debug "All bits at 1"
TestEndianSwapPtr32($FFFFFFFF, $FFFFFFFF, "All bits at 1")
Debug ""

Debug "Alternating bits (1)"
TestEndianSwapPtr32($AAAAAAAA, $AAAAAAAA, "Alternating bits (1)")
Debug ""

Debug "Alternating bits (2)"
TestEndianSwapPtr32($55555555, $55555555, "Alternating bits (2)")
Debug ""

Debug "Four distinct bytes (1)"
TestEndianSwapPtr32($12345678, $78563412, "Four distinct bytes (1)")
Debug ""

Debug "Four distinct bytes (2)"
TestEndianSwapPtr32($F1E2D3C4, $C4D3E2F1, "Four distinct bytes (2)")
Debug ""

Debug "Lowest byte only"
TestEndianSwapPtr32($000000FF, $FF000000, "Lowest byte only")
Debug ""

Debug "Highest byte only"
TestEndianSwapPtr32($FF000000, $000000FF, "Highest byte only")
Debug ""


If FailedUnitTests
	End 1
EndIf

Debug "Done !"


EndTime = ElapsedMilliseconds()
OpenConsole()
PrintN("Took " + Str(EndTime - StartTime) + "ms")

Input()
