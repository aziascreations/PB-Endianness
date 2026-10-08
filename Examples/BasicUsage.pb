
EnableExplicit

XIncludeFile "../Includes/Endianness.pbi"


Define ValU8.a = %01101001

Debug RSet(Bin(NibbleSwapA(ValU8), #PB_Ascii), 8, "0")
