GLOBAL PB_NibbleSwap
GLOBAL PB_EndianSwap2

SEGMENT .text USE32 CLASS=CODE

PB_NibbleSwap:
	ROL al, 4
	RET

PB_EndianSwap2:
	XCHG al,ah
	RET

SEGMENT .data CLASS=DATA
