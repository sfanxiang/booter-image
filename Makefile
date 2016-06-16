booter_image: main
	cp main booter_image

main: main.asm func.inc optionrom.inc
	nasm -o $@ $<
