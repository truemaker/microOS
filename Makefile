all: clean workspace build run
	make clean

clean:
	rm -rf bins
	rm -rf imgs
	rm -rf objs

workspace:
	mkdir bins
	mkdir imgs
	mkdir objs

build:
	nasm -f bin bootloader/boot.asm -o bins/boot.bin
	dd if=/dev/zero of=bins/zeroes.bin bs=512 count=1
	cat bins/boot.bin bins/zeroes.bin > imgs/OS.img

run:
	qemu-system-i386 imgs/OS.img -m 128M -soundhw pcspk