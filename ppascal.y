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
#include "anasem.h"

int yyerror (char *s);
/* ------------------VARIABLES GLOBALES -------------------------*/
  NOE syntree;          /* commande  globale                     */
  BILENVTY benvty;      /* environnement global                  */
  BILENVTY lenvty;      /* environnement local                   */
  BILFON bifon;         /* environnement fonctions               */
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
%left Se
%left And Or Not Lt Eq
%left Pl Mo
%left Mu

%%

MP      :	L_vart LD C { benvty = $1; bifon = $2; syntree = $3; YYACCEPT;}
		
E       :	E Pl E      {$$ = Nalloc();
                             $$->codop = Pl;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"+");
                             calcul_type(benvty, $$ , ligcour);}
	| 	E Mo E      {$$ = Nalloc();
                             $$->codop = Mo;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"-");
                             calcul_type(benvty, $$ , ligcour);}
	| 	E Mu E      {$$ = Nalloc();
                             $$->codop = Mu;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"*");
                             calcul_type(benvty, $$ , ligcour);}
	| 	E Or E      {$$ = Nalloc();
                             $$->codop = Or;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"Or");
                             calcul_type(benvty, $$ , ligcour);}
	| 	E Lt E      {$$ = Nalloc();
                             $$->codop = Lt;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"Lt");
                             calcul_type(benvty, $$ , ligcour);}
	| 	E Eq E      {$$ = Nalloc();
                             $$->codop = Eq;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"Eq");
                             calcul_type(benvty, $$ , ligcour);}
	| 	E And E     {$$ = Nalloc();
                             $$->codop = And;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"And");
                             calcul_type(benvty, $$ , ligcour);}
	| 	Not E       {$$ = Nalloc();
                             $$->codop = Not;
                             $$->FG = $2;
                             $$->FD = NULL;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"Not");
			     $$->typno = calcul_type(benvty, $$ , ligcour);
			     }
	|   '('	E ')'       {$$ = $2;}
	| 	I           {$$ = $1;}
	| 	V           {$$ = $1;}
        | 	True        {$$ = Nalloc(); $$->codop = T_boo; $$->ETIQ = "true";}
	| 	False       {$$ = Nalloc(); $$->codop = T_boo; $$->ETIQ = "false";}
        | 	V '(' L_args ')'     {$$ = Nalloc();
                                      $$->codop = NFon;
				      $$->ETIQ = Idalloc();
				      strcpy($$->ETIQ, $1->ETIQ);
				      $$->FG = $3;
				      $$->FD = NULL;}
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
			      $$->FD = $3;
                              calcul_type(benvty, $1 , ligcour);
                              calcul_type(benvty, $$ , ligcour);}
	| 	Et '[' E ']' {$$ = Nalloc();             /* plusieurs indices                */
                              $$->codop = Ind;
			      $$->FG = $1;
			      $$->FD = $3;
			      calcul_type(benvty, $$ , ligcour);}
        ;
	
C      :	C Se Ca      {$$ = Nalloc();
                              $$->codop = Se;
                              $$->FG = $1;
                              $$->FD = $3;
                              $$->ETIQ = malloc(2);
                              strcpy($$->ETIQ,"Se");
			      calcul_type(benvty, $$ , ligcour);}
        |       Ca            {$$ = $1;}
        ;

Ca       : 	Et Af E     {$$ = Nalloc();
                             $$->codop = Af;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"Af");
			     calcul_type(benvty, $$ , ligcour);}
	| 	V Af E      {$$ = Nalloc();
                             $$->codop = Af;
                             $$->FG = $1;
                             $$->FD = $3;
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"Af");
			     calcul_type(benvty, $1 , ligcour);
			     calcul_type(benvty, $$ , ligcour);}
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
                                   strcpy($$->ETIQ,"IfThEl");
				   calcul_type(benvty, $$ , ligcour);}
	| 	Wh E Do Ca   {$$ = Nalloc();
                             $$->codop = Wh;
			     type_copy(&($$->typno), creer_type(0,T_com));
                             $$->FG = $2;         /* condition d'entree dans le while */
                             $$->FD = $4;         /* corps du while                   */
                             $$->ETIQ = malloc(2);
                             strcpy($$->ETIQ,"Wh");
			     calcul_type(benvty, $$ , ligcour);}
	| 	V '(' L_args ')' {$$ = Nalloc();
                                  $$->codop = NFon;
				  $$->ETIQ = Idalloc();
				  strcpy($$->ETIQ, $1->ETIQ);
				  $$->FG = $3;
				  $$->FD = NULL;}
        ;

L_args  :       %empty      {$$ = NULL;}
	| 	L_argsnn    {$$ = $1;}
        ;
		
L_argsnn: 	E               {$$ = $1;}
        |  	E ',' L_argsnn  {$$ = Nalloc();
				 $$->FG = $1;
		                 $$->FD = $3;}
        ;
			
L_argt  :       %empty      {$$ = bilenvty_vide ();}
	| 	L_argtnn    {$$ = $1;}
	;
		
L_argtnn: 	Argt               {$$ = $1;}       
	| 	L_argtnn ',' Argt  {$$ = concatty ($1, $3);}
	;
			
Argt    :	V ':' TP    {$$ = creer_bilenvty(creer_envty($1->ETIQ,$3,0));}
        ;
		
TP      :	T_boo       {type_copy(&$$, creer_type(0, T_boo));}
        |  	T_int       {type_copy(&$$, creer_type(0, T_int));}
        | 	T_ar TP     {type_copy(&$$, $2), $$.DIM++;}
        ;
		
L_vart  :       %empty      {$$ = bilenvty_vide(); benvty = $$;}
	| 	L_vartnn    {$$ = $1; benvty = $$;}
        ;
		
L_vartnn: 	Var Argt               {$$ = $2;}
	| 	L_vartnn ',' Var Argt  {$$ = concatty ($1, $4);}
	;
		
D_entp  : 	Dep NPro '(' L_argt ')'  {LFON fon = Lfonalloc();
                                          fon->ID = $2->ETIQ;
					  fon->PARAM = $4;
					  $$ = creer_bilfon(fon);}
        ;
		
D_entf  : 	Def NFon '(' L_argt ')' ':' TP {LFON fon = Lfonalloc();
                                                fon->ID = $2->ETIQ;
						fon->PARAM = $4;
						fon->TYPRET = $7;
						$$ = creer_bilfon(fon);}
        ;
		
D       :	D_entp L_vart C  {$1.debut->VARLOC = copier_bilenvty($2);
                                  $1.debut->CORPS = copier_noe($3);
                                  $$ = $1;}
        | 	D_entf L_vart C  {$1.debut->VARLOC = copier_bilenvty($2);
                                  $1.debut->CORPS = copier_noe($3);
                                  $$ = $1;}
        ;
		
LD      :       %empty     {$$ = bilfon_vide();}
        |	LD D       {$$ = concatfn($1, $2);}
        ;
		
%%

#include "yy.lex.c"

int yyerror (char* s)
{
  fprintf (stderr, "%s ligne %d \n", s, ligcour);
    return EXIT_FAILURE;
}

/*  pour tester l'analyse */
int main(int argn, char **argv)
{
  yyparse();
  ecrire_prog(bifon, benvty,syntree);
  return(1);
  }

				       /*  pour tester l'interpreteur 
int main (int argc, char* argv [])
{
  yyparse();
  ecrire_prog(bifon, benvty, syntree);
  type terr=creer_type(0,T_err);
  type tcom= creer_type(0,T_com);
  if (type_eq(syntree->typno,terr))
    {
      printf("erreur de typage\n");
      return EXIT_FAILURE;
    }
  else if (type_eq(syntree->typno,tcom))
    printf("programme bien type\n");
  else
    {
    printf("attention: typage incomplet\n");
    return EXIT_FAILURE;
    }
  init_memoire;
  printf("Les variables globales avant exec:\n");
  printf("------------------------:\n");
  ecrire_bilenvty(benvty); printf("\n");
  ecrire_memoire(5,5,20);
  semop_gp(bifon, lenvty, benvty, syntree);
  printf("Les variables globales apres exec:\n");
  printf("------------------------:\n");
  ecrire_bilenvty(benvty); printf("\n");
  ecrire_memoire(5,5,20);
  return EXIT_SUCCESS;
  }*/

