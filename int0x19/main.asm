org 0

stack:
main:
	jmp 0x800:start

init_vga:	db 1

%include "vga.inc"

start:
	cli
	mov ax, cs
	mov ss, ax
	mov sp, stack

	cmp byte [cs:init_vga], 0
	je skip_vga
	init_vgabios

	mov ax, 3
	int 0x10

	mov bh, 0
	mov al, 'b'
	mov cx, 1
	mov ah, 0xa
	int 0x10

skip_vga:
	mov ax, 0
	mov es, ax
	mov dword [es:4*0x19], 0xf000e6f2
	int 0x19
