all : ppascal

lex.yy.c: ppascal.l
	flex ppascal.l
	cp lex.yy.c yy.lex.c

ppascal.tab.c ppascal.tab.h: lex.yy.c
	yacc -r state -b ppascal -d ppascal.y

ppascal: arbre.c interp.c anasem.c ppascal.tab.c
	gcc -g -o ppascal ppascal.tab.c anasem.c arbre.c interp.c

clean:
	rm -f *.tab.*
	rm -f *~
	rm -f ppascal
	rm -f *.o
	rm -f *.yy.*
	rm -f yy.lex.c
	rm -f lex.yy.c
