org 0
%define SEG_MAIN_CODE16 0x800
%define REAL_SIZE 0xa00
%define PROTECTED_SIZE 0x80000
%define UNCOMPRESSED_SIZE 0x1000000
%define RAMDISK_SIZE 0xe123f	; accurate
%define RAMDISK_ADDR 0xf1e000

bits 16
main:
	jmp 0x800:start

images_base:	dd 0x100000

%include "func.inc"
%include "optionrom.inc"

%define SEG_CODE16 SEG_MAIN_CODE16
%define LINEAR_ADDR(x) ((x)+SEG_CODE16*0x10)

align 1
bits 16

start:
	cli
	
	mov ax, 0
	mov ss, ax
	mov sp, 0x7c00

	; do this first
	init_vgabios
	cli
	
	; get memory size
	mov al, 0x17
	out 0x70, al
	in al, 0x71
	mov [cs:mem_size], al
	mov al, 0x18
	out 0x70, al
	in al, 0x71
	mov [cs:mem_size+1], al

	; copy interrupt code
	mov ax, SEG_CODE16
	mov ds, ax
	mov si, int_handler
	mov ax, SEG_INT_CODE16
	mov es, ax
	mov di, 0
	mov cx, int_handler_end-int_handler
	cld
	rep movsb
	
	; install empty interrupt handlers that only return error
	mov ax, 0
	mov es, ax
	mov di, 0x11*4
l:
	mov word [es:di], empty_int_handler-int_handler
	mov word [es:di+2], SEG_INT_CODE16
	add di, 4
	cmp di, 0x30*4
	jbe l

	mov ax, 3
	int 0x10

	cli
	
	mov ax, 0
	mov ss, ax
	mov sp, 0x7c00
	mov ax, 0
	mov es, ax
	
	; install int 0x15
	mov ax, 0
	mov es, ax
	mov word [es:0x15*4], int0x15_handler-int_handler
	mov word [es:0x15*4+2], SEG_INT_CODE16
	
	mov ax, SEG_CODE16
	mov es, ax
	mov si, mem_table
	mov ebx, [cs:images_base]
	
	mov ecx, REAL_SIZE
	mov edx, 0x90000
	call memset_0
	
	mov ah, 0xff
	mov ecx, REAL_SIZE/2
	mov dword [cs:mem_src], ebx
	mov dword [cs:mem_dst], 0x90000
	int 0x15
	
	; mov ecx, PROTECTED_SIZE
	; mov edx, 0x10000
	; call memset_0
	
	mov ah, 0xff
	mov ecx, PROTECTED_SIZE/2
	add ebx, REAL_SIZE
	mov dword [cs:mem_src], ebx
	mov dword [cs:mem_dst], 0x10000
	int 0x15
	
	mov ah, 0xff
	mov ecx, (RAMDISK_SIZE+1)/2
	add ebx, PROTECTED_SIZE
	mov dword [cs:mem_src], ebx
	mov dword [cs:mem_dst], RAMDISK_ADDR
	int 0x15
	
	; mov ecx, UNCOMPRESSED_SIZE
	; mov edx, 0x100000
	; call memset_0
	
	mov ax, 0x9000
	mov es, ax
	mov si, boot_cmd
	mov di, 0x9800	; cmdline
copy_cmd:
	mov al, [cs:si]
	mov [es:di], al
	inc si
	inc di
	test al, al
	jnz copy_cmd

	jmp SEG_INT_CODE16:enter_kernel-int_handler

boot_cmd:	db "root=/dev/ram0", 0

mem_table:
	times 16 db 0
	dw 0xffff
mem_src:	times 3 db 0
	times 5 db 0
mem_dst:	times 3 db 0
	times 19 db 0
