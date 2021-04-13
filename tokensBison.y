%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

//variables
  int yylex();
  extern char** environ;

  //Alias Structure
  typedef struct node {
      char* alias;
      char* val;
      struct node* next;
  } node_t;
  node_t* aliasHead; //points to aliases

 //functions
  void yyerror(const char *s);
  void printenv();
  void SetEnv(char* input);
  void cd(char* input);
  void cde();
  void UnSetEnv(char* input);
  void aliasFun(char* toAlias);
  void printAlias(node_t* head);
  void assignAlias(node_t** head, char* name, char* word);
  void removeAlias(node_t** head, char* name);
  void unAssignAlias(node_t** head, char* name);
  void run_command(char* input);
%}


 



%token NUMBER WORDS GREETING NAME META NEWLINE EXITTOKEN SETENV PRINTENV UNSETENV CD CDE ALIAS RUN UNALIAS
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
%type <sval> ALIAS
%type <sval> UNALIAS
%type <sval> UNSETENV
%type <sval> RUN

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
  | EXITTOKEN               { printf("bison found an Exit Token\n"); exit(1); }
  | SETENV                  { SetEnv( $1 ); }
  | UNSETENV                { UnSetEnv( $1 ); }
  | PRINTENV                { printenv(); }
  | CD                      { cd( $1 ); }
  | ALIAS                   { aliasFun( $1 ); }
  | UNALIAS                 { unAssignAlias(&aliasHead,  $1 ); }
  | CDE                     { cde(); }
  | RUN                     { run_command($1);}
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
  if (ret != 0){
        printf("no such file or directory\n");
      } 
}

void UnSetEnv(char* input){
    char delim[] = " ";
    char* ptr1 = strtok(input, delim);
    char* ptr2 = strtok(NULL, "/0");
    //printf("$1 is %s, $2 is %s", ptr1, ptr2);
    unsetenv(ptr2);
}

void aliasFun(char* toAlias){
char delim[] = " ";
    char* ptr1 = strtok(toAlias, delim);
    char* ptr2 = strtok(NULL, delim);
    char* ptr3 = strtok(NULL, "/0");
    if(ptr2 == NULL && ptr3 == NULL){
    printAlias( aliasHead);
    }
    else if(ptr2 != NULL && ptr3 != NULL){
    assignAlias(&aliasHead, ptr2, ptr3);
    }
    else{
    printf("too many/few arguments\n");
    }
}

void printAlias(node_t* head){
    node_t* current = head;
    while (current != NULL){
        printf("alias %s='%s'\n", current->alias, current->val); //prints out the aliases by looping
        current = current->next;
    }
}

void assignAlias(node_t** head, char* alias, char* val) {
    node_t* current = *head;
    node_t* newNode = malloc(sizeof(node_t));
    newNode->alias = alias;
    newNode->val = val;
    newNode->next = NULL;
    if (current != NULL){
        while (current->next != NULL && strcmp(current->alias, alias) != 0)
        {
            current = current->next;
        }
        if (strcmp(current->alias, alias) == 0)
        {
            current->val = val;
            free(newNode);
            return;
        }
        current->next = newNode;
    }
    else
    {
        *head = newNode;
    }
}

void removeAlias(node_t** head, char* name) {
    node_t* current = *head;
    node_t* prev = NULL;
    while (1) {
        if (current == NULL){ printf("%s is not an alias\n", name); return;}
        if (strcmp(current->alias, name) == 0) break;
        prev = current;
        current = current->next;
    }
    if (current == *head) *head = current->next;
    if (prev != NULL) prev->next = current->next;
    free(current);
    return 0;
}

void run_command(char* input)
{
    char* temp = input;
    char* newInput[256];
      for (int i = 0; i < strlen(temp); i++)
      {
        int terminated = 0;
        char* oldW[256];
        if (temp[i] == '$' && temp[i+1] == '{')
        {
          for(int j = i+2; j < strlen(temp); j++)
          {
            if (temp[j] != '}')
            {
              strncat(oldW, &temp[j], 1);
              continue;
            }
            terminated = 1;
            break;
          }
          if (terminated = 1)
          {
            if (getenv(oldW) != NULL)
            {
              strcat(newInput, getenv(oldW));
              i += strlen(oldW) + 3;
            }
            else
            {
              strncat(newInput, '$', 1);
              strncat(newInput, '{', 1);
              strcat(newInput, oldW);
              strncat(newInput, '}', 1);
              i+= strlen(oldW) + 3;
            }
          }
          else
          {
            strncat(newInput, temp[i], 1);
            continue;
          }
        }
        strncat(newInput, temp[i], 1);
      }
      printf(newInput);
      printf("\n");
}

void unAssignAlias(node_t** head, char* name){
char delim[] = " ";
    char* ptr1 = strtok(name, delim);
    char* ptr2 = strtok(NULL, "/0");
    if(ptr2 != NULL){removeAlias( &aliasHead, ptr2);}
    else{
    printf("Too many/few arguments");}
}