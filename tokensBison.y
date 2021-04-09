%{
  #include <stdio.h>
  #include <stdlib.h>
  // Declare stuff from Flex that Bison needs to know about:
  int yylex();
  void yyerror(const char *s);

  /*NUMBER tokensBison        { printf("bison found a Number: %d\n", $1); }
      | WORDS tokensBison       { printf("bison found a Word: %s\n", $1); free($1); }
      | STRINGLIT tokensBison   { printf("bison found a String: %s\n", $1); free($1); }
      | GREETING tokensBison    { printf("bison found a Greeting: %s\n", $1); free($1); }
      | NAME tokensBison        { printf("bison found a Name: %s\n", $1); free($1); }
      | META tokensBison        { printf("bison found a Meta Val: %s\n", $1); free($1); }
      | EXITTOKEN tokensBison   { printf("bison found an Exit Token"); exit(1); }
      |
  */
%}



%token NUMBER STRINGLIT WORDS GREETING NAME META NEWLINE EXITTOKEN
%type <number> NUMBER
%type <sval> STRINGLIT
%type <sval> NEWLINE
%type <sval> WORDS
%type <sval> GREETING
%type <sval> NAME
%type <sval> META
%type <sval> EXITTOKEN

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
 | STMT STMT STMT STMTS
 | NEWLINE STMTS
;
STMT:
   NUMBER                  { printf("bison found a Number: %d\n", $1); }
  | WORDS                   { printf("bison found a Word: %s\n", $1); }
  | STRINGLIT               { printf("bison found a String: %s\n", $1);  }
  | GREETING                { printf("bison found a Greeting: %s\n", $1);  }
  | NAME                    { printf("bison found a Name: %s\n", $1); }
  | META                    { printf("bison found a Meta Val: %s\n", $1); }
  | EXITTOKEN               { printf("bison found an Exit Token"); exit(1); }
  |
  ;


  %%

  void yyerror(const char *s){
  printf("bison found an Error: %s\n", s);
  exit(1);}