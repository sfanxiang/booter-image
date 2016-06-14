%ifndef PCI_INC
%define PCI_INC

pci_read:
	; cl: bus, ch: slot, dl: func, dh: reg
	; eax: data read
	
	; C version:
	; outl(0xcf8,(((u32)(spec->bus)<<16)|((u32)(spec->slot)<<11)|
	; 	((u32)(spec->func)<<8)|((u32)(reg&0xfc))|
	; 	((u32)0x80000000)));
	; return inl(0xcfc);
	
	push ebx 

	mov eax, 0
	movzx ebx, cl
	shl ebx, 16
	or eax, ebx
	movzx ebx, ch
	shl ebx, 11
	or eax, ebx
	movzx ebx, dl
	shl ebx, 8
	or eax, ebx
	movzx ebx, dh
	and ebx, 0xfc
	or eax, ebx
	or eax, 0x80000000
	
	mov dx, 0xcf8
	out dx, eax
	mov dx, 0xcfc 
	in eax, dx
	
	pop ebx

	ret


pci_write:
	; cl: bus, ch: slot, dl: func, dh: reg, esi: data
	;
	
	; C version:
	; outl(0xcf8,(((u32)(spec->bus)<<16)|((u32)(spec->slot)<<11)|
	; 	((u32)(spec->func)<<8)|((u32)(reg&0xfc))|
	; 	((u32)0x80000000)));
	; outl(0xcfc, ebx));
	
	push ebx

	mov eax, 0
	movzx ebx, cl
	shl ebx, 16
	or eax, ebx
	movzx ebx, ch
	shl ebx, 11
	or eax, ebx
	movzx ebx, dl
	shl ebx, 8
	or eax, ebx
	movzx ebx, dh
	and ebx, 0xfc
	or eax, ebx
	or eax, 0x80000000
	
	mov dx, 0xcf8
	out dx, eax
	mov eax, esi
	mov dx, 0xcfc
	out dx, eax
	
	pop ebx
	
	ret

%endif
