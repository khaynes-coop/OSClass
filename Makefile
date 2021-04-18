# Simple Makefile

CC=/usr/bin/cc

all:  bison-config flex-config nutshell

bison-config:
	bison -d tokensBison.y

flex-config:
	flex lexer.l

nutshell: 
	$(CC) main.c tokensBison.tab.c lex.yy.c -o main.o -lfl

clean:
	rm tokensBison.tab.c tokensBison.tab.h lex.yy.c