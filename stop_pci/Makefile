booter_image: main
	cp main booter_image

main: main.asm pci.inc vga.inc
	nasm -o $@ $<
