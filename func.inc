%ifndef FUNC_INC
%define FUNC_INC

align 1

%define SEG_INT_CODE16 0x60
%define SEG_CODE16 SEG_INT_CODE16
%define SEL_CODE32 (gdt_code32-gdt)
%define SEL_DATA32 (gdt_data32-gdt)
%define SEL_CODE16 (gdt_code16-gdt)
%define SEL_DATA16 (gdt_data16-gdt)

%define OFFSET(x) ((x) - int_handler)
%define LINEAR_ADDR(x) (OFFSET(x) + SEG_CODE16*0x10)

int_handler:
int0x15_handler:
bits 16
	cli
	cmp ah, 0xff	; I changed my mind
	je short handle_0x87
	cmp ah, 0x88
	je near handle_0x88

	push bp
	mov bp, sp
	or word [ss:bp+6], 1
	pop bp
	mov ah, 1
	iret

handle_0x87:
	pusha
	push ds
	push es

	add ecx, ecx	; changed to ecx from cx

	and esi, 0xffff
	xor ebp, ebp
	mov bp, es
	shl ebp, 4
	add ebp, esi

	in al, 0x92
	or al, 2
	out 0x92, al

	lgdt [cs:OFFSET(gdt_ptr)]
	lidt [cs:OFFSET(idt_ptr)]

	mov eax, cr0
	or eax, 1
	mov cr0, eax
	
	jmp dword SEL_CODE32:LINEAR_ADDR(protected)

bits 32
protected:
	mov ax, SEL_DATA32
	mov ds, ax
	mov es, ax

	mov esi, [ds:ebp+0x12]
	; and esi, 0xffffff
	mov edi, [ds:ebp+0x1a]
	; and edi, 0xffffff
	
	cld
	rep movsb

	jmp SEL_CODE16:LINEAR_ADDR(go_real)

bits 16
go_real:
	mov eax, SEL_DATA16
	mov ds, eax
	mov es, eax

	mov eax, cr0
	and eax, 0x7ffffffe
	mov cr0, eax

	jmp SEG_CODE16:OFFSET(return)

bits 16
return:
	lidt [cs:OFFSET(idt_ptr_real)]

	pop es
	pop ds
	popa

	push bp
	mov bp, sp
	and word [ss:bp+6], 0xfffe
	mov ah, 0
	pop bp
	iret

align 8
gdt:
gdt_null:
	dq 0
gdt_code32:
	dq 0x00cf9a000000ffff
gdt_data32:
	dq 0x00cf92000000ffff
gdt_code16:
	dq 0x000f9a000000ffff
gdt_data16:
	dq 0x000f92000000ffff

align 8
gdt_ptr:
	dw $-gdt-1
	dd LINEAR_ADDR(gdt)

align 8
idt_ptr:
	dw 0
	dd 0

align 8
idt_ptr_real:
	dw 0x3ff		; 256 entries, 4b each = 1K
	dd 0

align 8
handle_0x88:
	mov ax, [cs:OFFSET(mem_size)]
	iret
mem_size:	dw 0x4000	; to be initialized


empty_int_handler:
	push bp
	mov bp, sp
	or word [ss:bp+6], 1
	pop bp
	mov ah, 1
	mov al, 0
	iret


; this function is copied with interrupt handlers
enter_kernel:
	in al, 0x92
	or al, 2
	out 0x92, al

	lgdt [cs:OFFSET(gdt_ptr)]
	lidt [cs:OFFSET(idt_ptr)]

	mov eax, cr0
	or eax, 1
	mov cr0, eax
	
	jmp dword SEL_CODE32:LINEAR_ADDR(.protected)

bits 32
.protected:
	mov ax, SEL_DATA32
	mov ds, ax
	mov es, ax
	xor ax, ax
	mov edi, 0x1000
	mov ecx, 0x10000-0x1000
	
	cld
	rep stosb

	jmp SEL_CODE16:LINEAR_ADDR(.go_real)

bits 16
.go_real:
	mov eax, SEL_DATA16
	mov ds, eax
	mov es, eax

	mov eax, cr0
	and eax, 0x7ffffffe
	mov cr0, eax

	jmp SEG_CODE16:OFFSET(.return)

bits 16
.return:
	lidt [cs:OFFSET(idt_ptr_real)]

	mov ax, 0x9000
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov sp, 0x9800
	
	mov word [ds:0x224], 0x9800-0x200	; heap_end_ptr
	or byte [ds:0x211], 0x80	; loadflags
	mov dword [ds:0x228], 0x99800	; cmd_line_ptr
	mov byte [ds:0x210], 1	; type_of_loader
	mov dword [ds:0x218], RAMDISK_ADDR	; ramdisk_image
	mov dword [ds:0x21c], RAMDISK_SIZE	; ramdisk_size

	jmp 0x9020:0

int_handler_end:

memset_0:
	; ecx: size, edx: addr
	pusha
	push ds
	push es
	
	in al, 0x92
	or al, 2
	out 0x92, al

	lgdt [cs:gdt_ptr]
	lidt [cs:idt_ptr]

	mov eax, cr0
	or eax, 1
	mov cr0, eax
	
	jmp dword SEL_CODE32:.protected+SEG_MAIN_CODE16*0x10

bits 32
.protected:
	mov ax, SEL_DATA32
	mov ds, ax
	mov es, ax
	xor ax, ax
	mov edi, edx
	
	cld
	rep stosb

	jmp SEL_CODE16:.go_real+SEG_MAIN_CODE16*0x10

bits 16
.go_real:
	mov eax, SEL_DATA16
	mov ds, eax
	mov es, eax

	mov eax, cr0
	and eax, 0x7ffffffe
	mov cr0, eax

	jmp SEG_MAIN_CODE16:.return

bits 16
.return:
	lidt [cs:idt_ptr_real]
	
	pop es
	pop ds
	popa
	ret

%endif
