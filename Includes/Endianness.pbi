;{- Code Header
; ==- Basic Info -================================
;     Name: Endianness.pbi
;  Version: 2.0.0-indev
;   Author: Herwin Bozet (NibblePoker)
;
; ==- Compatibility -=============================
;  Tested compiler version:
;    * PureBasic 5.73 LTS (x86/x64)
;    * //PureBasic 6.21 - ASM Backend (x86/x64)
;    * //PureBasic 6.21 - C Backend (x86/x64/arm64)
;    * //PureBasic 6.40 - ASM Backend (x86/x64)
;    * //PureBasic 6.40 - C Backend (x86/x64/arm64)
; 
; ==- Links & License -===========================
;  License: CC0 1.0 Universal (Public Domain)
;   GitHub: https://github.com/aziascreations/PB-Endianness
;}


; ------------------------------------------------------------------------------
;- Remarks

; A second procedure was specially made for and .u (and .a) variables to avoid any potential problem that could happen
;  if you use "EndianSwapW" when declaring an implicitely typed variable.
; The compiler might think that you want to use a "Word" and not an "Unsigned Word, aka. Unicode", even if
;  the value returned be these procedure is exactly the same bit-wise.
; If your variable is explicitely typed, it shouldn't be a problem, but you should still use the correct one.

; Each of the procedures in this include uses the RAX register and its parts (EAX, AX, AL, AH).
; And in the case of "EndianSwapQ(...)" on x86, the EDX register is used.
; Keep this in mind if you call them while using ASM !

; ROL r8/m8 -> Similar to a shift, but the bits loop
; https://www.aldeid.com/wiki/X86-assembly/Instructions/rol

; XCHG r8, r8 -> Where both r8 are parts of r16 -> (ax = al+ah)
; See: https://c9x.me/x86/html/file_module_x86_id_328.html

; BSWAP r32/r64 -> Does the operation on the register itself.
; See: https://www.felixcloutier.com/x86/bswap



; ------------------------------------------------------------------------------
;- Changelog

; * 2.0.0 - ??/??/2026
;   * Revamped include and tests
;   * Added support for ARM64
;   * Added support for C-Backend
; 
; * 1.0.2 - 11/07/2019
;   * Improved EndianSwapQ(...)
;   * Fixed the indentation
; 
; * 1.0.1 - 11/07/2019
;   * Initial Release



; ------------------------------------------------------------------------------
;- Compiler Directives

CompilerIf #PB_Compiler_IsMainFile
	EnableExplicit
CompilerEndIf



; ------------------------------------------------------------------------------
;- Compiler Abstraction

CompilerIf #PB_Compiler_Version >= 600
	#_NibblePoker_Endianness_IsBackend_Asm = Bool(#PB_Compiler_Backend = #PB_Backend_Asm)
	#_NibblePoker_Endianness_IsBackend_C   = Bool(#PB_Compiler_Backend = #PB_Backend_C) 
	#_NibblePoker_Endianness_IsArch_x86    = Bool(#PB_Compiler_Processor = #PB_Processor_x86)
	#_NibblePoker_Endianness_IsArch_x64    = Bool(#PB_Compiler_Processor = #PB_Processor_x64)
	;#_NibblePoker_Endianness_IsArch_Arm32  = Bool(#PB_Compiler_Processor = #PB_Processor_Arm32)
	#_NibblePoker_Endianness_IsArch_Arm64  = Bool(#PB_Compiler_Processor = #PB_Processor_Arm64)
CompilerElse
	#_NibblePoker_Endianness_IsBackend_Asm = #True
	#_NibblePoker_Endianness_IsBackend_C   = #False
	#_NibblePoker_Endianness_IsArch_x86    = Bool(#PB_Compiler_Processor = #PB_Processor_x86)
	#_NibblePoker_Endianness_IsArch_x64    = Bool(#PB_Compiler_Processor = #PB_Processor_x64)
	;#_NibblePoker_Endianness_IsArch_Arm32  = #False
	#_NibblePoker_Endianness_IsArch_Arm64  = #False
CompilerEndIf



; ------------------------------------------------------------------------------
;- Procedures

;-> Via Pointers

Procedure NibbleSwapPtr8(*Address)
	CompilerIf #_NibblePoker_Endianness_IsBackend_Asm
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86
			EnableASM
				MOV eax, *Address
				ROL byte [eax], 4
			DisableASM
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_x64
			EnableASM
				MOV rax, *Address   ; rax = the pointer value
				ROL byte [rax], 4	; rotate the byte AT that address by 4 bits -> swaps its two nibbles
			DisableASM
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElseIf #_NibblePoker_Endianness_IsBackend_C
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64
			CompilerWarning "Untested !"
			!__asm__ volatile ("rolb $4, (%0)" :: "r" (v_address) : "memory");
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_Arm64
			CompilerWarning "Untested !"
			!__asm__ volatile (
			!	"ldrb  %w0, [%3]\n\t"
			!	"ubfiz %w1, %w0, #4, #4\n\t"
			!	"ubfx  %w2, %w0, #4, #4\n\t"
			!	"orr   %w0, %w1, %w2\n\t"
			!	"strb  %w0, [%3]"
			!	: "=&r"(v_value), "=&r"(v_temp1), "=&r"(v_temp2)
			!	: "r"(v_address)
			!	: "memory"
			!);
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElse
		CompilerError "Unsupported compiler backend !"
		
	CompilerEndIf
EndProcedure

Procedure EndianSwapPtr16(*Address)
	CompilerIf #_NibblePoker_Endianness_IsBackend_Asm
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86
			EnableASM
				MOV eax, *Address
				MOV cx, [eax]
				XCHG cl, ch
				MOV [eax], cx
			DisableASM
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_x64
			EnableASM
				MOV rax, *Address   ; rax = the pointer value
				MOV cx, [rax]		; cx  = the word AT that address
				XCHG cl, ch			; swap its two bytes
				MOV [rax], cx		; write the swapped word back
			DisableASM
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElseIf #_NibblePoker_Endianness_IsBackend_C
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_x64
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_Arm64
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElse
		CompilerError "Unsupported compiler backend !"
		
	CompilerEndIf
EndProcedure

Procedure EndianSwapPtr32(*Address)
	CompilerIf #_NibblePoker_Endianness_IsBackend_Asm
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86
			EnableASM
				MOV eax, *Address
				MOV ecx, [eax]
				BSWAP ecx
				MOV [eax], ecx
			DisableASM
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_x64
			EnableASM
				MOV rax, *Address   ; rax = the pointer value
				MOV ecx, [rax]		; ecx = the long AT that address
				BSWAP ecx			; swap its four bytes
				MOV [rax], ecx		; write the swapped long back
			DisableASM
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElseIf #_NibblePoker_Endianness_IsBackend_C
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_x64
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_Arm64
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElse
		CompilerError "Unsupported compiler backend !"
		
	CompilerEndIf
EndProcedure

Procedure EndianSwapPtr64(*Address)
	CompilerIf #_NibblePoker_Endianness_IsBackend_Asm
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86
			EnableASM
				MOV eax, *Address   ; eax = the pointer value
				MOV ecx, [eax]		; ecx = the lower dword AT that address
				MOV edx, [eax+4]	; edx = the upper dword AT that address
				
				BSWAP ecx
				BSWAP edx
				
				MOV [eax], edx      ; write the swapped dwords back, in reversed order
				MOV [eax+4], ecx
			DisableASM
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_x64
			EnableASM
				MOV rax, *Address   ; rax = the pointer value
				MOV rcx, [rax]		; rcx = the quad AT that address
				BSWAP rcx			; swap its eight bytes
				MOV [rax], rcx		; write the swapped quad back
			DisableASM
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElseIf #_NibblePoker_Endianness_IsBackend_C
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_x64
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_Arm64
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElse
		CompilerError "Unsupported compiler backend !"
		
	CompilerEndIf
EndProcedure


;-> Direct Values

;-> > 1 Byte (B/A) (Nibble inverters)

Procedure.b NibbleSwapB(Number.b)
	CompilerIf #_NibblePoker_Endianness_IsBackend_Asm
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64
			EnableASM
				ROL Number, 4
			DisableASM
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElseIf #_NibblePoker_Endianness_IsBackend_C
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64
			CompilerWarning "Untested !"
			!__asm__ volatile ("rolb $4, %0" : "+q" (v_number));
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_Arm64
			CompilerWarning "Untested !"
			!__asm__ volatile (
			!	"ubfiz %w1, %w0, #4, #4\n\t"
			!	"ubfx  %w2, %w0, #4, #4\n\t"
			!	"orr   %w0, %w1, %w2"
			!	: "+r"(v_number), "=&r"(v_temp1), "=&r"(v_temp2)
			!);
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElse
		CompilerError "Unsupported compiler backend !"
		
	CompilerEndIf
	
	ProcedureReturn Number
EndProcedure

Procedure.a NibbleSwapA(Number.a)
	CompilerIf #_NibblePoker_Endianness_IsBackend_Asm
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64
			EnableASM
				ROL Number, 4
			DisableASM
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElseIf #_NibblePoker_Endianness_IsBackend_C
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64
			CompilerWarning "Untested !"
			!__asm__ volatile ("rolb $4, %0" : "+q" (v_number));
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_Arm64
			CompilerWarning "Untested !"
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElse
		CompilerError "Unsupported compiler backend !"
		
	CompilerEndIf
	
	ProcedureReturn Number
EndProcedure


;-> > 2 Bytes (W/U)

Procedure.w EndianSwapW(Number.w)
	CompilerIf #_NibblePoker_Endianness_IsBackend_Asm
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64
			EnableASM
				MOV ax,Number
				XCHG al,ah
				MOV Number,ax
			DisableASM
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElseIf #_NibblePoker_Endianness_IsBackend_C
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_Arm64
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElse
		CompilerError "Unsupported compiler backend !"
		
	CompilerEndIf
	
	ProcedureReturn Number
EndProcedure

Procedure.u EndianSwapU(Number.u)
	CompilerIf #_NibblePoker_Endianness_IsBackend_Asm
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64
			EnableASM
				MOV ax,Number
				XCHG al,ah
				MOV Number,ax
			DisableASM
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElseIf #_NibblePoker_Endianness_IsBackend_C
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_Arm64
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElse
		CompilerError "Unsupported compiler backend !"
		
	CompilerEndIf
	
	ProcedureReturn Number
EndProcedure


;-> 4 Bytes (L)

; Original code for "EndianSwapL(...)" by djes on the PureBasic forum.
; See: https://www.purebasic.fr/english/viewtopic.php?f=19&t=17427
; 
; Improvement(s) made:
; * EAX Register returned directly -> MAY save a couple of cycles if the compiler doesn't optimize it already.
;                                     It does, it goes from ~687-690ms/1M calls to ~635ms/1M calls.

Procedure.l EndianSwapL(Number.l)
	CompilerIf #_NibblePoker_Endianness_IsBackend_Asm
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64
			EnableASM
				MOV eax,Number
				BSWAP eax
				ProcedureReturn
			DisableASM
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElseIf #_NibblePoker_Endianness_IsBackend_C
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_Arm64
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElse
		CompilerError "Unsupported compiler backend !"
		
	CompilerEndIf
EndProcedure


;-> 4-8 Bytes (I)

; EndianSwapI(Number.i)
; Had to be separated based on the CPU arch because its size varies based on it, and also because BSWAP uses
;  the register size to know what to do.
; And since x64 has 64bit registers while x86 doesn't, they have to be different.

Procedure.i EndianSwapI(Number.i)
	CompilerIf #_NibblePoker_Endianness_IsBackend_Asm
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86
			EnableASM
				MOV eax, Number
				BSWAP eax
				ProcedureReturn
			DisableASM
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_x64
			EnableASM
				MOV rax, Number
				BSWAP rax
				MOV Number, rax
			DisableASM

			ProcedureReturn Number
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElseIf #_NibblePoker_Endianness_IsBackend_C
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_x64
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_Arm64
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElse
		CompilerError "Unsupported compiler backend !"
		
	CompilerEndIf
EndProcedure


;-> 8 Bytes (Q)

; MOVBE could have been used, but the compiler kept giving a syntax error for some reason :/
; See: https://www.felixcloutier.com/x86/movbe
; TODO: Check again since using "!" can fix this issue.
; Same thing with MOVSS and other SSE2 MOV ops with xmm regs.

Procedure.q EndianSwapQ(Number.q)
	CompilerIf #_NibblePoker_Endianness_IsBackend_Asm
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86
			; A version of this procedure that uses xmm registers and SSE2 instructions can be made to suit both
			;   x86 and x64, but the performances would likely take a hit. (~8 instructions with XMM regs.)
			; The stack could have technically been used to leave EDX untouched, but when I used it,
			;   the "ProcedureReturn" kept throwing an "Invalid memory access" error.
			EnableASM
				MOV eax, dword [p.v_Number]
				MOV edx, dword [p.v_Number+4]
				
				BSWAP eax
				BSWAP edx
				
				MOV dword [p.v_Number+4], eax
				MOV dword [p.v_Number], edx
			DisableASM
			
			ProcedureReturn Number
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_x64
			EnableASM
				MOV rdx, Number
				BSWAP rdx
				MOV Number, rdx
			DisableASM
			
			ProcedureReturn Number
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElseIf #_NibblePoker_Endianness_IsBackend_C
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_x64
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_Arm64
			CompilerWarning "Untested !"
			CompilerWarning "Not implemented !"
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElse
		CompilerError "Unsupported compiler backend !"
		
	CompilerEndIf
EndProcedure



; ------------------------------------------------------------------------------
;- Aliases

CompilerIf #_NibblePoker_Endianness_IsArch_x86
	Macro EndianSwapPtr(Pointer) : EndianSwapPtr32(Pointer) : EndMacro
	
CompilerElseIf #_NibblePoker_Endianness_IsArch_x64 Or #_NibblePoker_Endianness_IsArch_Arm64
	Macro EndianSwapPtr(Pointer) : EndianSwapPtr64(Pointer) : EndMacro
	
CompilerElse
	CompilerWarning "Unsupported CPU Architecture in Endianness.pbi for EndianSwapPtr(...) !"
	
CompilerEndIf


Macro NibbleSwapI8(Number) : NibbleSwapB(Number) : EndMacro

Macro NibbleSwapU8(Number) : NibbleSwapA(Number) : EndMacro


Macro EndianSwapI16(Number) : EndianSwapW(Number) : EndMacro

Macro EndianSwapU16(Number) : EndianSwapU(Number) : EndMacro


Macro EndianSwapI32(Number) : EndianSwapL(Number) : EndMacro


Macro EndianSwapI64(Number) : EndianSwapQ(Number) : EndMacro



; ------------------------------------------------------------------------------
;- Macros

; Macro NibbleSwap(Number)
; 	CompilerSelect TypeOf(Number)
; 		CompilerCase #PB_Ascii
; 			NibbleSwapA(Number)
; 			
; 		CompilerCase #PB_Byte
; 			NibbleSwapB(Number)
; 			
; 		CompilerDefault
; 			CompilerError "Unsupported value type given in '+NibbleSwap(Number)' !"
; 			
; 	CompilerEndSelect
; EndMacro

; Macro EndianSwap(Number)
; 	CompilerSelect TypeOf(Number)
; 		CompilerCase #PB_Word
; 			EndianSwapW(Number)
; 			
; 		CompilerCase #PB_Unicode
; 			EndianSwapU(Number)
; 			
; 		CompilerCase #PB_Long
; 			EndianSwapL(Number)
; 			
; 		CompilerCase #PB_Integer
; 			EndianSwapI(Number)
; 			
; 		CompilerCase #PB_Quad
; 			EndianSwapQ(Number)
; 			
; 		CompilerDefault
; 			CompilerError "Unsupported value type given in '+EndianSwap(Number)' !"
; 			
; 	CompilerEndSelect
; EndMacro
