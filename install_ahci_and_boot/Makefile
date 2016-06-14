booter_image: main ahci_optionrom
	cat $^ > booter_image

main: main.asm optionrom.inc
	nasm -o $@ $<
