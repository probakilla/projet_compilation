/* arbre.h */
#ifndef ARBRE_H
#define ARBRE_H 
/* ----------------------------types--------------------------------------------*/

/* type: tableau */
typedef struct {
  int DIM;   /* dimension ; vaut 0 ssi type de base                           */
  int TYPEF; /* type des cellules de plus petite dim: T_int ou T_com ou T_err */
}type;

/* commande := arbre abstrait */
typedef struct noeud{
  int codop;  /* I,V, operateur */
  type typno; /*[0,0,T_com](si commande) ou [k,l,T_int] (si expression)*/
  char *ETIQ;
  struct noeud *FG, *FD;} *NOE;

/* environnement_type := liste de var ou param (identificateur, type, valeur)  */
typedef struct cellenvty{
  char *ID;
  type TYPE;
  int  VAL;
  struct cellenvty *SUIV;} *ENVTY;

/* biliste de var ou param */
typedef struct bilenvty{
  ENVTY debut;
  ENVTY fin;}BILENVTY;

/* listefonctions := liste de 4-tuples (ident, BILparametres, BILvarloc, ast) */
typedef struct cellfon{
  char *ID;
  BILENVTY PARAM;    /* pametres formels  */
  BILENVTY VARLOC;   /* variables locales */
  NOE CORPS;
  struct cellfon *SUIV;} *LFON;

/* biliste de fonctions */
typedef struct{
  LFON debut;
  LFON fin;}BILFON;


/*------------------FONCTIONS ---------------------------------------------------*/
/*---------------------parcours d'arbres-----------------------------------------*/
extern int yylex();          /* fonction generee par flex                        */
extern int yyerror();        /* fonction generee par flex/bison                  */
/*---------------------allocation memoire----------------------------------------*/
extern char *Idalloc();      /* retourne un tableau de MAXIDENT char             */
extern NOE Nalloc();         /* retourne un NOE                                  */
extern ENVTY Envtalloc();    /* retourne un ENVTY                                */
extern type *talloc();       /* retourne un pointeur sur type *                  */
extern LFON  Lfonalloc();    /* retourne un LFON                                 */
/*---------------------parcours d'arbres-----------------------------------------*/
 extern void prefix(NOE n);   /* ecrit l'expression n en notation prefixe         */
/*---------------------environnements--------------------------------------------*/
extern int  type_eq(type t1, type t2);/* 1 si t1 ==t2 , 0 sinon                  */
extern void type_copy(type *tcop, type torig);/* copie torig vers tcop           */
extern void type_affect(ENVTY rho, type tvar);/* affecte le type  de   *rho      */
extern type creer_type(int dm, int tf);        /* retourne le type               */
extern ENVTY creer_envty(char *etiq, type tau,int val);/*pointe vers cette var typee*/
extern ENVTY copier_envty(ENVTY env);/*pointe vers une copie                     */
extern char *nomop(int codop);/* traduit entier vers chaine (= nom operation)    */
extern void ecrire_type(type tp);      /* ecrit le type                          */
extern int ecrire_envty(ENVTY rho);/* affiche l'environnement type               */
extern int eval(int op, int arg1, int arg2); /* retourne (arg1 op arg2)          */
extern ENVTY rechty(char *chaine, ENVTY listident);/* retourne la position de chaine*/
/* retourne la position de chaine (rho_lc est prioritaire) */
extern int affectty(ENVTY rho, char *var, type tpvar, int val);/*   affecte var  */
extern int valchty(ENVTY rho, char *var); /* valeur de var dans envirnt-type rho */
/*---------------------bilistes-de-var-typees------------------------------------*/
extern void inbilenvty(BILENVTY *prho,char *var,type tvar);   /* initialise var  */
extern BILENVTY bilenvty_vide() ;                  /* retourne une biliste vide  */
extern BILENVTY creer_bilenvty(ENVTY varty);/* retourne une biliste a un element */
extern BILENVTY copier_bilenvty(BILENVTY bty);/*pointe vers copie                */
extern BILENVTY concatty(BILENVTY bty1, BILENVTY bty2);/* retourne la concatenation*/
extern void ecrire_bilenvty(BILENVTY bty); /* affiche la biliste de quadruplets  */
/* affecte  la valeur rhs a la variable lhs                                      */
extern void affectb(BILENVTY rho_gb, char *lhs, int rhs);
/*---------------------fonctions --------------------------------------------*/
extern LFON creer_fon(char *nfon, BILENVTY lparam,BILENVTY lvars,NOE com);   /* pointe vers cette fonction */
extern NOE creer_noe(int codop, type typno, char* etiq, NOE fg, NOE fd);
extern NOE copier_noe(NOE noe);      /* pointe vers une copie                */
extern LFON copier_fon(LFON lfn);    /* pointe vers une copie                */
extern void ecrire_fon(LFON bfn);
extern LFON rechfon(char *chaine, LFON listident);/* retourne la position de chaine*/ 
/*---------------------bilistes-de-fonctions --------------------------------*/
extern BILFON bilfon_vide() ;                  /* retourne une biliste vide  */
extern BILFON creer_bilfon(LFON pfon);  /* retourne une biliste a un element */
extern BILFON copier_bilfon(BILFON bfn);/* pointe vers une copie             */
extern BILFON concatfn(BILFON bfn1, BILFON bfn2);/* retourne la concatenation*/
extern BILENVTY allvars(BILFON bfon);/*les variables de bfon (params puis varloc)*/
extern void ecrire_bilfon(BILFON bfn);   /* affiche la biliste de fonctions  */
/*---------------------programmes -----------------------------------------------*/
void ecrire_prog(BILENVTY argby,NOE argno);/* affiche le programme  */
/* --------------------CONSTANTES -----------------------------------------------*/
#define MAXIDENT 16          /* long max d'un identificateur de variable         */
#define TAILLEADR 1000       /* nbe max adresses dans le tas                     */
#define TAILLEMEM 10000      /* taille du tas                                    */
/*---------------------VARIABLES globales ---------------------------------------*/
/* definies au  debut de y.tab.c , non-declarees dans y.tab.h                    */
//extern NOE syntree;          /* arbre syntaxique                        (y.tab.c)*/
//extern BILENVTY benvty;      /* environnement global                    (y.tab.c)*/
#endif

