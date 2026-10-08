;{- Code Header
; ==- Basic Info -================================
;         Name: EndianSwapQ_SSE.pbi
;      Version: 1.0.0 (Experimental)
;       Author: Herwin Bozet
;  Create date: 11 January 2020, 08:33:48
; 
;  Description: An experimental version of "EndianSwapQ" from "Endianness.pbi" that
;                uses the SSE2 instruction set.
; 
; ==- Compatibility -=============================
;  Compiler version: PureBasic 5.70 (x64) (Other versions untested)
;  Operating system: Windows (Other platforms untested)
; 
; ==- Links & License -===========================
;  License: CC0 1.0 Universal (Public Domain)
;   GitHub: https://github.com/aziascreations/PB-Endianness
; 
;}


; ------------------------------------------------------------------------------
;- Compiler Directives

EnableExplicit



; ------------------------------------------------------------------------------
;- Procedure

Procedure.q EndianSwapQSSE(Number.q)
	EnableASM
		; Copy the input into XMM0
		MOVQ xmm0, Number
		
		; Clear the XMM1 register.
		PXOR xmm1, xmm1
		
		; "Interleave" XMM0 and XMM1.
		PUNPCKLBW xmm0, xmm1
		
		; BSWAP each dword
		! PSHUFHW xmm0, xmm0, 00011011b
		! PSHUFLW xmm0, xmm0, 00011011b
		
		; "De-interleave" XMM0
		PACKUSWB xmm0, xmm0
		
		; Swaps each dword.
		! PSHUFD xmm0, xmm0, 10110001b
		
		; Get the result
		MOVQ Number, xmm0
		DisableASM
		
	ProcedureReturn Number
EndProcedure



; ------------------------------------------------------------------------------
;- Tests

CompilerIf #PB_Compiler_IsMainFile
	XIncludeFile "../Includes/Endianness.pbi"
	
	Define i.i, StartTime.q, Temp.q
	
	; Doing 1 M random swaps
	
	StartTime = ElapsedMilliseconds()
	For i=0 To 1000000
		RandomData(@Temp, 8)
		
		EndianSwapQ(Temp)
	Next
	Debug "EndianSwapQ() > "+Str(ElapsedMilliseconds()-StartTime)+"ms"
	
	StartTime = ElapsedMilliseconds()
	For i=0 To 1000000
		RandomData(@Temp, 8)
		
		EndianSwapQSSE(Temp)
	Next
	Debug "EndianSwapQSSE() > "+Str(ElapsedMilliseconds()-StartTime)+"ms"
CompilerEndIf
