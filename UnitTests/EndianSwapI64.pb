; Tests a selection of representative 64bit values and validates the operation
;  against their expected byte-reversed result.
; Unlike the 8 and 16bit tests, the full 64bit range can't be brute-forced in a
;  reasonable amount of time, so a fixed set of patterns is used instead.

EnableExplicit

XIncludeFile "_UnitTesting.pbi"
XIncludeFile "../Includes/Endianness.pbi"

Procedure TestEndianSwapI64(In.q, Out.q, TestName.s)
	Protected Tmp.q

	Tmp = EndianSwapI64(In)
	AssertIsTrue(CompareMemory(@Tmp, @Out, 8), TestName + " (Single)",
	             RSet(Bin(In, #PB_Quad), 64, "0") + " -> " + RSet(Bin(Tmp, #PB_Quad), 64, "0"))

	Tmp = EndianSwapI64(Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @In, 8), TestName + " (Full circle)")

	Tmp = EndianSwapI64(EndianSwapI64(Tmp))
	AssertIsTrue(CompareMemory(@Tmp, @In, 8), TestName + " (Double circle)")
EndProcedure

Global StartTime = ElapsedMilliseconds()
Global EndTime


Debug "All bits at 0"
TestEndianSwapI64($0000000000000000, $0000000000000000, "All bits at 0")
Debug ""

Debug "All bits at 1"
TestEndianSwapI64($FFFFFFFFFFFFFFFF, $FFFFFFFFFFFFFFFF, "All bits at 1")
Debug ""

Debug "Alternating bits (1)"
TestEndianSwapI64($AAAAAAAAAAAAAAAA, $AAAAAAAAAAAAAAAA, "Alternating bits (1)")
Debug ""

Debug "Alternating bits (2)"
TestEndianSwapI64($5555555555555555, $5555555555555555, "Alternating bits (2)")
Debug ""

Debug "Eight distinct bytes (1)"
TestEndianSwapI64($0123456789ABCDEF, $EFCDAB8967452301, "Eight distinct bytes (1)")
Debug ""

Debug "Eight distinct bytes (2)"
TestEndianSwapI64($F1E2D3C4B5A69708, $0897A6B5C4D3E2F1, "Eight distinct bytes (2)")
Debug ""

Debug "Lowest byte only"
TestEndianSwapI64($00000000000000FF, $FF00000000000000, "Lowest byte only")
Debug ""

Debug "Highest byte only"
TestEndianSwapI64($FF00000000000000, $00000000000000FF, "Highest byte only")
Debug ""

Debug "Lower dword only"
TestEndianSwapI64($0000000012345678, $7856341200000000, "Lower dword only")
Debug ""

Debug "Upper dword only"
TestEndianSwapI64($1234567800000000, $0000000078563412, "Upper dword only")
Debug ""


If FailedUnitTests
	End 1
EndIf

Debug "Done !"


EndTime = ElapsedMilliseconds()
OpenConsole()
PrintN("Took " + Str(EndTime - StartTime) + "ms")

Input()
