#include <assert.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "arbre.h"
#include "ppascal.tab.h"
#include "interp.h"

/*--------------------------------------------------------------------*/
/* -----------------------------types---------------------------------*/
/*   NOE,ENVTY,BILENVTY  : definis dans arbre.h                       */
/*--------------------------------------------------------------------*/


/* ------------------VARIABLES GLOBALES ------------------------------*/
/* le tas; (NIL=0); "vraies" adresses >=1                             */
int TAS[TAILLEMEM];
/* ADR[i]=adresse dans le tas du tab i                                */
int ADR[TAILLEADR];
/* TAL[i]=taille du tab i                                             */
int TAL[TAILLEADR];  
int ptasl=1; /* premiere place libre dans TAS[]                       */
int padrl=1; /* premiere place libre dans ADR[]                       */
/*--------------------------------------------------------------------*/
/* ----------------------traitement--memoire--------------------------*/
void init_memoire()
{int i=0;
while (i < TAILLEMEM)
  TAS[i++]=0;
 i=0;
while (i < TAILLEADR)
  {ADR[i++]=0;
   TAL[i]=0;
  }
}
/* decrit la memoire: */
/* ADR[i]: adresse du tableau i dans le TAS */
/* TAL[i]: taille du tableau i; de ADR[i] a ADR[i] + TAL[i] */
/* TAS: tableau (statique) contenant tous les tableaux (dynamiques) */
void ecrire_memoire(int maxadr, int maxtal, int maxtas)
{int i;
 printf("Le tableau ADR:\n");
 printf("------------------------:\n");
 for(i=0; i < maxadr;i++)
   printf("%d:",ADR[i]);
 printf("\n");
 printf("Le tableau TAL:\n");
 printf("------------------------:\n");
 for(i=0; i < maxadr;i++)
   printf("%d:",TAL[i]);
 printf("\n");
 printf("Le tableau TAS:\n");
 printf("------------------------:\n");
 for(i=0; i < maxtas;i++)
   printf("%d:",TAS[i]);
 printf("\n");
 return;
}
/*--------------------------------------------------------------------*/	    
/*---------------semantique-------------------------------------------*/
/* N.B.allocation dynamique de tableaux; mais pas de ramasse-miettes! */

/* semantique op a grands pas des expressions                         */
/* fait agir e sur rho_gb, le  modifie, retourne val(e)               */
int semval(BILFON rho_fn, BILENVTY rho_gb,NOE e) 
{ if(e != NULL)
    {ENVTY pos;
      int res,taille;
            switch(e->codop)
	{
	 case Ind:
	   {
	     int tab = semval (rho_fn, rho_gb, e->FG);
	     int ind = semval (rho_fn, rho_gb, e->FD);
	     return TAS[ADR[tab] + ind];
	   }
	  case Pl:case Mo:case Mu:case And:case Or:case Lt:case  Eq:/* op binaire     */
	    return(eval(e->codop,semval(rho_fn, rho_gb,e->FG),semval(rho_fn, rho_gb,e->FD)));
	case Not:                                            /* operation unaire      */
	  return(eval(e->codop,semval(rho_fn, rho_gb,e->FG),0));
	case I:                        /* numeral          */
	  return (atoi(e->ETIQ));
	case V:                         /* variable        */
	  {pos=rechty(e->ETIQ,rho_gb.debut);
	   return(pos->VAL);          /* rho_gb(var)     */
	  }
	case False:
	  return 0;
	case True:
	  return 1;
	case NewAr:                     /*creation tableau */
	  {
	    int taille = semval (rho_fn, rho_gb, e->FD);
	    res = padrl;
	    ADR[res] = ptasl;
	    ptasl += taille;
	    TAL[res] = taille;
	    padrl++;
	    return res;
	  }
	  case NFon:
	  {
	    LFON fon = rechfon(e->ETIQ, rho_fn.debut);
	    if (fon != NULL)
	      {
		BILENVTY bil = concatty(fon->PARAM, fon->VARLOC);
		bil = concatty(bil, rho_gb);
		semop_gp(rho_fn, bil, fon->CORPS);
		ENVTY env = rechty(e->ETIQ, bil.debut);
		printf("%d\n",env->VAL);
		return env->VAL;
	      }
	    printf("La fonction %s n'est pas définit\n", e->ETIQ);
	  }
	default:
	  return(EXIT_FAILURE);  /* codop inconnu au bataillon */
	}
    }
  else
    return(EXIT_FAILURE);
}

/* semantique op a grands pas des commandes                      */
/* fait agir c sur rho_gb, le  modifie                           */
void semop_gp(BILFON rho_fn, BILENVTY rho_gb, NOE c)
{char *lhs; int rhs; int cond;
 if(c != NULL)
    {switch(c->codop)
       {case Mp:
	    semop_gp(rho_fn, rho_gb, c->FG);
	    break;
	case Af:
	  if (c->FG->codop==V)        /* affectation a une variable */
	    {lhs= c->FG->ETIQ;
	     printf("lhs vaut %s \n",lhs);
	     rhs= semval(rho_fn, rho_gb, c->FD);
	     if (c->FD->codop==NewAr)
	       {
	       ENVTY pos=rechty(lhs,rho_gb.debut);
	       if (pos!=NULL)
		 {
		   int taille= semval(rho_fn, rho_gb, c->FD->FD);
		   pos->TYPE.TAILLE=taille;
		 }
	       }
	     printf("rhs vaut %d \n",rhs);
	     affectb(rho_gb, lhs, rhs);
	    }
	  else
	    {
	      assert(c->FG->codop==Ind);/* affectation a un tableau */
	      int tab = semval(rho_fn, rho_gb, c->FG->FG);
	      int ind = semval(rho_fn, rho_gb, c->FG->FD);
	      char *ntab = c->FG->FG->ETIQ;
	      ENVTY pos = rechty(c->FG->FG->ETIQ, rho_gb.debut); 
	      if(ind >= pos->TYPE.TAILLE)
		printf("ERREUR:Affectation de %d en dehors de la taille du tableau %s\n", semval(rho_fn, rho_gb, c->FD) , ntab);
	      else
		TAS[ADR[tab] + ind] = semval(rho_fn, rho_gb, c->FD);
	    }
	  break;	    
	case Sk: break;
	case Se: 
	  semop_gp(rho_fn, rho_gb, c->FG);
	  semop_gp(rho_fn, rho_gb, c->FD);
	  break; 
	case If:
	  if (semval(rho_fn, rho_gb, c->FG))
	    semop_gp(rho_fn, rho_gb, c->FD->FG);
	  else
	    semop_gp(rho_fn, rho_gb, c->FD->FD);
	  break;
	case Wh:
	  while (semval(rho_fn, rho_gb,  c->FG))
	    {
	    semop_gp(rho_fn, rho_gb, c->FD);
	    semop_gp(rho_fn, rho_gb, c);
	    }
	  break;
	default: break;
	}
    }
}








 

