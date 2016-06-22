org 0
%define SEG_MAIN_CODE16 0x800
%define REAL_SIZE 0x3e00
%define PROTECTED_SIZE (1048576*8)
; %define UNCOMPRESSED_SIZE 0x1000000
; no more ramdisks
%define RAMDISK_SIZE 0	; accurate

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

	mov ax, 0xb800
	mov es, ax
	mov byte [es:0], 'b'

	mov ax, 0
	mov ss, ax
	mov sp, 0x7c00
	
	; install int 0x15
	mov ax, 0
	mov es, ax
	mov word [es:0x15*4], int0x15_handler-int_handler
	mov word [es:0x15*4+2], SEG_INT_CODE16
	
	mov ax, SEG_CODE16
	mov es, ax
	mov si, mem_table
	mov ebx, [cs:images_base]
	
	cmp ebx, 0x1000000+REAL_SIZE+PROTECTED_SIZE+RAMDISK_SIZE+1
	ja skip

	; notify
	mov ax, 0xb800
	mov ds, ax
	mov byte [ds:0], 'm'

	mov ah, 0xff
	mov ecx, (REAL_SIZE+PROTECTED_SIZE+RAMDISK_SIZE+1)/2
	mov [cs:mem_src], ebx
	add ebx, REAL_SIZE+PROTECTED_SIZE+RAMDISK_SIZE+1
	mov [cs:mem_dst], ebx
	mov [cs:images_base], ebx
	int 0x15

skip:
	; mov ecx, REAL_SIZE
	; mov edx, 0x90000
	; call memset_0
	
	mov ah, 0xff
	mov ecx, REAL_SIZE/2
	mov dword [cs:mem_src], ebx
	mov dword [cs:mem_dst], 0x10000
	int 0x15
	
	; mov ecx, PROTECTED_SIZE
	; mov edx, 0x10000
	; call memset_0
	
	mov ah, 0xff
	mov ecx, PROTECTED_SIZE/2
	add ebx, REAL_SIZE
	mov dword [cs:mem_src], ebx
	mov dword [cs:mem_dst], 0x100000
	int 0x15

	add ebx, PROTECTED_SIZE
	
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

	; ; disable PIC; I don't know
	; mov al,0x10
	; out 0x20,al
	; out 0xa0,al
	; mov al,32
	; out 0x21,al
	; out 0xa1,al
	; mov al,4
	; out 0x21,al
	; mov al,2
	; out 0xa1,al
	; mov al,0xff
	; out 0xa1,al
	; out 0x21,al

	; go
	jmp SEG_INT_CODE16:enter_kernel-int_handler

boot_cmd: db 0

mem_table:
	times 16 db 0
	dw 0xffff
mem_src:	times 3 db 0
	times 5 db 0
mem_dst:	times 3 db 0
	times 19 db 0
