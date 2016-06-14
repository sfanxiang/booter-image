org 0

stack:
main:
	jmp 0x800:start

%define rom_seg 0x2000

drive:	db 0x80
rom_size:	dw 16384

%include "optionrom.inc"

start:
	cli
	mov ax, cs
	mov ss, ax
	mov sp, stack

	init_vgabios
	cli
	
	mov ax, 3
	int 0x10

	mov bh, 0
	mov al, 'b'
	mov cx, 1
	mov ah, 0xa
	int 0x10

	mov ax, 0
	mov es, ax
	mov di, 0x11*4
	mov ax, cs
l:
	mov word [es:di], empty_int_handler
	mov [es:di+2], ax
	add di, 4
	cmp di, 0x21*4
	jbe l

	mov si, cs
	mov ds, si
	mov si, ahci_optionrom
	mov di, rom_seg
	mov es, di
	mov di, 0
	mov cx, [cs:rom_size]
	cld
	rep movsb
	
	call rom_seg:OPTION_ROM_ENTRY

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

empty_int_handler:
	mov ah, 1
	iret

ahci_optionrom:
	; AHCI option ROM here
