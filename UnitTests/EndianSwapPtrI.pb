; Tests a selection of representative values and validates the operation
;  against their expected byte-reversed result.
; Unlike the 8 and 16bit tests, the full range of an Integer can't be
;  brute-forced in a reasonable amount of time, so a fixed set of patterns is
;  used instead. Its size varies based on the CPU architecture, so the test
;  values are picked to make sense on both.

EnableExplicit

XIncludeFile "_UnitTesting.pbi"
XIncludeFile "../Includes/Endianness.pbi"

Procedure TestEndianSwapPtrI(In.i, Out.i, TestName.s)
	Protected Tmp.i

	Tmp = In
	EndianSwapPtrI(@Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @Out, SizeOf(Integer)), TestName + " (Single)",
	             RSet(Bin(In, #PB_Integer), SizeOf(Integer) * 8, "0") + " -> " +
	             RSet(Bin(Tmp, #PB_Integer), SizeOf(Integer) * 8, "0"))

	EndianSwapPtrI(@Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @In, SizeOf(Integer)), TestName + " (Full circle)")

	EndianSwapPtrI(@Tmp)
	EndianSwapPtrI(@Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @In, SizeOf(Integer)), TestName + " (Double circle)")
EndProcedure

Global StartTime = ElapsedMilliseconds()
Global EndTime


Debug "All bits at 0"
TestEndianSwapPtrI($0000000000000000, $0000000000000000, "All bits at 0")
Debug ""

Debug "All bits at 1"
CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
	TestEndianSwapPtrI($FFFFFFFFFFFFFFFF, $FFFFFFFFFFFFFFFF, "All bits at 1")
CompilerElse
	TestEndianSwapPtrI($FFFFFFFF, $FFFFFFFF, "All bits at 1")
CompilerEndIf
Debug ""

Debug "Alternating bits (1)"
CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
	TestEndianSwapPtrI($AAAAAAAAAAAAAAAA, $AAAAAAAAAAAAAAAA, "Alternating bits (1)")
CompilerElse
	TestEndianSwapPtrI($AAAAAAAA, $AAAAAAAA, "Alternating bits (1)")
CompilerEndIf
Debug ""

Debug "Alternating bits (2)"
CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
	TestEndianSwapPtrI($5555555555555555, $5555555555555555, "Alternating bits (2)")
CompilerElse
	TestEndianSwapPtrI($55555555, $55555555, "Alternating bits (2)")
CompilerEndIf
Debug ""

Debug "Distinct bytes"
CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
	TestEndianSwapPtrI($0123456789ABCDEF, $EFCDAB8967452301, "Distinct bytes")
CompilerElse
	TestEndianSwapPtrI($12345678, $78563412, "Distinct bytes")
CompilerEndIf
Debug ""

Debug "Lowest byte only"
CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
	TestEndianSwapPtrI($00000000000000FF, $FF00000000000000, "Lowest byte only")
CompilerElse
	TestEndianSwapPtrI($000000FF, $FF000000, "Lowest byte only")
CompilerEndIf
Debug ""

Debug "Highest byte only"
CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
	TestEndianSwapPtrI($FF00000000000000, $00000000000000FF, "Highest byte only")
CompilerElse
	TestEndianSwapPtrI($FF000000, $000000FF, "Highest byte only")
CompilerEndIf
Debug ""


If FailedUnitTests
	End 1
EndIf

Debug "Done !"


EndTime = ElapsedMilliseconds()
OpenConsole()
PrintN("Took " + Str(EndTime - StartTime) + "ms")

Input()
