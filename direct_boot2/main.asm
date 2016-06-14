org 0

stack:
main:
	jmp 0x800:start

drive:	db 0x80

%include "vga.inc"

start:
	cli
	mov ax, cs
	mov ss, ax
	mov sp, stack

	init_vgabios
	mov ax, 3
	int 0x10

	mov bh, 0
	mov al, 'b'
	mov cx, 1
	mov ah, 0xa
	int 0x10
	
	mov dl, [cs:drive]

	jmp 0:0x7c00
