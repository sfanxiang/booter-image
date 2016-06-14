org 0

stack:
main:
	jmp 0x800:start

drive:	db 0x80

%include "vga.inc"

%define IVT_SIZE 480

start:
	cli
	mov ax, cs
	mov ss, ax
	mov sp, stack

	init_vgabios
	mov ax, 3
	int 0x10
	
	mov ax, 0
	mov es, ax
	
	mov ebx, [es:4*0x10]
	
	mov ax, cs
	mov ds, ax
	mov si, ivt
	mov di, 0
	
	mov cx, IVT_SIZE
	cld
	rep movsb
	
	mov [es:4*0x10], ebx
	
	mov bh, 0
	mov al, 'b'
	mov cx, 1
	mov ah, 0xa
	int 0x10
	
	mov dl, [cs:drive]	; drive
	mov ah, 0	; function
	int 0x13
	
	mov al, 1	; sectors
	mov ch, 0	; cylinder
	mov cl, 1	; sector
	mov dh, 0	; head
	mov dl, [cs:drive]	; drive
	mov bx, 0x7c0	; addr
	mov es, bx
	mov bx, 0
	mov ah, 2	; function
	int 0x13
	
	push ax
	
	mov bh, 0
	mov al, 'r'
	mov cx, 1
	mov ah, 0xa
	int 0x10
	
	pop ax
	
	test ah, ah
	jnz fail
	
	mov bh, 0
	mov al, 'j'
	mov cx, 1
	mov ah, 0xa
	int 0x10
	
	mov dl, [cs:drive]
	jmp 0:0x7c00

fail:
	mov bh, 0
	mov al, 'f'
	mov cx, 1
	mov ah, 0xa
	int 0x10
	
stop:
	hlt
	jmp stop

ivt:
	; IVT here
