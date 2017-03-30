SRCS = arbre.c inter.c
OBJS = $(SRCS:.c=.o)

LEX_IN  =   $(wildcard *.l)
YACC_IN =   $(wildcard *.y)
LEX_OUT     =   $(patsubst %.l, %, $(LEX_IN))
YACC_OUT    =   $(patsubst %.y, %, $(YACC_IN))

CC      =   gcc
RM      =   rm -f
LEX     =   flex
YACC    =   bison -d

CFLAGS      =
LDFLAGS     =

.PHONY      :   all flexalone yaccalone clean re
.PRECIOUS   :   %.tab.c %.tab.h %.tab.o %.yy.c %.yy.o %.o
.SUFFIXES   :   .c .h .l .o .tab.c .tab.h .tab.o .y .yy.c .yy.o

%                       :   %.tab.o %.yy.o $(OBJS)
	 		$(CC) -o $@ $*.tab.o $*.yy.o $(OBJS)

%.tab.c %.tab.h %.yy.c  :   %.y %.l
			$(YACC) -o $*.tab.c $*.y
			$(LEX) -o $*.yy.c $*.l

%       :   %.yy.o
	$(CC) -o $@ -DFLEXALONE $*.yy.o -lfl

%.yy.o  :   %.yy.c
	$(CC) -c -o $@ $*.yy.c

%.yy.c  :   %.l
	$(LEX) -o $@ $*.l

%               :   %.tab.o
		$(CC) -o $@ $*.tab.o

%.tab.o         :   %.tab.c %.tab.h
		$(CC) -c -o $@ $*.tab.c

%.tab.c %.tab.h :   %.y
		$(YACC) -o $@ $*.y

all         :   yacctargets flextargets

yacctargets :   $(YACC_IN:%.y=%)

flextargets :   $(LEX_IN:%.l=%)

clean       :
	$(RM) *~
	$(RM) *.tab.c *.tab.h *.tab.o
	$(RM) *.yy.c *.yy.o
	$(RM) $(OBJS)
	$(RM) $(LEX_OUT)
	$(RM) $(YACC_OUT)
	$(RM) .#bilquad.h	

re          :   clean all
