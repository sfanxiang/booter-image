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
	
	mov ax, 0
	mov ds, ax
	
	mov ax, cs
	mov word [ds:1*4], int1_handler
	mov [ds:1*4+2], ax
	mov word [ds:0x19*4], int0x19_handler
	mov [ds:0x19*4+2], ax

	pushf
	mov bp, sp
	or word [ss:bp], 0x100
	popf

	jmp 0xffff:0
	
int1_enable:	db 1
int0x19_changes_count:	db 1

int1_handler:
	pusha
	push ds
	push es

	mov ax, 0
	mov ds, ax
	
	cmp word [ds:0x19*4], int0x19_handler
	je install_handlers

	dec byte [cs:int0x19_changes_count]
	cmp byte [cs:int0x19_changes_count], 0
	jne install_handlers
	
	mov byte [cs:int1_enable], 0

install_handlers:
	mov ax, cs
	mov word [ds:1*4], int1_handler
	mov [ds:1*4+2], ax
	mov word [ds:0x19*4], int0x19_handler
	mov [ds:0x19*4+2], ax

	mov bp, sp
	mov bp, [ss:bp+12]
	cmp byte [cs:int1_enable], 0
	jne set_tf

clear_tf:
	and word [ss:bp],0xfeff
	jmp int1_ret

set_tf:
	or word [ss:bp], 0x100

int1_ret:
	pop es
	pop ds
	popa
	iret

int0x19_handler:
	mov byte [cs:int1_enable], 0
	jmp $

