%ifndef VGA_INC
%define VGA_INC

%define VGABIOS_SEG 0xc000
%define OPTION_ROM_ENTRY 3

%define init_vgabios call VGABIOS_SEG:OPTION_ROM_ENTRY

%endif
