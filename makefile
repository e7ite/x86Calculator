make: clean compile
	gcc -no-pie -m32 main.o -o calc.out

compile:
	nasm -g -f elf32 main.asm -o main.o

clean:
	rm -f *.o main
