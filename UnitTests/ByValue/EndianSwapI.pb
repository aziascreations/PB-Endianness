; Tests a selection of representative values and validates the operation
;  against their expected byte-reversed result.
; Unlike the 8 and 16bit tests, the full range of an Integer can't be
;  brute-forced in a reasonable amount of time, so a fixed set of patterns is
;  used instead. Its size varies based on the CPU architecture, so the test
;  values are picked to make sense on both.

EnableExplicit

XIncludeFile "../_UnitTesting.pbi"
XIncludeFile "../../Includes/Endianness.pbi"

Procedure TestEndianSwapI(In.i, Out.i, TestName.s)
	Protected Tmp.i

	Tmp = EndianSwapI(In)
	
	CompilerIf #_NibblePoker_Endianness_IsArch_x86
	    AssertIsTrue(CompareMemory(@Tmp, @Out, SizeOf(Integer)), TestName + " (Single)",
	                 RSet(Bin(In, #PB_Long), SizeOf(Integer) * 8, "0") + " -> " +
	                 RSet(Bin(Tmp, #PB_Long), SizeOf(Integer) * 8, "0"))
	CompilerElseIf #_NibblePoker_Endianness_IsArch_x64
	    AssertIsTrue(CompareMemory(@Tmp, @Out, SizeOf(Integer)), TestName + " (Single)",
	                 RSet(Bin(In, #PB_Quad), SizeOf(Integer) * 8, "0") + " -> " +
	                 RSet(Bin(Tmp, #PB_Long), SizeOf(Integer) * 8, "0"))
	CompilerElse
	    CompilerError "Unsupported CPU Architecture !"
	CompilerEndIf
	
	    

	Tmp = EndianSwapI(Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @In, SizeOf(Integer)), TestName + " (Full circle)")

	Tmp = EndianSwapI(EndianSwapI(Tmp))
	AssertIsTrue(CompareMemory(@Tmp, @In, SizeOf(Integer)), TestName + " (Double circle)")
EndProcedure

Global StartTime = ElapsedMilliseconds()
Global EndTime


Debug "All bits at 0"
TestEndianSwapI($0000000000000000, $0000000000000000, "All bits at 0")
Debug ""

Debug "All bits at 1"
CompilerIf SizeOf(Integer) = 8
	TestEndianSwapI($FFFFFFFFFFFFFFFF, $FFFFFFFFFFFFFFFF, "All bits at 1")
CompilerElse
	TestEndianSwapI($FFFFFFFF, $FFFFFFFF, "All bits at 1")
CompilerEndIf
Debug ""

Debug "Alternating bits (1)"
CompilerIf SizeOf(Integer) = 8
	TestEndianSwapI($AAAAAAAAAAAAAAAA, $AAAAAAAAAAAAAAAA, "Alternating bits (1)")
CompilerElse
	TestEndianSwapI($AAAAAAAA, $AAAAAAAA, "Alternating bits (1)")
CompilerEndIf
Debug ""

Debug "Alternating bits (2)"
CompilerIf SizeOf(Integer) = 8
	TestEndianSwapI($5555555555555555, $5555555555555555, "Alternating bits (2)")
CompilerElse
	TestEndianSwapI($55555555, $55555555, "Alternating bits (2)")
CompilerEndIf
Debug ""

Debug "Distinct bytes"
CompilerIf SizeOf(Integer) = 8
	TestEndianSwapI($0123456789ABCDEF, $EFCDAB8967452301, "Distinct bytes")
CompilerElse
	TestEndianSwapI($12345678, $78563412, "Distinct bytes")
CompilerEndIf
Debug ""

Debug "Lowest byte only"
CompilerIf SizeOf(Integer) = 8
	TestEndianSwapI($00000000000000FF, $FF00000000000000, "Lowest byte only")
CompilerElse
	TestEndianSwapI($000000FF, $FF000000, "Lowest byte only")
CompilerEndIf
Debug ""

Debug "Highest byte only"
CompilerIf SizeOf(Integer) = 8
	TestEndianSwapI($FF00000000000000, $00000000000000FF, "Highest byte only")
CompilerElse
	TestEndianSwapI($FF000000, $000000FF, "Highest byte only")
CompilerEndIf
Debug ""


If FailedUnitTests
	End 1
EndIf

Debug "Done !"


EndTime = ElapsedMilliseconds()
OpenConsole()
PrintN("Took " + Str(EndTime - StartTime) + "ms")
