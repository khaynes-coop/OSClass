%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

//variables
  int yylex();
  extern char** environ;
 //functions
  void yyerror(const char *s);
  void printenv();
  void SetEnv(char* input);
  void cd(char* input);
  void cde();
%}


 
%token NUMBER WORDS GREETING NAME META NEWLINE EXITTOKEN SETENV PRINTENV CD CDE
%type <number> NUMBER
%type <sval> NEWLINE
%type <sval> WORDS
%type <sval> GREETING
%type <sval> NAME
%type <sval> META
%type <sval> EXITTOKEN
%type <sval> SETENV
%type <sval> PRINTENV
%type <sval> CD
%type <sval> CDE

%union {
  int number;
  char *sval;
}

%%

prog:
    STMTS ;
STMTS  :
 | STMT NEWLINE STMTS
 | STMT STMTS
;
STMT:
  | NUMBER                  { printf("bison found a Number: %d\n", $1); }
  | WORDS                   { printf("bison found a Word: %s\n", $1); }
  | GREETING                { printf("bison found a Greeting: %s\n", $1);  }
  | NAME                    { printf("bison found a Name: %s\n", $1); }
  | META                    { printf("bison found a Meta Val: %s\n", $1); }
  | EXITTOKEN               { printf("bison found an Exit Token"); exit(1); }
  | SETENV                  { SetEnv( $1 ); }
  | PRINTENV                { printenv(); }
  | CD                      { cd( $1 ); }
  | CDE                     { cde(); }
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

void SetEnv(char* input){
    char delim[] = " ";
    char* ptr1 = strtok(input, delim);
    char* ptr2 = strtok(NULL, delim);
    char* ptr3 = strtok(NULL, "/0");
    //printf("$2 is %s, $3 is %s", ptr2, ptr3);
    setenv(ptr2, ptr3, 1);
}

void cd(char* input) {
  int ret;
  char delim[] = " ";
    char* ptr1 = strtok(input, delim);
    char* ptr2 = strtok(NULL, "/0");
      ret = chdir(ptr2);
      if (ret != 0)
      {
        printf("no such file or directory\n");
      }
}

void cde() {
  int ret;
  ret =chdir(getenv("HOME"));
  if (ret != 0)
      {
        printf("no such file or directory\n");
      } 

}