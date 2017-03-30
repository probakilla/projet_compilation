%{
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "arbre.h"
#include "interp.h"

/* ------------------VARIABLES GLOBALES -------------------------*/
  NOE syntree;          /* commande  globale                     */
  BILENVTY benvty;      /* environnement global                  */
  int ligcour=1;        /* ligne  courante                       */
  type tycour;          /* type courant                          */
  ENVTY vtycour;        /* var typee courante                    */
/* -------------------------------- -----------------------------*/

%}
%start MP
%union{NOE NO; type TYP; BILENVTY LARGT;}

%type <NO>     LD MP C E Et
%type <TYP>    TP
%type <LARGT>  Argt L_vart L_vartnn L_args L_argsnn L_argt L_argtnn      
			
%token <NO>    Pl Mo Mu Or Lt Eq And Not I V true false NewAr Se Af Sk If Th El Wh Do Dep Def NPro NFon Var Ind
%token <TYP>   T_boo T_int T_ar T_err T_bot T_com
%%

MP      :	L_vart LD C {benvty = $1; syntree = $2; YYACCEPT;}
		
E       :	E Pl E      {$$ = Nalloc();
                             $$->codop = Pl;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"+");}
	| 	E Mo E      {$$ = Nalloc();
                             $$->codop = Mo;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"-");}
	| 	E Mu E      {$$ = Nalloc();
                             $$->codop = Mu;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"*");}
	| 	E Or E      {$$ = Nalloc();
                             $$->codop = Or;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"Or");}
	| 	E Lt E      {$$ = Nalloc();
                             $$->codop = Lt;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"Lt");}
	| 	E Eq E      {$$ = Nalloc();
                             $$->codop = Eq;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"Eq");}
	| 	E And E     {$$ = Nalloc();
                             $$->codop = And;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"And");}
	| 	Not E       {$$ = Nalloc();
                             $$->codop = Not;
                             $$->FG = $2;
                             $$->FD = NULL;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"Not");}
	|   '('	E ')'       {$$ = $2;}
	| 	I           {$$ = $1;}
	| 	V           {$$ = $1;}
	| 	true        {$$ = $1;}
	| 	false       {$$ = $1;}
	| 	V '(' L_args ')'
	| 	NewAr TP '[' E ']'   {$$ = Nalloc();
                                      $$->codop = NewAr;
                                      type_copy(&($$->typno),$2); /* DIM,TYPEF sont connus   */
				      ($$->typno).DIM++;          /* mise a jour DIM         */
      				      $$->FG=NULL;
				      $$->FD=$4;          /* TAILLE a calculer a partir de E */}
	| 	Et          {$$ = $1;}
        ;

Et      :       V '[' E ']' {$$ = Nalloc();              /* un seul indice                   */
                             $$->codop = Ind;
			     $$->FG = $1;
			     $$->FD = $3;}
	| 	Et '[' E ']' {$$ = Nalloc();             /* plusieurs indices                */
                              $$->codop = Ind;
			      $$->FG = $1;
			      $$->FD = $3;}
        ;
	
C       :	C Se C      {$$ = Nalloc();
                             $$->codop = Se;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"Se");}
	| 	Et Af E     {$$ = Nalloc();
                             $$->codop = Af;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"Af");}
	| 	V Af E      {$$ = Nalloc();
                             $$->codop = Af;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"Af");}
	| 	Sk          {$$ = $1;}
	|   '{' C '}'       {$$ = $2;}
	| 	If E Th C El C    {$$ = Nalloc();
                                   $$->codop = If;
                                   $$->FG = $2;         /* condition     */
                                   $$->FD = Nalloc();   /* alternative   */
			           $$->FD->ETIQ="";     /* champ inutile */
			           $$->FD->FG = $4;     /* branche true  */
			           $$->FD->FD = $6;     /* branche false */
                                   $$->ETIQ = malloc(2);
                                   strcpy($$->ETIQ,"IfThEl");}
	| 	Wh E Do C   {$$ = Nalloc();
                             $$->codop = Wh;
                             $$->FG = $2;         /* condition d'entree dans le while */
                             $$->FD = $4;         /* corps du while                   */
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"Wh");}
	| 	V '(' L_args ')'
        ;

L_args  :       %empty
	| 	L_argsnn    {$$ = $1;}
        ;
		
L_argsnn: 	E           {$$ = $1;}
	| 	E ',' L_argsnn
	;
			
L_argt  :       %empty
	| 	L_argtnn
	;
		
L_argtnn: 	Argt        {$$ = $1;}       
	| 	L_argtnn ',' Argt
	;
			
Argt    :	V ':' TP    {$$ = creer_bilenvty(creer_envty($1->ETIQ,$3,0));}
        ;
		
TP      :	T_boo       {$$ = $1;}
	| 	T_int       {$$ = $1;}
	| 	T_ar TP     {$$ = $2; $$.DIM++;}
        ;
		
L_vart  :       %empty      {$$ = bilenvty_vide();}
	| 	L_vartnn    {$$ = $1;}
        ;
		
L_vartnn: 	Var Argt               {$$ = $2;}
	| 	L_vartnn ',' Var Argt  {$$ = concatty ($1, $4);}
	;
		
D_entp  : 	Dep NPro '(' L_argt ')'
        ;
		
D_entf  : 	Def NFon '(' L_argt ')' ':' TP
        ;
		
D       :	D_entp L_vart C
	| 	D_entf L_vart C
        ;
		
LD      :       %empty
	|	LD D       {$$ = $1; /*On voulait mettre une valeur marrante mais ça compile pas :( */}
        ;
		
%%

#include "arbre.h"
#include "yy.lex.c"

int main (int argc, char* argv [])
{
    return EXIT_SUCCESS;
}
