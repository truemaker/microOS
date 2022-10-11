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
	nasm -f elf kernel/kernel_entry.asm -o objs/kernel_entry.o
	/usr/local/i386elfgcc/bin/i386-elf-g++ -ffreestanding -m32 -g -c kernel/kernel.cpp -o objs/kernel.o -mno-red-zone -O1 -fpermissive -fno-pic -fno-builtin
	/usr/local/i386elfgcc/bin/i386-elf-ld -m elf_i386 -o bins/kernel.bin -Ttext 0x00007e00 objs/kernel_entry.o objs/kernel.o --oformat binary
	cat bins/boot.bin bins/kernel.bin bins/zeroes.bin > imgs/OS.img

run:
	qemu-system-i386 imgs/OS.img -m 128M -soundhw pcspk