booter_image: main
	cp main booter_image

main: main.asm vga.inc
	nasm -o $@ $<
