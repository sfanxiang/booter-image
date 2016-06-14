org 0x8000

bits 16
stack:
main:
	jmp start

pci_id_list:
	; all devices
	; dw 0xffff, 0xffff
	; 10 Gigabit & 40 Gigabit Converged Network Adapters and Server Adapters
	dw 0x8086, 0x10f1
	dw 0x8086, 0x10c8
	dw 0x8086, 0x150b
	dw 0x8086, 0x10ec
	dw 0x8086, 0x10f4
	dw 0x8086, 0x10c7
	dw 0x8086, 0x10c6
	; Gigabit Server Adapters
	dw 0x8086, 0x10c9
	dw 0x8086, 0x10e6
	dw 0x8086, 0x10e8
	dw 0x8086, 0x1526
	; Desktop Adapters & Network Connections
	dw 0x8086, 0x10d3
	; test
	; dw 0x8086, 0x1237
	; dw 0x8086, 0x7000
	; dw 0x8086, 0x7010
	; dw 0x8086, 0x7020
	; end
	dw 0, 0

%include "vga.inc"
%include "pci.inc"

start:
	cli
	
	mov ax, 0
	mov ss, ax
	mov sp, stack
	
	init_vgabios
	mov ax, 3
	int 0x10
	
	mov ax, 0xb800
	mov es, ax
	
	mov ecx, 0
	mov di, 0

check_all_devices:
	push ecx
	mov dx, cx
	shr dx, 13
	mov dh, 0
	and cx, 0x1fff
	call pci_read
	
	mov ecx, eax
	call search_id_list
	
	test al, al
	jz .skip_device

	pop ecx
	push ecx
	mov esi, 0
	mov dx, cx
	shr dx, 13
	mov dh, 4
	and cx, 0x1fff
	
	mov byte [es:di], '*'
	add di, 2
	
	call pci_write

.skip_device:
	pop ecx
	inc ecx
	cmp ecx, 0x10000
	jb check_all_devices

return:
	mov ecx, 0xffffffff
delay:
	dec ecx
	cmp ecx, 0
	jne delay
	jmp 0xffff:0

search_id_list:
	; ecx: id
	; al = found
	
	mov eax, pci_id_list
.search_for:
	cmp dword [cs:eax], 0
	je .search_fail
	cmp dword [cs:eax], 0xffffffff
	je .search_found
	cmp dword [cs:eax], ecx
	je .search_found
	add eax, 4
	jmp .search_for
	
.search_fail:
	mov al, 0
	ret
.search_found:
	mov al, 1
	ret
