org 0x8000

stack:
main:
	mov al, 0xf
	out 0x70, al
	mov al, 4
	out 0x71, al

	jmp 0xffff:0
