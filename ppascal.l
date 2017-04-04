%{
  extern int ligcour;
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
                           (yylval.NO)->ETIQ = malloc(yyleng + 1);
                           strcpy((yylval.NO)->ETIQ,yytext);
                           type_copy(&((yylval.NO)->typno),creer_type(0,T_com));
                           return(Sk);}
new{sep}array{sep}of       {return(NewAr);}
array{sep}of               {return(T_ar);}
integer                    {type_copy(&(yylval.TYP),creer_type(0,T_int)); return(T_int);}
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
"true"                     {return(True);}
"false"                    {return(False);}
"defun"                    {return(Def);}
"defpro"                   {return(Dep);}
<INITIAL>{lettre}{caractere}* {yylval.NO=Nalloc();
                              (yylval.NO)->codop = V; /* variable (type inconnu) */
                              (yylval.NO)->FG = NULL;
                              (yylval.NO)->FD = NULL;
                              (yylval.NO)->ETIQ = malloc(yyleng + 1);
                              strcpy((yylval.NO)->ETIQ,yytext);
                              return(V);}       /* variable                     */
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
                           (yylval.NO)->codop = I;
                           return(I);}          /* entier                      */
:=                         {return(Af);}
";"                        {return(Se);}
{sep}                      {;}
\n                         {ligcour++;}
.                          {return(yytext[0]);}
%%

int yywrap()
{return(1);}
