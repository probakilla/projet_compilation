/* anasem.h */
#ifndef ANASEM_H
#define ANASEM_H 

/*------------------FONCTIONS ---------------------------------------------------*/
/*------------------types--------------------------------------------------------*/

/* envoie message s d'erreur de type en ligne ligne                              */
extern void typ_error(char *s,int ligne);
/*renvoie le type de e*/
extern type calcul_type(BILENVTY rho_gb, NOE e,int ligne);
#endif
