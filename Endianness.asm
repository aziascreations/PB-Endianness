GLOBAL PB_NibbleSwap
GLOBAL PB_EndianSwap2
GLOBAL PB_EndianSwap4
GLOBAL PB_EndianSwap8

SEGMENT .text USE32 CLASS=CODE

PB_NibbleSwap:
	ROL al, 4
	RET

PB_EndianSwap2:
	XCHG al,ah
	RET

PB_EndianSwap4:
	BSWAP eax
	RET

PB_EndianSwap8:
	BSWAP rax
	RET

SEGMENT .data CLASS=DATA
