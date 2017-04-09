%{
  extern int ligcour;
  enum {declareVariable, declareFonction, declareProcedure};
  int declare = declareVariable;
%}

%x COMMENT  
debcom            "/*"
endcom            "*/"
sep               [ \t]+
sign              [\+-]
lettre            [A-Za-z]
caractere         [A-Za-z0-9\-\_]

%%
<INITIAL>{debcom}          {BEGIN COMMENT;}
<COMMENT>{endcom}          {BEGIN INITIAL;}
<COMMENT>.                 {;}
skip                       {yylval.NO=Nalloc();
                           (yylval.NO)->codop = Sk;
                           tycour=creer_type(0,T_com);
                           (yylval.NO)->FG = NULL;
                           (yylval.NO)->FD = NULL;
                           (yylval.NO)->ETIQ = Idalloc();
                           strcpy((yylval.NO)->ETIQ,yytext);
                           type_copy(&((yylval.NO)->typno),creer_type(0,T_com));
                           return(Sk);}
new{sep}array{sep}of       {return(NewAr);}
array{sep}of               {return(T_ar);}
integer                    {type_copy(&(yylval.TYP),creer_type(0,T_int));
                            return(T_int);}
boolean                    {type_copy(&(yylval.TYP),creer_type(0,T_boo));
                            return(T_boo);}
if                         {return(If);}
then                       {return(Th);}
else                       {return(El);}
var                        {return(Var);}
while                      {return(Wh);}
do                         {return(Do);}
"+"                        {return(Pl);}
"-"                        {return(Mo);}
"*"                        {return(Mu);}
"and"                      {return(And);}
"or"                       {return(Or);}
"not"                      {return(Not);}
"<"                        {return(Lt);}
"="                        {return(Eq);}
"true"                     {yylval.NO=Nalloc();
                           (yylval.NO)->codop = True;
			   type_copy(&((yylval.NO)->typno),creer_type(0,T_boo)); 
                           (yylval.NO)->FG = NULL;
                           (yylval.NO)->FD = NULL;
			   (yylval.NO)->ETIQ = malloc(yyleng + 1);
                           strcpy((yylval.NO)->ETIQ,yytext);
			   return(True);}
"false"                    {yylval.NO=Nalloc();
                           (yylval.NO)->codop = False;
			   type_copy(&((yylval.NO)->typno),creer_type(0,T_boo)); 
                           (yylval.NO)->FG = NULL;
                           (yylval.NO)->FD = NULL;
			   (yylval.NO)->ETIQ = malloc(yyleng + 1);
                           strcpy((yylval.NO)->ETIQ,yytext);
			   return(False);}
"defun"                      {declare = declareFonction; return(Def);}
"defpro"                     {declare = declareProcedure; return(Dep);}
<INITIAL>{lettre}{caractere}* {yylval.NO=Nalloc();
                               (yylval.NO)->ETIQ = Idalloc();
			       strcpy((yylval.NO)->ETIQ, yytext);
                               if (declare == declareVariable)
				 {
				   (yylval.NO)->codop = V; /* variable (type inconnu) */
				   (yylval.NO)->FG = NULL;
				   (yylval.NO)->FD = NULL;
				   return(V);}       /* variable                     */
			       else if (declare == declareFonction)
				 {
				   (yylval.NO)->codop = NFon; /* Nom de fonction     */
				   declare = declareVariable;
				   (yylval.NO)->FG = NULL;
				   (yylval.NO)->FD = NULL;
				   return(NFon);}
			       else if (declare == declareProcedure)
				 {
				   (yylval.NO)->codop = NPro; /* Nom de procédure     */
				   declare = declareVariable;
				   (yylval.NO)->FG = NULL;
				   (yylval.NO)->FD = NULL;
				   return(NPro);}
				 }
0|[1-9][0-9]*              {yylval.NO=Nalloc(); /*entier positif; AF:cas negatif*/
                           (yylval.NO)->codop = I;  /* entier                   */
                           printf("analyse lex, token I,l1 \n");
                           tycour=creer_type(0,T_int);
                           type_copy(&((yylval.NO)->typno),creer_type(0,T_int));
                           printf("analyse lex,token I,l2 \n");
                           (yylval.NO)->FG = NULL;
                           (yylval.NO)->FD = NULL;
                           (yylval.NO)->ETIQ = malloc(yyleng + 1);
                           strcpy((yylval.NO)->ETIQ,yytext);
                           printf("analyse lex, ETIQ :%s \n",(yylval.NO)->ETIQ);
                           return(I);}          /* entier                      */
:=                         {return(Af);}
";"                        {return(Se);}
{sep}                      {;}
\n                         {ligcour++;}
.                          {return(yytext[0]);}
%%

int yywrap()
{return(1);}
