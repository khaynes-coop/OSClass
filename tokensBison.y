%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <dirent.h>
  #include <errno.h>
  #include <unistd.h>
  #include <limits.h>
  #include <libgen.h>

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
  char* run_command(char* input);
  int aliasLoop(node_t** head, char* name, char* word);
  void ls(const char* input);
  void lse();
  void echo(char* words, int space);
  void aliasChecker(node_t** head, char* alias);
  void catFileOpenReadClose(char* file);
  void catDecode(char* catFile);
  void catNew(char* catFile);
%}


 



%token NUMBER WORDS GREETING NAME META NEWLINE EXITTOKEN SETENV PRINTENV UNSETENV CD CDE ALIAS RUN UNALIAS LS LSE ECHOS ECHOA CAT CATNEW
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
%type <sval> LS
%type <sval> LSE
%type <sval> ECHOS
%type <sval> ECHOA
%type <sval> CAT
%type <sval> CATNEW

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
  | WORDS                   { aliasChecker( &aliasHead, $1); }
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
  | LS                      { ls( $1 ); }
  | LSE                     { lse(); }
  | ECHOS                   { echo( $1 , 0); }
  | ECHOA                   { echo( $1 , 1); }
  | CAT                     { catDecode( $1 ); }
  | CATNEW                  { catNew( $1 ); }
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
    char* expInput = run_command(input);
    char delim[] = " ";
    char* ptr1 = strtok(expInput, delim);
    char* ptr2 = strtok(NULL, delim);
    char* ptr3 = strtok(NULL, "/0");
    //printf("$2 is %s, $3 is %s", ptr2, ptr3);
    setenv(ptr2, ptr3, 1);
}

void cd(char* input) {
  char* expInput = run_command(input);
  int ret;
  char delim[] = " ";
    char* ptr1 = strtok(expInput, delim);
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
    char* expInput = run_command(expInput);
    char delim[] = " ";
    char* ptr1 = strtok(input, delim);
    char* ptr2 = strtok(NULL, "/0");
    //printf("$1 is %s, $2 is %s", ptr1, ptr2);
    unsetenv(ptr2);
}

void aliasFun(char* toAlias){
  char* expInput = run_command(toAlias);
char delim[] = " ";
    char* ptr1 = strtok(expInput, delim);
    char* ptr2 = strtok(NULL, delim);
    char* ptr3 = strtok(NULL, "/0");
    if(ptr2 == NULL && ptr3 == NULL){
    printAlias( aliasHead);
    }
    else if(ptr2 != NULL && ptr3 != NULL){
    if(aliasLoop(&aliasHead, ptr2, ptr3) == 0){
    assignAlias(&aliasHead, ptr2, ptr3);}
    else{printf("Name may cause an infinite loop\n");}
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

char* run_command(char* input)
{
    char* temp = input;
    char* newInput;
    newInput = malloc(256);
      for (int i = 0; i < strlen(temp); i++)
      {
        int terminated = 0;
        char* oldW;
        oldW = malloc(256);
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
        strncat(newInput, &temp[i], 1);
      }
      return newInput;
}

void unAssignAlias(node_t** head, char* name){
char delim[] = " ";
    char* ptr1 = strtok(name, delim);
    char* ptr2 = strtok(NULL, "/0");
    ptr2 = run_command(ptr2);
    if(ptr2 != NULL){removeAlias( &aliasHead, ptr2);}
    else{
    printf("Too many/few arguments");}
}

int aliasLoop(node_t** head, char* name, char* word){
node_t* current = *head;
    node_t* prev = NULL;
    while (1) {
        if (current == NULL){ return 0;}

        if (strcmp(current->alias, word) == 0){
        if(strcmp(current->val, name) == 0 ){
        return -1;}
        else{
        return aliasLoop(head, name, current->val); }

        }
        prev = current;
        current = current->next;
    }


}
void ls(const char* input) {
  char* newInput = run_command(input);
  char delim[] = " ";
    char* ptr1 = strtok(newInput, delim);
    char* ptr2 = strtok(NULL, "/0");
  struct dirent *dir;
  DIR *dh;
  if (strcmp(ptr2,".") == 0)
  {
    char* cwd;
    cwd = malloc(256);
    cwd = getcwd(cwd, 256);
    cwd = basename(cwd);
    chdir("..");
    dh = opendir(cwd);
    chdir(cwd);
  }
  else if (strcmp(ptr2,"..") == 0)
  {
    char* innercwd;
    innercwd = malloc(256);
    innercwd = getcwd(innercwd, 256);
    innercwd = basename(innercwd);
    chdir("..");
    char* cwd;
    cwd = malloc(256);
    cwd = getcwd(cwd, 256);
    cwd = basename(cwd);
    chdir("..");
    dh = opendir(cwd);
    chdir(cwd);
    chdir(innercwd);
  }
  else
  {
    dh = opendir(ptr2);
  }
  if (!dh)
  {
    if (errno = ENOENT)
    {
      printf("Directory doesn't exist\n");
    }
    else
    {
      printf("Unable to read directory\n");
    }
    return;
  }
  dir = readdir(dh);
 while (dir != NULL)
  {
    printf("%s\n", dir->d_name);
    dir = readdir(dh);
  }
}

void lse()
{
  struct dirent *dir;
  DIR *dh;
  char* cwd;
    cwd = malloc(256);
    cwd = getcwd(cwd, 256);
    cwd = basename(cwd);
    chdir("..");
    dh = opendir(cwd);
    chdir(cwd);
    dir = readdir(dh);
 while (dir != NULL)
  {
    printf("%s\n", dir->d_name);
    dir = readdir(dh);
  }
  }
void echo(char* words, int space){

if(space == 0){ char delim[] = "\"";
char* ptr1 = strtok(words, delim);
    char* ptr2 = strtok(NULL, delim);
    printf("%s\n", ptr2);}
else if (space == 1){
char delim[] = " ";
char* ptr1 = strtok(words, delim);
    char* ptr2 = strtok(NULL, "\0");
    printf("%s\n", ptr2);}
}

void aliasChecker( node_t** head, char* alias){

node_t* current = *head;
    node_t* prev = NULL;
    while (1) {
        if (current == NULL){ printf("%s\n", alias); return;}//print/execute alias
        if (strcmp(current->alias, alias) == 0){ aliasChecker(head, current->val); return;}
        prev = current;
        current = current->next;
    }


}

void catFileOpenReadClose(char* file){
FILE *filePointer;

if((filePointer = fopen(file, "r") )== NULL){
printf("no such filename\n");
return;
}
int c;
while ((c = getc(filePointer)) != EOF)
        putchar(c);
fclose(filePointer);
printf("\n");
}

void catDecode(char* catFile){
char delim[] = " ";
char* ptr1 = strtok(catFile, delim);
    char* ptr2 = strtok(NULL, delim);
    char* ptr3 = strtok(NULL, "/0");


    if(ptr2 != NULL && ptr3 == NULL){
    catFileOpenReadClose(ptr2);
    }
}

void catNew(char* catFile){
    char delim[] = " ";
    //printf("%s", catFile);
    char* ptr1 = strtok(catFile, delim);
    char* ptr2 = strtok(NULL, ">");


    FILE *filePointer;
    filePointer = fopen(ptr2, "w");
    fclose(filePointer);

    if((filePointer = fopen(ptr2, "r") ) != NULL){ printf("Successfully created file %s\n", ptr2);}
    else{ printf("Did not create file %s\n", ptr2);}

}