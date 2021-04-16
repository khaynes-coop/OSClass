%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <dirent.h>
  #include <errno.h>
  #include <unistd.h>
  #include <limits.h>
  #include <libgen.h>
  #include <time.h>

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
  void SetEnv(char* input, int pass);
  char* cd(char* input);
  char* cde();
  void UnSetEnv(char* input, int pass);
  void aliasFun(char* toAlias, int pass);
  void printAlias(node_t* head);
  void assignAlias(node_t** head, char* name, char* word);
  void removeAlias(node_t** head, char* name);
  void unAssignAlias(node_t** head, char* name);
  char* run_command(char* input);
  int aliasLoop(node_t** head, char* name, char* word);
  char* ls(const char* input);
  char* lse();
  char* echo(char* words, int space);
  void aliasChecker(node_t** head, char* alias);
  void catFileOpenReadClose(char* file);
  void catOpenReadClose(char* file, char* file2);
  void catDecode(char* catFile);
  void catNew(char* catFile);
  void catApp(char* catFile, int open);
  void aliasFunctionsPrint(char* aliasString);
  char* pwd();
  char* wc(char* input);
  char** sortStrings(char* input);
    unsigned long int fileLineCount(char* file);
    void sortfile(char **array, int linecount);
  char* date();
    char* sortNotFile(char* input);
    char* pipeFunction(char* pipesBars);
  char* grep(char* input);
%}


 




%token NUMBER WORDS GREETING NAME META NEWLINE EXITTOKEN SETENV SETENVQ PRINTENV UNSETENV UNSETENVP ALIASC CD CDE ALIAS RUN UNALIAS LS LSE ECHOS ECHOA CAT CATNEW CATAPP CATW ALIASA ALIASP PWD WC SORT DATE PIPPET GREP

%type <number> NUMBER
%type <sval> SORT
%type <sval> PIPPET
%type <sval> NEWLINE
%type <sval> WORDS
%type <sval> GREETING
%type <sval> NAME
%type <sval> META
%type <sval> EXITTOKEN
%type <sval> SETENV
%type <sval> SETENVQ
%type <sval> PRINTENV
%type <sval> CD
%type <sval> CDE
%type <sval> ALIAS
%type <sval> ALIASA
%type <sval> ALIASP
%type <sval> ALIASC
%type <sval> UNALIAS
%type <sval> UNSETENV
%type <sval> UNSETENVP
%type <sval> RUN
%type <sval> LS
%type <sval> LSE
%type <sval> ECHOS
%type <sval> ECHOA
%type <sval> CAT
%type <sval> CATW
%type <sval> CATNEW
%type <sval> CATAPP
%type <sval> PWD
%type <sval> WC
%type <sval> DATE
%type <sval> GREP

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
  | SETENV                  { SetEnv( $1, 0 ); }
  | SETENVQ                 { SetEnv( $1, 1 ); }
  | UNSETENV                { UnSetEnv( $1, 0 ); }
  | UNSETENVP               { UnSetEnv( $1, 1 ); }
  | PRINTENV                { printenv(); }
  | CD                      { cd( $1 ); }
  | ALIAS                   { aliasFun( $1 , 0); }
  | ALIASA                  { aliasFun( $1 , 1); }
  | ALIASP                  { aliasFun( $1 , -1); }
  | ALIASC                  { aliasFun( $1 , -2); }
  | UNALIAS                 { unAssignAlias(&aliasHead,  $1 ); }
  | CDE                     { cde(); }
  | LS                      { char* p = ls( $1 ); printf("%s", p); }
  | LSE                     { char* p = lse(); printf("%s", p); }
  | ECHOS                   { char* p = echo( $1 , 0); printf("%s", p);}
  | ECHOA                   { char* p = echo( $1 , 1); printf("%s", p); }
  | CAT                     { catDecode( $1 ); }
  | CATNEW                  { catNew( $1 ); }
  | CATAPP                  { catApp( $1, 0 ); }
  | CATW                    { catApp( $1, 1 ); }
  | PWD                     { pwd(); }
  | WC                      { char* print = wc( $1 ); printf("%s", print);}
  | SORT                    { char** print = sortStrings( $1 ); int j = atoi(print[0]); if (j > 0){j++; for(int c = 1; c < j; c++) printf("%s", print[c]); printf("\n");} else printf("%s\n",  print[0]);}
  | DATE                    { date(); }
  | PIPPET                  { pipeFunction( $1 ); }
  | GREP                    { grep( $1); }
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

void SetEnv(char* input, int pass){
    char* expInput = run_command(input);
    char* delim;
        char* ptr1;
        char* ptr2;
        char* ptr3;
    if (pass == 1){
            delim = " ";
             ptr1 = strtok(input, delim);
             ptr2 = strtok(NULL, delim);
             ptr3 = strtok(NULL, "\"");
             //printf("$2 is %s, $3 is %s", ptr2, ptr3);
    }
    else{
         delim = " ";
         ptr1 = strtok(expInput, delim);
         ptr2 = strtok(NULL, delim);
         ptr3 = strtok(NULL, "/0");}

    //printf("$2 is %s, $3 is %s", ptr2, ptr3);
    setenv(ptr2, ptr3, 1);
}

char* cd(char* input) {
  char* newInput = run_command(input);
  int ret = 1;
  char delim[] = " ";
  char* ptr1 = strtok(newInput, delim);
  char* ptr2 = strtok(NULL, " ");
  char* cwd;
  cwd = malloc(2000);
  cwd = getcwd(cwd, 2000);
  if (ptr2[0] == '/')
  {
    chdir("/");
  }
  ret = chdir(ptr2);
  if (ret != 0)
  {
    return("Error no such file or directory\n");
  }
  else
  {
    cwd = getcwd(cwd, 2000);
    setenv("PWD", cwd, 1);
    return("");
  }
}

char* cde() {
  int ret;
  ret =chdir(getenv("HOME"));
  if (ret != 0)
  {
    return("Error no such file or directory\n");
  } 
  else
  {
    char* cwd;
    cwd = malloc(256);
    cwd = getcwd(cwd, 256);
    setenv("PWD", cwd, 1);
    return("");
  }
}

void UnSetEnv(char* input, int pass){

    char delim[] = " ";
    char* ptr1 = strtok(input, delim);
    char* ptr2 = strtok(NULL, "/0");
    //printf("$1 is %s, $2 is %s", ptr1, ptr2);
    if(pass == 1){ptr2 = run_command(ptr2);}
    unsetenv(ptr2);
}

void aliasFun(char* toAlias, int pass){

  char* delim;
  char* ptr1;
  char* ptr2;
  char* ptr3;
  if(pass == 1){delim = "\"";
  ptr1 = strtok(toAlias, " ");
  ptr2 = strtok(NULL, " ");
  ptr3 = strtok(NULL, delim);
  //printf("%s ptr1, %s ptr2, %s ptr3", ptr1, ptr2, ptr3);
  }
  else if(pass == -1){delim = " ";
      ptr1 = strtok(toAlias, delim);
      ptr2 = strtok(NULL, delim);
      char* val = strtok(NULL, "/0");
      ptr3 = run_command(val);}
      else if(pass == -2){delim = " ";
            ptr1 = strtok(toAlias, delim);
            char* val = strtok(NULL, delim);
            ptr3 = strtok(NULL, "/0");
            ptr2 = run_command(val);}
  else{delim = " ";
    ptr1 = strtok(toAlias, delim);
    ptr2 = strtok(NULL, delim);
    ptr3 = strtok(NULL, "/0");}
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
    return;
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
char* ls(const char* input) {
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
      return("Error directory doesn't exist\n");
    }
    else
    {
      return("Error unable to read directory\n");
    }
    return("");
  }
  char* returnstring;
  returnstring = (char* )malloc(sizeof(node_t)* 100);
  dir = readdir(dh);
 while (dir != NULL)
  {
    strcat(returnstring, dir->d_name);
    strcat(returnstring, "\n");
    dir = readdir(dh);
  }
  return returnstring;
}

char* lse()
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
    char* returnstring;
    returnstring = (char* )malloc(sizeof(node_t)* 100);
 while (dir != NULL)
  {
    strcat(returnstring, dir->d_name);
    strcat(returnstring, "\n");
    //printf("%s\n", dir->d_name);
    dir = readdir(dh);
  }
  return returnstring;
  }
char* echo(char* words, int space){

if(space == 0){ char delim[] = "\"";
char* ptr1 = strtok(words, delim);
    char* ptr2 = strtok(NULL, delim);
    char* ptr3 = run_command(ptr2);
    return ptr3;}

else if (space == 1){
char delim[] = " ";
char* ptr1 = strtok(words, delim);
    char* ptr2 = strtok(NULL, "\0");
    char* ptr3 = run_command(ptr2);
        return ptr3;}
}

void aliasChecker( node_t** head, char* alias){

node_t* current = *head;
    node_t* prev = NULL;
    while (1) {
        if (current == NULL){ char* print = run_command(alias); aliasFunctionsPrint(print); return;}//print/execute alias
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
    if(ptr2 != NULL && ptr3 != NULL){
        catOpenReadClose(ptr2, ptr3);
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

void catOpenReadClose(char* file, char* file2){

FILE *filePointer;

if((filePointer = fopen(file, "r") )== NULL){
printf("no such filename %s\n", file);
return;
}
else{
int c;
while ((c = getc(filePointer)) != EOF)
        putchar(c);}
fclose(filePointer);

if((filePointer = fopen(file2, "r") )== NULL){
printf("no such filename %s\n", file2);
return;
}
else{
int c;
while ((c = getc(filePointer)) != EOF)
        putchar(c);}
fclose(filePointer);
printf("\n");


}

void catApp(char* catFile, int open){
    char delim[] = " ";
    //printf("%s\n", catFile);
    char* ptr1 = strtok(catFile, delim);
    char* ptr2 = strtok(NULL, delim);
    char* ignorw = strtok(NULL, delim);
    char* ptr3 = strtok(NULL, "\0");
char* write;
//open f2 in write, f1 in read, write each char of f1 to f2
if(open == 0){write = "a";}
else{write = "w";}

FILE *f1;
FILE *f2;
if((f1 = fopen(ptr2, "r") )== NULL){
printf("no such filename %s\n", ptr2);
fclose(f1);
return;
}
else{
if((f2 = fopen(ptr3, write) ) != NULL){
    int c;
    while ((c = getc(f1)) != EOF){
        fputc(c, f2);}
}
 else{printf("Unexpected error\n" );}
fclose(f2);
fclose(f1);
}}

void aliasFunctionsPrint(char* aliasString){

printf("%s\n", aliasString);
}

char* pwd() {
  char* cwd;
    cwd = malloc(256);
    cwd = getcwd(cwd, 256);
    strcat(cwd, "\n");
    return cwd;
}

char* wc(char* input) {
  char* buf;
  char* newInput = run_command(input);
  int lflag = 0, wflag = 0, cflag = 0;
  int totlines = 0, totwords = 0, totchars = 0, fcount = 0;
  char delim[] = " ";
  char* ptr1 = strtok(newInput, delim);
  char* returnstring;
  returnstring = malloc(sizeof(node_t));
  ptr1 = strtok(NULL, delim);
  while (ptr1 != NULL)
  {
    if (ptr1[0] == '-')
    {
      for (int i = 1; i < strlen(ptr1); i++)
      { 
        if (ptr1[i] == 'l')
          lflag = 1;
        else if (ptr1[i] == 'w')
          wflag = 1;
        else if (ptr1[i] == 'c')
          cflag = 1;
      }
    }
    else
    {
      fcount++;
      FILE *file;
      char ch;
      buf = malloc(256);
      int lines =  0, words = 1, chars = 0, word = 0;
      if ((file = fopen(ptr1, "r")) == NULL)
      {
        return("Error no such filename\n");
      }
      else
      {
        while ((ch = fgetc(file)) != EOF)
        {
          chars++;
          if (ch == ' ' || ch == '\t' || ch == '\0' || ch == '\n')
          {
            if (word == 1)
            {
              word = 0;
              words++;
            } 
          }
          if (ch == '\0' || ch == '\n')
            lines++;
          else
            word = 1;
        }
      if (lflag == 1 && wflag == 0 && cflag == 0)
        {
          sprintf(buf, "%d", lines);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          strcat(returnstring, ptr1);
          strcat(returnstring, "\n");
        }
      else if (lflag == 1 && wflag == 1 && cflag == 0)
        {
          sprintf(buf, "%d", lines);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          sprintf(buf, "%d", words);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          strcat(returnstring, ptr1);
          strcat(returnstring, "\n");
        }
      else if (lflag == 1 && wflag == 0 && cflag == 1)
        {
          sprintf(buf, "%d", lines);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          sprintf(buf, "%d", chars);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          strcat(returnstring, ptr1);
          strcat(returnstring, "\n");
        }
      else if (lflag == 0 && wflag == 1 && cflag == 0)
      {
          sprintf(buf, "%d", words);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          strcat(returnstring, ptr1);
          strcat(returnstring, "\n");
        }
      else if (lflag == 0 && wflag == 1 && cflag == 1)
        {
          sprintf(buf, "%d", words);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          sprintf(buf, "%d", chars);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          strcat(returnstring, ptr1);
          strcat(returnstring, "\n");
        }
      else if (lflag == 0 && wflag == 0 && cflag == 1)
        {
          sprintf(buf, "%d", chars);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          strcat(returnstring, ptr1);
          strcat(returnstring, "\n");
        }
      else
        {
          sprintf(buf, "%d", lines);
          strcat(returnstring, buf);
          strcat(returnstring, " ");
          sprintf(buf, "%d", words);
          strcat(returnstring, buf);
          strcat(returnstring, " ");
          sprintf(buf, "%d", chars);
          strcat(returnstring, buf);
          strcat(returnstring, " ");
          strcat(returnstring, ptr1);
          strcat(returnstring, "\n");
        }
      totlines += lines;
      totwords += words;
      totchars += chars;
      fclose(file);
      }
    }
    ptr1 = strtok(NULL, delim);
  }
  if (fcount > 1)
  {
    if (lflag == 1 && wflag == 0 && cflag == 0)
        {
          sprintf(buf, "%d", totlines);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          strcat(returnstring, "total\n");
        }
      else if (lflag == 1 && wflag == 1 && cflag == 0)
        {
          sprintf(buf, "%d", totlines);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          sprintf(buf, "%d", totwords);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          strcat(returnstring, "total\n");
        }
      else if (lflag == 1 && wflag == 0 && cflag == 1)
        {
          sprintf(buf, "%d", totlines);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          sprintf(buf, "%d", totchars);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          strcat(returnstring, "total\n");
        }
      else if (lflag == 0 && wflag == 1 && cflag == 0)
        {
          sprintf(buf, "%d", totwords);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          strcat(returnstring, "total\n");
        }
      else if (lflag == 0 && wflag == 1 && cflag == 1)
        {
          sprintf(buf, "%d", totwords);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          sprintf(buf, "%d", totchars);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          strcat(returnstring, "total\n");
        }
      else if (lflag == 0 && wflag == 0 && cflag == 1)
        {
          sprintf(buf, "%d", totchars);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          strcat(returnstring, "total\n");
        }
      else
        {
          sprintf(buf, "%d", totlines);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          sprintf(buf, "%d", totwords);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          sprintf(buf, "%d", totchars);
strcat(returnstring, buf);
          strcat(returnstring, " ");
          strcat(returnstring, "total\n");
        }
  }
  return returnstring;
}

char** sortStrings(char* input){
char* ptr3 = NULL;
    char* delim = " ";

    char* ptr1 = strtok(input, delim); //sort
    strtok(NULL, delim);
    char* ptr2 = strtok(NULL, delim); // file 1

    if(strtok(NULL, delim) != NULL){
    ptr3 = strtok(NULL, "/0"); //file 2
    //printf("$2 is %s, $3 is %s", ptr2, ptr3);
    }

     unsigned long int linecount = fileLineCount(ptr2);
        char **array = (char**)malloc(linecount * sizeof(char*));
        char singleline[4096];
FILE *filePointer;

    if((filePointer = fopen(ptr2, "r") )== NULL){
        printf("no such filename\n");
        fclose(filePointer);
        char** ret =(char**)malloc(sizeof(char*) * 4);
        char* set = "Error: No Such File";
        ret[0] = set;
        return ret;
    }
        int i = 1;
        array[0] = (char*) malloc (4096 * sizeof(char));
        sprintf(array[0], "%lu", linecount);

            while(fgets(singleline, 4096, filePointer) != NULL)
            {
                array[i] = (char*) malloc (4096 * sizeof(char));
                singleline[4095] = '\0';
                strcpy(array[i], singleline);
                i++;
            }

sortfile(array, linecount);
fclose(filePointer);
        if(ptr3 != NULL){
        FILE *FukinFile = NULL;
        //print to the file
        if((FukinFile = fopen(ptr3, "w+") )== NULL){
        char** ret =(char**)malloc(sizeof(char*) * 4);
                     ret[0] = "Error Opening file";
                     return ret;
        }

        //for(int c = 1; c < linecount +1; c++) printf("%s", array[c]);

        for(int i = 1; i < linecount + 1; i++){
        fprintf(FukinFile, "%s", array[i]);
        }

        fclose(FukinFile);

            char** ret =(char**)malloc(sizeof(char*) * 4);
             ret[0] = ptr3;
             return ret;
        }
        else{

        return array;
        }
}

unsigned long int fileLineCount(char* file){
FILE *fp = fopen(file, "r");
    unsigned long int linecount = 0;
    int c;
    if(fp == NULL){
        fclose(fp);
        return 0;
    }
    while((c=fgetc(fp)) != EOF )
    {
        if(c == '\n')
            linecount++;
    }
    fclose(fp);
    linecount++;
    return linecount;

}

void sortfile(char **array, int linecount){
    int i, j;
    char t[4096];
    for(i=1; i < linecount;i++)
    {
        for(j=1; j < linecount; j++)
        {
            if(strcmp(array[j-1], array[j]) > 0)
            {
                strcpy(t, array[j-1]);
                strcpy(array[j-1], array[j]);
                strcpy(array[j], t);
            }
        }
    }
}

char* date()
{
  time_t t = time(NULL);
  return(asctime(localtime(&t)));
}

char* sortNotFile(char* input){

char tempstr[strlen(input) + 1];
strncpy(tempstr, input, sizeof(tempstr));
printf("%s", input);
    char* delim = "\n";
    unsigned long int numNewLine = 0;
    char* token = strtok(tempstr, delim);

    while(token != NULL){
    numNewLine = numNewLine + 1;
    token = strtok(NULL, delim);
    }
    if(numNewLine == 0){return input;}

    char **array = (char**)malloc(numNewLine * sizeof(char*));
    char* singleline;
         singleline = strtok(input, delim);
    for(int i = 0; i < numNewLine; i++){
    array[i] = singleline;
    singleline = strtok(NULL, delim);
    }

sortfile(array, numNewLine);
strcpy(input, array[0]);
        for(int i = 1; i < numNewLine; i++){
        strcat(input, "\n");
        strcat(input, array[i]);
        }

        return input;

}

char* pipeFunction(char* pipesBars){
char tempstr[strlen(pipesBars) + 1];
strncpy(tempstr, pipesBars, sizeof(tempstr));
    char* delim = "|";
    unsigned long int numBar = 0;
    //printf("%s\n", tempstr);
    char* token = strtok(tempstr, delim);

    while(token != NULL){
    numBar= numBar + 1;
                token = strtok(NULL, delim);}
 //printf("%s\n", pipesBars);
char **array = (char**)malloc(numBar * sizeof(char*));
    char* singleline;
     singleline = strtok(pipesBars, delim);
    for(int i = 0; i < numBar; i++){
    array[i] = singleline;
    singleline = strtok(NULL, delim);
    }

    for(int i = 1; i < numBar; i++){
    array[i]++;
           //printf("%lu: %s\n", numBar, array[i]);
            }
   char currVal[4096];
   char prevVal[4096];
   printf("%s\n",  array[0]);
for(int i = 0; i < numBar; i++){

strncpy(prevVal, currVal, sizeof(prevVal));
if(strncmp("echo ", &array[i], 4) == 0){
char* print = echo(array[i], 1);
printf("%s", print);
strncpy(currVal, print, sizeof(currVal));
}
else if(strncmp("ls ", array[i], 3) == 0){
char* print = lse();
//printf("%s", print);
strncpy(currVal, print, sizeof(currVal));
}
else if(strncmp("sort", array[i], 4) == 0){
strncpy(currVal, sortNotFile(prevVal), sizeof(currVal));
}
else if(strncmp("wc ", array[i], 2) == 0){
char* print = wc(array[i]);
strncpy(currVal, print, sizeof(currVal));
}

}

printf("%s\n", currVal);
}

char* grep(char* input)
{
  FILE *f;
  char* returnstring;
  returnstring = malloc(sizeof(node_t));
  char delim[] = " ";
  char* ptr1 = strtok(input, delim);
  char* ptr2 = strtok(NULL, delim);
  ptr1 = strtok(NULL, delim);
  while (ptr1 != NULL)
  {
    if(strstr(ptr1, ".txt"))
    {
      if ((f = fopen(ptr1, "r")) == NULL)
      {
        printf("Error no such filename\n");
        return "";
      }
      const char* line;
      line = malloc(4096);
      while(fgets(line, sizeof(line), f) != NULL)
      {
        if (line != NULL && strstr(line, ptr2) != NULL)
        {
         strcat(returnstring, ptr1);
         strcat(returnstring, "\n");
        }
      }
      fclose(f);
    }
    ptr1 = strtok(NULL, delim);
  }
  return(returnstring);
}