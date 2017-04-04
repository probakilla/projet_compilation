/*Projet de compilation réalisé par:
  -Chloé Pathé
  -Jimmy Menan
  -Julien Pilleux
  -Guillaume Chupin
*/
%{
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "arbre.h"
#include "interp.h"

int yyerror (char *s);
/* ------------------VARIABLES GLOBALES -------------------------*/
  NOE syntree;          /* commande  globale                     */
  BILENVTY benvty;      /* environnement global                  */
  int ligcour=1;        /* ligne  courante                       */
  type tycour;          /* type courant                          */
  ENVTY vtycour;        /* var typee courante                    */
/* -------------------------------- -----------------------------*/

%}
%start MP
%union{NOE NO; type TYP; BILENVTY LARGT; BILFON LFON;}

%type <NO>     MP C Ca E Et L_argsnn L_args
%type <TYP>    TP
%type <LARGT>  Argt L_vart L_vartnn L_argt L_argtnn
%type <LFON>   D LD D_entp D_entf
			
%token <NO>    Pl Mo Mu Or Lt Eq And Not I V True False NewAr Se Af Sk If Th El Wh Do Dep Def NPro NFon Var Ind Mp
%token <TYP>   T_boo T_int T_ar T_err T_bot T_com
%left And Or
%left Pl Mo
%left Mu
%nonassoc Eq lt Not
%%

MP      :	L_vart LD C {benvty = $1; syntree = $2; YYACCEPT;}
		
E       :	E Pl E      {$$ = Nalloc();
                             $$->codop = Pl;
                             type_copy(&($$->typno),T_int);
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"+");}
	| 	E Mo E      {$$ = Nalloc();
                             $$->codop = Mo;
                             type_copy(&($$->typno),T_int);
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"-");}
	| 	E Mu E      {$$ = Nalloc();
                             $$->codop = Mu;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             type_copy(&($$->typno),T_int);
                             strcpy($$->ETIQ,"*");}
	| 	E Or E      {$$ = Nalloc();
                             $$->codop = Or;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             type_copy(&($$->typno),T_boo);
                             strcpy($$->ETIQ,"Or");}
	| 	E Lt E      {$$ = Nalloc();
                             type_copy(&($$->typno),T_boo);
                             $$->codop = Lt;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"Lt");}
	| 	E Eq E      {$$ = Nalloc();
                             $$->codop = Eq;
                             $$->FG = $1;
                             type_copy(&($$->typno),T_boo);
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"Eq");}
	| 	E And E     {$$ = Nalloc();
                             $$->codop = And;
                             type_copy(&($$->typno),T_boo);
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"And");}
	| 	Not E       {$$ = Nalloc();
                             type_copy(&($$->typno),T_boo);
                             $$->codop = Not;
                             $$->FG = $2;
                             $$->FD = NULL;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"Not");}
	|   '('	E ')'       {$$ = $2;}
	| 	I           {$$ = $1;}
	| 	V           {$$ = $1;}
	| 	True        {$$ = $1;}
	| 	False       {$$ = $1;}
	| 	V '(' L_args ')'     {$$ = Nalloc();
                                      $$->codop = $1;} //onsépa
	| 	NewAr TP '[' E ']'   {$$ = Nalloc();
                                      $$->codop = NewAr;
                                      type_copy(&($$->typno),$2); /* DIM,TYPEF sont connus   */
				      ($$->typno).DIM++;          /* mise a jour DIM         */
      	 			      $$->FG=NULL;
				      $$->FD=$4;          /* TAILLE a calculer a partir de E */}
	| 	Et          {$$ = $1;}
        ;

Et      :       V '[' E ']'  {$$ = Nalloc();              /* un seul indice                   */
                              $$->codop = Ind;
			      $$->FG = $1;
			      $$->FD = $3;}
	| 	Et '[' E ']' {$$ = Nalloc();             /* plusieurs indices                */
                              $$->codop = Ind;
			      $$->FG = $1;
			      $$->FD = $3;}
        ;
	
Ca      :	C Se Ca      {$$ = Nalloc();
                              $$->codop = Se;
                              $$->FG = $1;
                              $$->FD = $3;
                              $$->ETIQ = malloc(2);
                              strcpy($$->ETIQ,"Se");}
        |       C            {$$ = $1;}
        ;

C       : 	Et Af E     {$$ = Nalloc();
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
	| 	Sk                {$$ = $1;}
	|   '{' C '}'             {$$ = $2;}
	| 	If E Th C El Ca   {$$ = Nalloc();
                                   $$->codop = If;
                                   $$->FG = $2;         /* condition     */
                                   $$->FD = Nalloc();   /* alternative   */
			           $$->FD->ETIQ="";     /* champ inutile */
			           $$->FD->FG = $4;     /* branche true  */
			           $$->FD->FD = $6;     /* branche false */
                                   $$->ETIQ = malloc(2);
                                   strcpy($$->ETIQ,"IfThEl");}
	| 	Wh E Do Ca   {$$ = Nalloc();
                             $$->codop = Wh;
                             $$->FG = $2;         /* condition d'entree dans le while */
                             $$->FD = $4;         /* corps du while                   */
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"Wh");}
	| 	V '(' L_args ')' 
        ;

L_args  :       %empty      {$$ = Nalloc();}
	| 	L_argsnn    {$$ = $1;}
        ;
		
L_argsnn: 	E               {$$ = $1;}
	| 	E ',' L_argsnn  {;} // a todo
	;
			
L_argt  :       %empty      {$$ = bilenvty_vide ();}
	| 	L_argtnn    {$$ = $1;}
	;
		
L_argtnn: 	Argt               {$$ = $1;}       
	| 	L_argtnn ',' Argt  {$$ = concatty ($1, $3);}
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
		
D_entp  : 	Dep NPro '(' L_argt ')'{$$ = creer_bilfon(creer_fon($2, $4, NULL, NULL));}
        ;
		
D_entf  : 	Def NFon '(' L_argt ')' ':' TP {$$ = creer_bilfon(creer_fon($2, $4, bilenvty_vide(), Nalloc()));}
        ;
		
D       :	D_entp L_vart C  {$1.debut->VARLOC = $2;
                                  $1.debut->CORPS = $3;
                                  $$ = $1;}
        | 	D_entf L_vart C  {$1.debut->VARLOC = $2;
                                  $1.debut->CORPS = $3;
                                  $$ = $1;}
        ;
		
LD      :       %empty     {$$ = bilfon_vide();}
        |	LD D       {$$ = concatfn($1, $2);}
        ;
		
%%

#include "yy.lex.c"

int yyerror (char* s)
{
    fprintf (stderr, "%s error\n", s);
    return EXIT_FAILURE;
}

int main (int argc, char* argv [])
{
    return EXIT_SUCCESS;
}
