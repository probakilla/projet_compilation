/* arbre.c */
#include <assert.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "arbre.h"
#include "ppascal.tab.h"
#include "interp.h"
/*-------------------------------------------------------------------*/
/* ----------------------------types---------------------------------*/
/*  type, NOE,ENVTY,BILENVTY: definis dans arbre.h                   */
/*-------------------------------------------------------------------*/
/*---------------------allocation memoire----------------------------*/
char *Idalloc()
{
  return((char *)malloc(MAXIDENT*sizeof(char)));
}
NOE Nalloc()
{
  return((NOE)malloc(sizeof(struct noeud)));
}
ENVTY Envtalloc()
{
  return((ENVTY)malloc(sizeof(struct cellenvty)));
}
type *talloc()
{
  return((type *)malloc(sizeof(type)));
}
LFON Lfonalloc()
{
  return((LFON)malloc(sizeof(struct cellfon)));
}
/*-------------------------------------------------------------------*/
/*-------------------liberation de memoire---------------------------*/
void freeNOE(NOE n){

  free(n->ETIQ);
  if (n->FG!= NULL)
    freeNOE(n->FG);
  if (n->FD != NULL)
    freeNOE(n->FD);
}

void freeENV(ENVTY env){
  free(env->ID);

  if (env->SUIV != NULL)
    freeENV(env->SUIV);
}


void freeLFON(LFON l){
  free(l->ID);
  if (l->CORPS != NULL)
    freeNOE(l->CORPS);
  freeBILE(l->PARAM);
  freeBILE(l->VARLOC);


}

void freeBILE(BILENVTY b){
  if (b.debut != NULL){
    freeENV(b.debut);
    if (b.fin != NULL)
      freeENV(b.fin);
  }
}

void freeBILF(BILFON b){
  if(b.debut != NULL){
    freeLFON(b.debut);
    if (b.fin != NULL)
      freeLFON(b.fin);
  }
}

/*-------------------------------------------------------------------*/
/*---------------------parcours d'arbres-----------------------------*/
void prefix(NOE n)
/* ecrit l'expression n en notation prefixe*/
{ if(n != NULL)
    {if (n->ETIQ)
	printf("%s ",n->ETIQ);
      else
	printf("%s ",nomop(n->codop));
      prefix(n->FG);
      prefix(n->FD);
    };
}

/*-------------------------------------------------------------------*/
/*-----------------------------environnements------------------------*/
/* 1 si t1 ==t2 , 0 sinon                   */
int type_eq(type t1, type t2)
{return((t1.DIM==t2.DIM) && (t1.TYPEF==t2.TYPEF));
}

/* copie torig vers *tcop  */
void type_copy(type *tcop,type torig)
{tcop->DIM=torig.DIM;
  tcop->TAILLE=torig.TAILLE;
  tcop->TYPEF=torig.TYPEF;
  return;
}

/* affecte le type  de *prho      */
void type_affect(ENVTY rho,type tvar)
{(rho->TYPE).DIM=tvar.DIM;
  (rho->TYPE).TAILLE=tvar.TAILLE;
  (rho->TYPE).TYPEF=tvar.TYPEF;
}

/* retourne le type                  */
type creer_type(int dm, int taille, int tf)
{type TT;
  TT.DIM=dm;
  TT.TAILLE=taille;
  TT.TYPEF=tf;
  return(TT);
}

/* pointe vers cette var typee */
ENVTY creer_envty(char *etiq, type tau, int val)
{ENVTY ety;
  ety= Envtalloc();
  if (etiq !=NULL)
    {ety->ID=Idalloc();
      strcpy(ety->ID,etiq);}
  ety->TYPE=tau;
  ety->VAL=val;
  ety->SUIV=NULL;
  return(ety);
}

/* pointe vers copie  */
ENVTY copier_envty(ENVTY env)
{ENVTY ety = NULL;
  if (env != NULL)
    {
      ety= Envtalloc();
      if (env->ID!=NULL)
	{ety->ID=Idalloc();
	 strcpy(ety->ID,env->ID);}
      type_copy(&(ety->TYPE),env->TYPE);
      ety->VAL=env->VAL;
      ety->SUIV= copier_envty(env->SUIV);
    }
  return(ety);
}

/* retourne (arg1 op arg2) ou bien (op arg1) pour op "de base "*/
int eval(int op, int arg1, int arg2)
{switch(op)
    {case Pl:
	return(arg1 + arg2);
    case Mo:
      return(arg1 - arg2);
    case Mu:
      return(arg1 * arg2);
    case Ind:
      return(TAS[ADR[arg1]+arg2]);
    case And:
      return(arg1 * arg2);
    case Or:
      if (arg1 * arg2 == 0)
	return(arg1 + arg2);
      else
	return(1);
    case Not:
      return(1-arg1);/* l'argument est en position 1 */
    case Lt:
      if (arg1 < arg2)
	return(1);
      else
	return(0);
    case Eq:
      if (arg1 == arg2)
	return(1);
      else
	return(0);
    default:
      return(0);
    }
  return(0);
}
 
/* retourne l'adresse de la cellule contenant chaine. NULL si la chaine est absente */
ENVTY rechty(char *chaine, ENVTY listident)
{if (listident!=NULL)
    {if (strcmp(listident->ID,chaine)==0)
        {printf("trouve %s en position %p \n",chaine,listident);
	  return listident;}
      else
	return rechty(chaine,listident->SUIV);
    }
  else
    return NULL;
}


/* affecte val a la variable var, dans rho */
/* NB: le type n'est pas utilise           */
int affectty(ENVTY rho, char *var, type tpvar, int val)
{ENVTY pos;
  pos=rechty(var,rho);/* adresse de la cellule contenant var */
  printf("ancienne valeur vaut %d \n",pos->VAL);
  if (pos != NULL)
    {(pos->VAL)=val;
      (pos->TYPE)=tpvar;
      return(EXIT_SUCCESS);
    }
  else
    return(EXIT_FAILURE);
}

/* traduit entier (= codop) vers chaine (= nom operation)  */
/* utile pour les fonctions d'ecriture */
char *nomop(int codop)
{switch(codop)
    {case(I):return("I");
    case(V):return("V");
    case(Mp): return("Mp");
    case(Af): return("Af");
    case(Sk): return("Sk");
    case(NewAr): return("New_array_of ");
    case(T_ar): return("array_of ");
    case(T_int): return("integer");
    case(T_com): return("commande");
    case(T_bot): return("typ_indefini");
    case(T_err): return("typ_erreur");  
    case(Se): return("Se");
    case(Ind): return("Ind");  
    case(If): return("If");
    case(Th): return("Th");
    case(El): return("El");
    case(Wh): return("Wh");
    case(Do): return("Do");
    case(Pl): return("Pl");
    case(Mo): return("Mo");
    case(Mu): return("Mu");
    case(And):return("And");
    case(Or): return("Or");
    case(Not): return("Not");
    case(Lt): return("<");
    case(Eq): return("=");
    default: return(NULL);
    };
}

/* ecrit le type */
void ecrire_type(type tp)
{printf("DIM:%d,TAILLE:%d,TYPEF:%d,",tp.DIM,tp.TAILLE,tp.TYPEF);
}

/* affiche l'environnement type      */  
int ecrire_envty(ENVTY rho)
{ if (rho==NULL)
    {printf("fin d'environnement \n");
      return(EXIT_SUCCESS);}
  else
    {printf("variable %s ",rho->ID);
      ecrire_type(rho->TYPE);
      printf("valeur %d \n",rho->VAL);
      ecrire_envty(rho->SUIV); 
      return(EXIT_SUCCESS);
    };
}

/* valeur de var dans rho                                    */
/* NB: la valeur d'un tableau est un index du tas            */
int valchty(ENVTY rho, char *var)
{ENVTY pos;
  pos=rechty(var,rho);/* adresse de la cellule contenant var */
  if (pos != NULL)
    return(pos->VAL);
  else
    return(0);
}

/* initialise var dans *prho */
/* le couple  (var,tvar)  est copie dans l'environnement */
void inbilenvty(BILENVTY *prho,char *var,type tvar)
{ENVTY erho, pos, newcell;
  erho=prho->debut;
  pos=rechty(var,erho);/* adresse de la cellule contenant var */
  if (pos == NULL)
    /*on insere var en tete de envrnt*/
    { 
      newcell=Envtalloc();
      newcell->ID=Idalloc();
      strcpy(newcell->ID,var);
      /* newcell->VAL=intalloc(); */
      newcell->VAL=0;
      type_affect(newcell,tvar);
      newcell->SUIV=erho;
      prho->debut=newcell;
    }
}

/* retourne une biliste vide  */
BILENVTY bilenvty_vide()
{BILENVTY bty;
  bty.debut=NULL;bty.fin=NULL;
  return(bty);
}

/* retourne une biliste a un element */
BILENVTY creer_bilenvty(ENVTY varty)
{BILENVTY bty;
  bty.debut=varty;bty.fin=varty;
  return(bty);
}

/* pointe vers copie      */
BILENVTY copier_bilenvty(BILENVTY bty)
{ENVTY aty,ctycour; BILENVTY bcty;
  aty=copier_envty(bty.debut);
  bcty.debut=aty;
  ctycour=aty;
  while(ctycour && ctycour->SUIV)
    ctycour=ctycour->SUIV;
  bcty.fin=ctycour;
 
  return(bcty);
}

/* retourne la concatenation                       */
/* copie les deux arguments: pas de factorisation  */
BILENVTY concatty(BILENVTY bty1, BILENVTY bty2)
{BILENVTY bty,nbty1,nbty2;  
  nbty1=copier_bilenvty(bty1);
  nbty2=copier_bilenvty(bty2);
  if (nbty1.fin!= NULL)
    if (nbty2.debut!=NULL)
      {
	nbty1.fin->SUIV=nbty2.debut;
        bty.debut=nbty1.debut;
        bty.fin=nbty2.fin;
	
        return(bty);}
    else
      return(nbty1);
      else
	  return(nbty2);
}

/* affiche la biliste de variables typees */
void ecrire_bilenvty(BILENVTY bty)
{ecrire_envty(bty.debut);
}

/* affecte  la valeur rhs a la variable lhs (rho_lc prioritaire) */
void affectb(BILENVTY rho_gb, char *lhs, int rhs)
{ENVTY pos;
  pos=rechty(lhs,rho_gb.debut);  
  if (pos!=NULL)
    pos->VAL=rhs;                   /* lhs est une var enregistree           */
  else
    printf("erreur: variable %s non declaree", lhs);
}

NOE creer_noe(int codop, type typno, char* etiq, NOE fg, NOE fd)
{
  NOE noeud = Nalloc();
  noeud->codop = codop;
  noeud->typno = typno;
  if (etiq != NULL)
    {
      noeud->ETIQ = Idalloc();
      strcpy(noeud->ETIQ, etiq);
    }
  noeud->FG = fg;
  noeud->FD = fd;
  return noeud;
}

NOE copier_noe(NOE noe)
{
  NOE noeud = NULL;
  if (noe != NULL)
    {
      noeud = Nalloc();
      noeud->codop = noe->codop;
      noeud->typno = noe->typno;
      if (noe->ETIQ != NULL)
	{
	  noeud->ETIQ = Idalloc();
	  strcpy(noeud->ETIQ, noe->ETIQ);
	}     
      noeud->FG = copier_noe(noe->FG);
      noeud->FD = copier_noe(noe->FD);
    }
  return noeud;
}

LFON copier_fon(LFON lfn)
{
  LFON copy = NULL;
  if (lfn != NULL)
    {
      copy =  Lfonalloc();
      if(lfn->ID != NULL)
	{
	  copy->ID = Idalloc();
	  strcpy(copy->ID, lfn->ID);
	}
      copy->PARAM = copier_bilenvty(lfn->PARAM);
      copy->VARLOC = copier_bilenvty(lfn->VARLOC);
      copy->CORPS = copier_noe(lfn->CORPS);
      copy->SUIV = copier_fon(lfn->SUIV);
      type_copy(&(copy->TYPRET), lfn->TYPRET);
    }
  return copy;
}

void ecrire_fon(LFON bfn)
{
  if (bfn == NULL)
    printf("\nfin d'environnement \n");
  else
    {
      printf("\nNom de la fonction: %s\n", bfn->ID);
      printf("  Paramètre de la fonction:\n");
      ecrire_bilenvty(bfn->PARAM);
      printf("Les variables locales:\n");
      ecrire_bilenvty(bfn->VARLOC);
      printf("  Corps de la fonction:\n");
      prefix(bfn->CORPS);
      printf("\n  Type de retour\n");
      ecrire_type(bfn->TYPRET);
      ecrire_fon(bfn->SUIV);
    }
}

LFON rechfon(char *chaine, LFON listident)
{
  if (listident!=NULL)
    if (strcmp(listident->ID,chaine)==0)
      {
	printf("trouve %s en position %p \n",chaine,listident);
	return listident;
      }
    else
      return rechfon(chaine, listident->SUIV);
  else
    return NULL;
}

BILFON bilfon_vide()
{
  BILFON bfn;
  bfn.debut = NULL;
  bfn.fin = NULL;
  return bfn;
}

BILFON creer_bilfon(LFON pfon)
{
  BILFON bfn;
  bfn.debut = pfon;
  bfn.fin = pfon;
  return bfn;
}

BILFON copier_bilfon(BILFON bfn)
{
  LFON lfn, lfncour;
  BILFON bfncp;
  lfn = copier_fon(bfn.debut);
  bfncp.debut = lfn;
  lfncour = lfn;
  while (lfncour && lfncour->SUIV)
    lfncour = lfncour->SUIV;
  bfncp.fin = lfncour;
  return bfncp;
}

BILFON concatfn(BILFON bfn1, BILFON bfn2)
{
  BILFON bfn, nbfn1, nbfn2;
  nbfn1 = copier_bilfon(bfn1);
  nbfn2 = copier_bilfon(bfn2);
  if (nbfn1.fin !=NULL)
    if (nbfn2.debut !=NULL)
      {
	nbfn1.fin->SUIV = nbfn2.debut;
	bfn.debut = nbfn1.debut;
	bfn.fin = nbfn2.fin;
	return bfn;
      }
    else
      return nbfn1;
  else
    return nbfn2;
}

BILENVTY allvars(BILFON bfon)
{
  BILENVTY param = bilenvty_vide();
  BILENVTY varloc = bilenvty_vide();
  if (bfon.debut != NULL)
    {
      LFON fon = bfon.debut;
      while(fon != NULL)
	{
	  param = concatty(param, fon->PARAM);
	  varloc = concatty(varloc, fon->VARLOC);
	  fon = fon->SUIV;
	}
    }
  return concatty(param, varloc);
}

void ecrire_bilfon(BILFON bfn)
{
  ecrire_fon(bfn.debut);
}
/*-------------------------------------------------------------------------------*/
/*---------------------programmes -----------------------------------------------*/
void ecrire_prog(BILFON lfon, BILENVTY argby,NOE argno)
{printf("Les variables globales:\n");
  printf("------------------------:\n");
  ecrire_bilenvty(argby);printf("\n");
  printf("Les fonctions:\n");
  printf("------------------------:\n");
  ecrire_bilfon(lfon);printf("\n");
  printf("Le programme principal:\n");
  printf("------------------------:\n");
  prefix(argno);printf("\n");
  return;
}
