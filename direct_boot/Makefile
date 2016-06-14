booter_image: main ivt
	cat main ivt > booter_image

main: main.asm vga.inc
	nasm -o $@ $<
