all : ppascal

lex.yy.c: ppascal.l
	flex ppascal.l
	mv lex.yy.c yy.lex.c

ppascal.tab.c ppascal.tab.h: lex.yy.c
	yacc -b ppascal -d ppascal.y

ppascal: arbre.c interp.c ppascal.tab.c
	gcc -o ppascal ppascal.tab.c arbre.c interp.c

clean:
	rm -f *.tab.*
	rm -f *~
	rm -f ppascal
	rm -f *.o
	rm -f *.yy.*
