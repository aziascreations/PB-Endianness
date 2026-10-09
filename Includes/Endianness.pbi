;{- Code Header
; ==- Basic Info -================================
;     Name: Endianness.pbi
;  Version: 2.0.0
;   Author: Herwin Bozet (NibblePoker) & djes
;
; ==- Compatibility -=============================
;  Tested compiler versions:
;    * PureBasic 5.73 LTS (x86/x64)
;    * PureBasic 6.21 - ASM Backend (x86/x64)
;    * PureBasic 6.21 - C Backend (x86/x64/arm64)
;    * PureBasic 6.40 - ASM Backend (x86/x64)
;    * PureBasic 6.40 - C Backend (x86/x64)
;    * PureBasic 6.41 - ASM Backend (x86/x64)
;    * PureBasic 6.41 - C Backend (x86/x64/arm64)
; 
; ==- Links & License -===========================
;  License: CC0 1.0 Universal (Public Domain)
;   GitHub: https://github.com/aziascreations/PB-Endianness
;}


; ------------------------------------------------------------------------------
;- Remarks

; Each of the procedures in this include uses the RAX register and its parts (EAX, AX, AL, AH).
; And in the case of "EndianSwapQ(...)" on x86, the EDX register is used.
; Keep this in mind if you call them while using ASM !

; Duplicates exist for the `.a`/`.b` and `.u`/`.w` types to avoid any potential problem that
;  could result from relying on implicitely typed variable.
; The compiler might think that you want to use a "Word" and not an "Unsigned Word, aka. Unicode", even if
;  the value returned be these procedure is exactly the same bit-wise.
; If your variable is explicitely typed, it shouldn't be a problem, but you should still use the correct one.

; ROL r8/m8 -> Similar to a shift, but the bits loop
; https://www.aldeid.com/wiki/X86-assembly/Instructions/rol

; XCHG r8, r8 -> Where both r8 are parts of r16 -> (ax = al+ah)
; See: https://c9x.me/x86/html/file_module_x86_id_328.html

; BSWAP r32/r64 -> Does the operation on the register itself.
; See: https://www.felixcloutier.com/x86/bswap



; ------------------------------------------------------------------------------
;- Changelog

; * 2.0.0 - 09/10/2026
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

; Prevents version conflicts.
CompilerIf Not Defined(Endianness_BypassIncludeCheck, #PB_Constant)
	CompilerIf Defined(_NibblePoker_Endianness_WasIncluded, #PB_Constant)
		CompilerError "The `Endianness.pbi` include was already included somewhere else ! (Double import)"
	CompilerElse
		#_NibblePoker_Endianness_WasIncluded = #True
	CompilerEndIf
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
;- Include Options

; Prefer GCC builtins over custom assembly
CompilerIf Not Defined(Endianness_UseGccBuiltins, #PB_Constant)
	#Endianness_UseGccBuiltins = #True
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
				MOV rax, *Address
				ROL byte [rax], 4
			DisableASM
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElseIf #_NibblePoker_Endianness_IsBackend_C
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64 Or #_NibblePoker_Endianness_IsArch_Arm64
			; Plain C, GCC will optimize it when optimizations are enabled
			!*(unsigned char*)p_address = (*(unsigned char*)p_address << 4) | (*(unsigned char*)p_address >> 4);
			
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
				MOV rax, *Address
				MOV cx, [rax]
				XCHG cl, ch
				MOV [rax], cx
			DisableASM
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
	CompilerElseIf #_NibblePoker_Endianness_IsBackend_C
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64 Or #_NibblePoker_Endianness_IsArch_Arm64
			CompilerIf #Endianness_UseGccBuiltins
				!*(unsigned short*)p_address = __builtin_bswap16(*(unsigned short*)p_address);
			CompilerElse
				; Plain C, GCC will optimize it when optimizations are enabled
				!*(unsigned short*)p_address = (*(unsigned short*)p_address << 8) | (*(unsigned short*)p_address >> 8);
			CompilerEndIf
			
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
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64 Or #_NibblePoker_Endianness_IsArch_Arm64
			CompilerIf #Endianness_UseGccBuiltins
				!*(unsigned int*)p_address = __builtin_bswap32(*(unsigned int*)p_address);
			CompilerElse
				; Plain C, GCC will optimize it when optimizations are enabled
				!{
				!	unsigned int v = *(unsigned int*)p_address;
				!	*(unsigned int*)p_address =
				!		 ((v << 24)               ) |
				!		 ((v <<  8) & 0x00FF0000u) |
				!		 ((v >>  8) & 0x0000FF00u) |
				!		 ((v >> 24)               );
				!}
			CompilerEndIf
			
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
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64 Or #_NibblePoker_Endianness_IsArch_Arm64
			CompilerIf #Endianness_UseGccBuiltins
				!*(unsigned long long*)p_address = __builtin_bswap64(*(unsigned long long*)p_address);
			CompilerElse
				; Plain C, GCC will optimize it when optimizations are enabled
				!{
				!	unsigned long long v = *(unsigned long long*)p_address;
				!	*(unsigned long long*)p_address =
				!		 ((v << 56)                          ) |
				!		 ((v << 40) & 0x00FF000000000000ull) |
				!		 ((v << 24) & 0x0000FF0000000000ull) |
				!		 ((v <<  8) & 0x000000FF00000000ull) |
				!		 ((v >>  8) & 0x00000000FF000000ull) |
				!		 ((v >> 24) & 0x0000000000FF0000ull) |
				!		 ((v >> 40) & 0x000000000000FF00ull) |
				!		 ((v >> 56)                          );
				!}
			CompilerEndIf
			
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
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64 Or #_NibblePoker_Endianness_IsArch_Arm64
			; Plain C, GCC will optimize it when optimizations are enabled
			!v_number = ((unsigned char)v_number << 4) | ((unsigned char)v_number >> 4);
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
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64 Or #_NibblePoker_Endianness_IsArch_Arm64
			; Plain C, GCC will optimize it when optimizations are enabled
			!v_number = ((unsigned char)v_number << 4) | ((unsigned char)v_number >> 4);
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
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64 Or #_NibblePoker_Endianness_IsArch_Arm64
			CompilerIf #Endianness_UseGccBuiltins
				!v_number = __builtin_bswap16(v_number);
			CompilerElse
				; Plain C, GCC will optimize it when optimizations are enabled
				!{
				!	unsigned short v = v_number;
				!	v_number = (v << 8) | (v >> 8);
				!}
			CompilerEndIf
			
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
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64 Or #_NibblePoker_Endianness_IsArch_Arm64
			CompilerIf #Endianness_UseGccBuiltins
				!v_number = __builtin_bswap16(v_number);
			CompilerElse
				; Plain C, GCC will optimize it when optimizations are enabled
				!{
				!	unsigned short v = v_number;
				!	v_number = (v << 8) | (v >> 8);
				!}
			CompilerEndIf
			
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
		
		CompilerIf #_NibblePoker_Endianness_IsArch_x86 Or #_NibblePoker_Endianness_IsArch_x64 Or #_NibblePoker_Endianness_IsArch_Arm64
			CompilerIf #Endianness_UseGccBuiltins
				!v_number = __builtin_bswap32(v_number);
			CompilerElse
				; Plain C, GCC will optimize it when optimizations are enabled
				!{
				!	unsigned int v = v_number;
				!	v_number =
				!		((v << 24)              ) |
				!		((v <<  8) & 0x00FF0000u) |
				!		((v >>  8) & 0x0000FF00u) |
				!		((v >> 24)              );
				!}
			CompilerEndIf
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
		ProcedureReturn Number
		
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
			CompilerIf #Endianness_UseGccBuiltins
				!v_number = __builtin_bswap32(v_number);
			CompilerElse
				; Using the pre-optimized ASM since it works well enough to not warrant me breaking it.
				!__asm__ volatile (
				!	"bswapl %0"
				!	: "+r" (v_number)
				!);
			CompilerEndIf
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_x64
			CompilerIf #Endianness_UseGccBuiltins
				!v_number = __builtin_bswap64(v_number);
			CompilerElse
				; Using the pre-optimized ASM since it works well enough to not warrant me breaking it.
				!__asm__ volatile (
				!	"bswapq %0"
				!	: "+r" (v_number)
				!);
			CompilerEndIf
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_Arm64
			CompilerIf #Endianness_UseGccBuiltins
				!v_number = __builtin_bswap64(v_number);
			CompilerElse
				; Plain C, GCC will optimize it when optimizations are enabled
				!{
				!	unsigned long long v = v_number;
				!	v_number =
				!		((v << 56)                        ) |
				!		((v << 40) & 0x00FF000000000000ull) |
				!		((v << 24) & 0x0000FF0000000000ull) |
				!		((v <<  8) & 0x000000FF00000000ull) |
				!		((v >>  8) & 0x00000000FF000000ull) |
				!		((v >> 24) & 0x0000000000FF0000ull) |
				!		((v >> 40) & 0x000000000000FF00ull) |
				!		((v >> 56)                        );
				!}
			CompilerEndIf
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
		ProcedureReturn Number
		
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
			CompilerIf #Endianness_UseGccBuiltins
				!v_number = __builtin_bswap64(v_number);
			CompilerElse
				; Using the pre-optimized ASM since it works well enough to not warrant me breaking it.
				!__asm__ volatile (
				!	"bswapl %%eax;"
				!	"bswapl %%edx;"
				!	"xchgl  %%eax, %%edx"
				!	: "+A" (v_number)
				!);
			CompilerEndIf
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_x64
			CompilerIf #Endianness_UseGccBuiltins
				!v_number = __builtin_bswap64(v_number);
			CompilerElse
				; Using the pre-optimized ASM since it works well enough to not warrant me breaking it.
				!__asm__ volatile (
				!	"bswapq %0"
				!	: "+r" (v_number)
				!);
			CompilerEndIf
			
		CompilerElseIf #_NibblePoker_Endianness_IsArch_Arm64
			CompilerIf #Endianness_UseGccBuiltins
				!v_number = __builtin_bswap64(v_number);
			CompilerElse
				; Plain C, GCC will optimize it when optimizations are enabled
				!{
				!	unsigned long long v = v_number;
				!	v_number =
				!		((v << 56)                        ) |
				!		((v << 40) & 0x00FF000000000000ull) |
				!		((v << 24) & 0x0000FF0000000000ull) |
				!		((v <<  8) & 0x000000FF00000000ull) |
				!		((v >>  8) & 0x00000000FF000000ull) |
				!		((v >> 24) & 0x0000000000FF0000ull) |
				!		((v >> 40) & 0x000000000000FF00ull) |
				!		((v >> 56)                        );
				!}
			CompilerEndIf
			
		CompilerElse
			CompilerError "Unsupported CPU Architecture !"
			
		CompilerEndIf
		
		ProcedureReturn Number
		
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
