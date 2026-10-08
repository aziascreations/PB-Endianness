
EnableExplicit
XIncludeFile "_UnitTesting.pbi"
XIncludeFile "../Includes/Endianness.pbi"


; ------------------------------------------------------------------------------
; ;- Ascii (U8)
; 
; Define VarA1_In.a  = %11110000
; Define VarA1_Out.a = %00001111
; 
; Define VarA1_Tmp.a = VarA1_In
; 
; NibbleSwap(@VarA1_Tmp)
; Assert(CompareMemory(@VarA1_Tmp, @VarA1_Out, 1), "UInt8 with b7 to 0 is fine (Single)",
;        RSet(Bin(VarA1_Tmp), 8, "0") + " vs " + RSet(Bin(VarA1_Out), 8, "0"))
; 
; NibbleSwap(@VarA1_Tmp)
; Assert(CompareMemory(@VarA1_Tmp, @VarA1_In, 1), "UInt8 with b7 to 0 is fine (Full circle)",
;        RSet(Bin(VarA1_Tmp), 8, "0") + " vs " + RSet(Bin(VarA1_In), 8, "0"))
; 
; NibbleSwap(@VarA1_Tmp)
; NibbleSwap(@VarA1_Tmp)
; Assert(CompareMemory(@VarA1_Tmp, @VarA1_In, 1), "UInt8 with b7 to 0 is fine (Double circle)",
;        RSet(Bin(VarA1_Tmp), 8, "0") + " vs " + RSet(Bin(VarA1_In), 8, "0"))
; 
; Debug ""
; 
; Define VarA2_In.a  = %01010101
; Define VarA2_Out.a = %10101010
; 
; Define VarA2_Tmp.a = VarA2_In
; 
; NibbleSwap(@VarA2_Tmp)
; Assert(CompareMemory(@VarA2_Tmp, @VarA2_Out, 1), "UInt8 with b7 to 0 is fine (Single)",
;        RSet(Bin(VarA2_Tmp), 8, "0") + " vs " + RSet(Bin(VarA2_Out), 8, "0"))
; 
; NibbleSwap(@VarA2_Tmp)
; Assert(CompareMemory(@VarA2_Tmp, @VarA2_In, 1), "UInt8 with b7 to 0 is fine (Full circle)",
;        RSet(Bin(VarA2_Tmp), 8, "0") + " vs " + RSet(Bin(VarA2_In), 8, "0"))
; 
; NibbleSwap(@VarA2_Tmp)
; NibbleSwap(@VarA2_Tmp)
; Assert(CompareMemory(@VarA2_Tmp, @VarA2_In, 1), "UInt8 with b7 to 0 is fine (Double circle)",
;        RSet(Bin(VarA2_Tmp), 8, "0") + " vs " + RSet(Bin(VarA2_In), 8, "0"))
; 
; Debug ""



; ------------------------------------------------------------------------------
;- Unicode (U16)

Procedure TestU16(In.u, Out.u)
	Protected Tmp.u
	
	Tmp = In
	
	EndianSwapPtr16(@Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @Out, 1), "Single", RSet(Bin(Tmp), 16, "0") + " vs " + RSet(Bin(Out), 16, "0"))
	
	EndianSwapPtr16(@Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @In, 1), "Full circle", RSet(Bin(Tmp), 16, "0") + " vs " + RSet(Bin(Out), 16, "0"))
	
	EndianSwapPtr16(@Tmp)
	EndianSwapPtr16(@Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @In, 1), "Double circle", RSet(Bin(Tmp), 16, "0") + " vs " + RSet(Bin(Out), 16, "0"))
	
	
	Tmp = In
	
	Tmp = EndianSwapU16(Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @Out, 1), "Single", RSet(Bin(Tmp), 16, "0") + " vs " + RSet(Bin(Out), 16, "0"))
	
	Tmp = EndianSwapU16(Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @In, 1), "Full circle", RSet(Bin(Tmp), 16, "0") + " vs " + RSet(Bin(Out), 16, "0"))
	
	Tmp = EndianSwapU16(Tmp)
	Tmp = EndianSwapU16(Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @In, 1), "Double circle 1", RSet(Bin(Tmp), 16, "0") + " vs " + RSet(Bin(Out), 16, "0"))
	
	Tmp = EndianSwapU16(EndianSwapU16(Tmp))
	AssertIsTrue(CompareMemory(@Tmp, @In, 1), "Double circle 2", RSet(Bin(Tmp), 16, "0") + " vs " + RSet(Bin(Out), 16, "0"))
EndProcedure

Debug ""
Debug "U16 Tests"
Debug ""

Debug "All bits stay at 0"
TestU16(%0000000000000000, %0000000000000000)
Debug ""

Debug "All bits stay at 0"
TestU16(%1111111111111111, %1111111111111111)
Debug ""

Debug "Alterning bits (1)"
TestU16(%1010101010101010, %1010101010101010)
Debug ""

Debug "Alterning bits (2)"
TestU16(%0101010101010101, %0101010101010101)
Debug ""

Debug "b15 at 0, will be 0"
;  In: 0b0111_0000_1000_1111
; Out: 0b1000_1111_0111_0000
TestU16(%0111000010001111, %1000111101110000)
Debug ""

Debug "b15 at 1, will be 0"
;  In: 0b1111_0000_1000_1111
; Out: 0b1000_1111_1111_0000
TestU16(%1111000010001111, %1000111111110000)
Debug ""



; ------------------------------------------------------------------------------
;- Word (U16)

Procedure TestI16(In.w, Out.w)
	Protected Tmp.w = In
	
	EndianSwapPtr16(@Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @Out, 1), "Single", RSet(Bin(Tmp), 16, "0") + " vs " + RSet(Bin(Out), 16, "0"))
	
	EndianSwapPtr16(@Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @In, 1), "Full circle", RSet(Bin(Tmp), 16, "0") + " vs " + RSet(Bin(Out), 16, "0"))
	
	EndianSwapPtr16(@Tmp)
	EndianSwapPtr16(@Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @In, 1), "Double circle", RSet(Bin(Tmp), 16, "0") + " vs " + RSet(Bin(Out), 16, "0"))
	
	
	Tmp = In
	
	Tmp = EndianSwapI16(Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @Out, 1), "Single", RSet(Bin(Tmp), 16, "0") + " vs " + RSet(Bin(Out), 16, "0"))
	
	Tmp = EndianSwapI16(Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @In, 1), "Full circle", RSet(Bin(Tmp), 16, "0") + " vs " + RSet(Bin(Out), 16, "0"))
	
	Tmp = EndianSwapI16(Tmp)
	Tmp = EndianSwapI16(Tmp)
	AssertIsTrue(CompareMemory(@Tmp, @In, 1), "Double circle 1", RSet(Bin(Tmp), 16, "0") + " vs " + RSet(Bin(Out), 16, "0"))
	
	Tmp = EndianSwapI16(EndianSwapI16(Tmp))
	AssertIsTrue(CompareMemory(@Tmp, @In, 1), "Double circle 2", RSet(Bin(Tmp), 16, "0") + " vs " + RSet(Bin(Out), 16, "0"))
EndProcedure


Debug "All bits stay at 0"
TestI16(%0000000000000000, %0000000000000000)
Debug ""

Debug "All bits stay at 0"
TestI16(%1111111111111111, %1111111111111111)
Debug ""

Debug "Alterning bits (1)"
TestI16(%1010101010101010, %1010101010101010)
Debug ""

Debug "Alterning bits (2)"
TestI16(%0101010101010101, %0101010101010101)
Debug ""

Debug "b15 at 0, will be 0"
;  In: 0b0111_0000_1000_1111
; Out: 0b1000_1111_0111_0000
TestI16(%0111000010001111, %1000111101110000)
Debug ""

Debug "b15 at 1, will be 0"
;  In: 0b1111_0000_1000_1111
; Out: 0b1000_1111_1111_0000
TestI16(%1111000010001111, %1000111111110000)
Debug ""



; ;- Byte (I8)
; 
; Define VarB1_In.b  = %11110000
; Define VarB1_Out.b = %00001111
; 
; AssertEqualsB(NibbleSwapB(VarB1_In), VarB1_Out, "Int8 with b7 To 1 is fine")
; AssertEqualsB(NibbleSwapB(NibbleSwapB(VarB1_In)), VarB1_In, "Full circle Int8 with b7 to 1 is fine")
; AssertEqualsB(NibbleSwapB(NibbleSwapB(NibbleSwapB(NibbleSwapB(VarB1_In)))), VarB1_In, "Double circle Int8 with b7 to 1 is fine")
; 
; 
; Define VarB2_In.b  = %01010101
; Define VarB2_Out.b = %10101010
; 
; AssertEqualsB(NibbleSwapB(VarB2_In), VarB2_Out, "Int8 with b7 To 0 is fine")
; AssertEqualsB(NibbleSwapB(NibbleSwapB(VarB2_In)), VarB2_In, "Full circle Int8 with b7 to 0 is fine")
; AssertEqualsB(NibbleSwapB(NibbleSwapB(NibbleSwapB(NibbleSwapB(VarB2_In)))), VarB2_In, "Double circle Int8 with b7 to 0 is fine")
; 
; Debug ""
	
	
; 	Define VarW.w = $B903
; 	Debug "Word:"
; 	Debug "0x"+RSet(Hex(VarW, #PB_Word), 4, "0")+" -> 0x"+RSet(Hex(EndianSwapW(VarW), #PB_Word), 4, "0")
; 	Debug Str(VarW)+" -> "+Str(EndianSwapW(VarW))
; 	Debug ""
; 	
; 	Define VarU.w = $B903
; 	Debug "Unicode:"
; 	Debug "0x"+RSet(Hex(VarU, #PB_Unicode), 4, "0")+" -> 0x"+RSet(Hex(EndianSwapU(VarU), #PB_Unicode), 4, "0")
; 	Debug StrU(VarU, #PB_Unicode)+" -> "+StrU(EndianSwapU(VarU), #PB_Unicode)
; 	Debug ""
; 	
; 	Define VarL.l = $E530A6F0
; 	Debug "Long:"
; 	Debug "0x"+RSet(Hex(VarL, #PB_Long), 8, "0")+" -> 0x"+RSet(Hex(EndianSwapL(VarL), #PB_Long), 8, "0")
; 	Debug Str(VarL)+" -> "+Str(EndianSwapL(VarL))
; 	Debug ""
; 	
; 	Debug "Integer:"
; 	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
; 		Define VarI.i = $E530A6F0
; 		
; 		Debug "> 32 bits"
; 		Debug "0x"+RSet(Hex(VarI, #PB_Long), 8, "0")+" -> 0x"+RSet(Hex(EndianSwapL(VarI), #PB_Long), 8, "0")
; 		Debug Str(VarI)+" -> "+Str(EndianSwapL(VarI))
; 		Debug "> 64 bits"
; 		Debug "Use a 64 bits compiler or EndianSwapQ(...)"
; 		
; 	CompilerElseIf #PB_Compiler_Processor = #PB_Processor_x64
; 		Define VarI.i = $D34A096BD100F590
; 		
; 		Debug "> 32 bits"
; 		Debug "Use a 32 bits compiler or EndianSwapL(...)"
; 		Debug "> 64 bits"
; 		Debug "0x"+RSet(Hex(VarI, #PB_Quad), 16, "0")+" -> 0x"+RSet(Hex(EndianSwapI(VarI), #PB_Quad), 16, "0")
; 		Debug Str(VarI)+" -> "+Str(EndianSwapI(VarI))
; 		
; 	CompilerElse
; 		CompilerWarning "> Unsupported CPU Architecture for both x86 and x64."
; 	CompilerEndIf
; 	Debug ""
; 		
; 	Debug "Quad:"
; 	Define VarQ.q = $D34A096BD100F590
; 	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
; 		
; 		Debug "> 32 bits method (x86 fallback)"
; 		Debug "0x"+RSet(Hex(VarQ, #PB_Quad), 16, "0")+" -> 0x"+RSet(Hex(EndianSwapQ(VarQ), #PB_Quad), 16, "0")
; 		Debug Str(VarQ)+" -> "+Str(EndianSwapQ(VarQ))
; 		Debug "> 64 bits method (???)"
; 		Debug "Use a 64 bits compiler"
; 		
; 	CompilerElseIf #PB_Compiler_Processor = #PB_Processor_x64
; 		
; 		Debug "> 32 bits method (x86 fallback)"
; 		Debug "Use a 32 bits compiler"
; 		Debug "> 64 bits method (???)"
; 		Debug "0x"+RSet(Hex(VarQ, #PB_Quad), 16, "0")+" -> 0x"+RSet(Hex(EndianSwapQ(VarQ), #PB_Quad), 16, "0")
; 		Debug Str(VarQ)+" -> "+Str(EndianSwapQ(VarQ))
; 		
; 	CompilerElse
; 		CompilerWarning "> Unsupported CPU Architecture for both x86 and x64."
; 	CompilerEndIf

