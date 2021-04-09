%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <env.h>


//variables
  int yylex();
  char** environ;
 //functions
  void yyerror(const char *s);
  void printenv();
%}



%token NUMBER WORDS GREETING NAME META NEWLINE EXITTOKEN SETENV PRINTENV
%type <number> NUMBER
%type <sval> NEWLINE
%type <sval> WORDS
%type <sval> GREETING
%type <sval> NAME
%type <sval> META
%type <sval> EXITTOKEN
%type <sval> SETENV
%type <sval> PRINTENV

%union {
  int number;
  char *sval;
}

%%

prog:
    STMTS ;
STMTS  :
 | STMT NEWLINE STMTS
 | STMT STMT NEWLINE STMTS
 | STMT STMT STMT NEWLINE STMTS
 | NEWLINE STMTS
;
STMT:
  | NUMBER                  { printf("bison found a Number: %d\n", $1); }
  | WORDS                   { printf("bison found a Word: %s\n", $1); }
  | GREETING                { printf("bison found a Greeting: %s\n", $1);  }
  | NAME                    { printf("bison found a Name: %s\n", $1); }
  | META                    { printf("bison found a Meta Val: %s\n", $1); }
  | EXITTOKEN               { printf("bison found an Exit Token"); exit(1); }
  | SETENV WORDS WORDS      { printf("bison found input variables: %s\n %s\n ", $1, $2); setenv( $2, $3, 1); }
  | PRINTENV                { printenv(); }
  ;


  %%

  void yyerror(const char *s){
    printf("bison found an Error: %s\n", s);
    exit(1);
  }

  void printenv(){
    char **var;
    for(var = environ; *var!=NULL;++var) {
          printf("%s\n",*var);
    }
  }