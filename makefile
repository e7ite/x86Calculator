make: clean compile
	gcc -m32 main.o -o main

compile:
	nasm -g -f elf32 main.asm -o main.o

clean:
	rm -f *.o main
