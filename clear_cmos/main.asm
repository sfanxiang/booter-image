org 0x8000

stack:
main:
	mov dl, 0xff
	mov cx, 0xff
l:
	call write_cmos
	loop l

	jmp 0xffff:0

write_cmos:
	; cl: port, dl: data
	mov al, cl
	out 0x70, al
	mov al, dl
	out 0x71, al
	ret