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
  char* commandChecker(char* input);
  char* printenv();
  void SetEnv(char* input, int pass);
  char* cd(char* input);
  char* cde();
  void UnSetEnv(char* input, int pass);
  char* aliasFun(char* toAlias, int pass);
  char* printAlias(node_t* head);
  void assignAlias(node_t** head, char* name, char* word);
  void removeAlias(node_t** head, char* name);
  void unAssignAlias(node_t** head, char* name);
  char* run_command(char* input);
  int aliasLoop(node_t** head, char* name, char* word);
  char* ls(const char* input);
  char* lse();
  char* echo(char* words, int space);
  void aliasChecker(node_t** head, char* alias);
  char* catFileOpenReadClose(char* file);
  char* catOpenReadClose(char* file, char* file2);
  char* catDecode(char* catFile);
  char* catNew(char* catFile);
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
  char* rev(char* input);
  char* writeAppend(char* input, int type);
  char* echoFile(char* input, int type);
  void printDollarSign(){printf("$:");}
%}


 




%token NUMBER WORDS ECHOWRITE ECHOAPPEND GREETING NAME META NEWLINE WRITEOVER APPENDTO EXITTOKEN SETENV SETENVQ PRINTENV UNSETENV UNSETENVP ALIASC CD CDE ALIAS RUN UNALIAS LS LSE ECHOS ECHOA CAT CATNEW CATAPP CATW ALIASA ALIASP PWD WC SORT DATE PIPPET GREP REV

%type <number> NUMBER
%type <sval> ECHOWRITE
%type <sval> ECHOAPPEND
%type <sval> WRITEOVER
%type <sval> APPENDTO
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
%type <sval> REV

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
  | NUMBER                  { printf("bison found a Number: %d\n", $1); printDollarSign();}
  | WORDS                   { aliasChecker( &aliasHead, $1); printDollarSign();}
  | GREETING                { printf("bison found a Greeting: %s\n", $1);  printDollarSign();}
  | NAME                    { printf("bison found a Name: %s\n", $1); printDollarSign();}
  | META                    { printf("bison found a Meta Val: %s\n", $1); printDollarSign();}
  | EXITTOKEN               { printf("bison found a bye! <3\n"); exit(1); printDollarSign();}
  | SETENV                  { SetEnv( $1, 0 ); printDollarSign();}
  | SETENVQ                 { SetEnv( $1, 1 ); printDollarSign();}
  | UNSETENV                { UnSetEnv( $1, 0 ); printDollarSign();}
  | UNSETENVP               { UnSetEnv( $1, 1 ); printDollarSign();}
  | PRINTENV                { char* print = printenv(); printf("%s", print); printDollarSign();}
  | CD                      { cd( $1 ); printDollarSign();}
  | ALIAS                   { char* print = aliasFun( $1 , 0); printf("%s", print); printDollarSign();}
  | ALIASA                  { char* print = aliasFun( $1 , 1); printf("%s", print); printDollarSign();}
  | ALIASP                  { char* print = aliasFun( $1 , -1); printf("%s", print); printDollarSign();}
  | ALIASC                  { char* print = aliasFun( $1 , -2); printf("%s", print); printDollarSign();}
  | UNALIAS                 { unAssignAlias(&aliasHead,  $1 ); printDollarSign();}
  | CDE                     { cde(); printDollarSign();}
  | LS                      { char* p = ls( $1 ); printf("%s\n", p); printDollarSign();}
  | LSE                     { char* p = lse(); printf("%s\n", p); printDollarSign();}
  | ECHOWRITE               { echoFile($1, 1); printDollarSign();}
  | ECHOAPPEND              { echoFile($1, 0); printDollarSign();}
  | ECHOS                   { char* p = echo( $1 , 0); printf("%s\n", p); printDollarSign();}
  | ECHOA                   { char* p = echo( $1 , 1); printf("%s\n", p); printDollarSign();}
  | CAT                     { char* print = catDecode( $1 ); printf("%s\n", print); printDollarSign();}
  | CATNEW                  { char* print =catNew( $1 ); printf("%s\n", print); printDollarSign();}
  | CATAPP                  { catApp( $1, 0 ); printDollarSign();}
  | CATW                    { catApp( $1, 1 ); printDollarSign();}
  | PWD                     { pwd(); printDollarSign();}
  | WC                      { char* print = wc( $1 ); printf("%s\n", print); printDollarSign(); printDollarSign();}
  | SORT                    { char** print = sortStrings( $1 ); int j = atoi(print[0]); if (j > 0){j++; for(int c = 1; c < j; c++) printf("%s", print[c]); printf("\n");} else printf("%s\n",  print[0]); printDollarSign();}
  | DATE                    { date(); printDollarSign();}
  | PIPPET                  { pipeFunction( $1 ); printDollarSign();}
  | GREP                    { grep( $1); printDollarSign();}
  | REV                     { char* print = rev( $1 ); printf("%s\n", print); printDollarSign();}
  | WRITEOVER               { writeAppend($1, 1); printDollarSign();}
  | APPENDTO                { writeAppend($1, 0); printDollarSign();}
  ;


  %%

  void yyerror(const char *s){
    printf("bison found an Error: %s\n", s);
    exit(1);
  }

  char* printenv(){
  char* ptr4;
  ptr4 = malloc(sizeof(char*) * 800);
    char **var;
    for(var = environ; *var!=NULL;var++) {
    strcat(ptr4, *var);
    strcat(ptr4, "\n");
          //printf("%s\n",*var);
    }
    return ptr4;
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

char* aliasFun(char* toAlias, int pass){
char* ptr4;
ptr4 = malloc(sizeof(char*) * 400);
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
    ptr4 = printAlias( aliasHead);

    }

    else if(ptr2 != NULL && ptr3 != NULL){
    if(aliasLoop(&aliasHead, ptr2, ptr3) == 0){
    assignAlias(&aliasHead, ptr2, ptr3);
    strcat(ptr4, "\n");}
    else{strcat(ptr4, "Name may cause an infinite loop\n");}
    }
    else{
    strcat(ptr4, "too many/few arguments\n");
    }
    return ptr4;
}

char* printAlias(node_t* head){
char* ptr4;
ptr4 = malloc(sizeof(char*) * 400);
    node_t* current = head;
    while (current != NULL){
    strcat(ptr4, current->alias);
    strcat(ptr4, "=");
    strcat(ptr4, current->val);
    strcat(ptr4, "\n");
        //printf("alias %s='%s'\n", current->alias, current->val); //prints out the aliases by looping
        current = current->next;
    }
    return ptr4;
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
//printf("%s", words);
char* ptr3;
ptr3 = malloc(sizeof(char*)*100);

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
    //printf("%s", ptr3);
        return ptr3;}
}

void aliasChecker( node_t** head, char* alias){

node_t* current = *head;
    node_t* prev = NULL;
    char* print = run_command(alias);
    while (1) {
        if (current == NULL){  aliasFunctionsPrint(print); return;}//print/execute alias
        if (strcmp(current->alias, print) == 0){ aliasChecker(head, current->val); return;}
        prev = current;
        current = current->next;
    }


}

char* catFileOpenReadClose(char* file){
FILE *filePointer;
char* ptr4;
ptr4 = malloc(sizeof(char*) * 2000);
if((filePointer = fopen(file, "r") )== NULL){
ptr4 ="no such filename\n";
return ptr4;
}
int c;
int i = 0;

while ( (c = getc(filePointer)) != EOF)
                strncat(ptr4, &c, 1);

fclose(filePointer);

return ptr4;
}

char* catDecode(char* catFile){

char delim[] = " ";
char* ptr1 = strtok(catFile, delim);
    char* ptr2 = strtok(NULL, delim);
    char* ptr3 = strtok(NULL, "/0");
char* ptr4;
ptr4 = malloc(sizeof(char*) * 200);

    if(ptr2 != NULL && ptr3 == NULL){
    ptr4 = catFileOpenReadClose(ptr2);
    }
    else if(ptr2 != NULL && ptr3 != NULL){
        ptr4 = catOpenReadClose(ptr2, ptr3);
        }
        else {
                ptr4 = "too many/few args";
                }

        return ptr4;
}

char* catNew(char* catFile){
    char delim[] = " ";
    //printf("%s", catFile);
    char* ptr1 = strtok(catFile, delim);
    char* ptr2 = strtok(NULL, ">");
char* ptr4;
ptr4 = malloc(sizeof(char*) * 20);

    FILE *filePointer;
    filePointer = fopen(ptr2, "w");
    fclose(filePointer);

    if((filePointer = fopen(ptr2, "r") ) != NULL){ ptr4 = ptr2;}
    else{ ptr4 = "Error Did not create file\n";}

}

char* catOpenReadClose(char* file, char* file2){

FILE *filePointer;
char* ptr4;
ptr4 = malloc(sizeof(char*) * 200);
if((filePointer = fopen(file, "r") )== NULL){
strcpy(ptr4, "Error no such filename\n");
return ptr4;
}
else{
int c;
int i = 0;
while ( (c = getc(filePointer)) != EOF)
                strncat(ptr4, &c, 1);
fclose(filePointer);

if((filePointer = fopen(file2, "r") )== NULL){
strcpy(ptr4, "Error no such filename\n");
return ptr4;
}
else{
int c;
while ( (c = getc(filePointer)) != EOF)
                strncat(ptr4, &c, 1);
fclose(filePointer);
return ptr4;
}

}}

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
char* toprint = run_command(aliasString);
char* print = commandChecker(toprint);
printf("%s\n", print);
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
  char delim[] = " \n\t";
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
    char* t;
    t = malloc(sizeof(char*) * linecount);
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
    free(t);
}

char* date()
{
  time_t t = time(NULL);
  return(asctime(localtime(&t)));
}

char* sortNotFile(char* input){

char* tempstr = input;
//printf("%s" , tempstr);
    char* delim = "\n";
    unsigned long int numNewLine = 0;

    for(int m = 0; tempstr[m]; m++){
    //printf("%c", tempstr[m]);
    if(tempstr[m] == '\n') {
            numNewLine++;
        }

    }
    if(numNewLine == 0){return input;}
//printf("%lu %s\n", numNewLine, input);
    char **array = (char**)malloc(numNewLine * sizeof(char*));
    char* singleline;
         singleline = strtok(input, delim);
    for(int i = 0; i < numNewLine; i++){
    //printf("Line %s\n", singleline);
    array[i] = singleline;
    //printf("Array %s\n", array[i]);
    singleline = strtok(NULL, delim);
    }
char* ptr4;
  ptr4 = malloc(sizeof(char*) * 5000);
if(strncmp(array[0], ".", 1) != 0){
sortfile(array, numNewLine);}
for(int i = 0; i < numNewLine; i++){

        strcat(ptr4, array[i]);
        strcat(ptr4, "\n");
        }
//printf("%s\n", ptr4);
        return ptr4;

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
   char currVal[5096];
   char prevVal[5096];
   //printf("%s\n",  array[0]);

for(int i = 0; i < numBar; i++){

char* p;
   p = malloc(sizeof(char*) * sizeof(prevVal));

strncpy(prevVal, currVal, sizeof(prevVal));
if(strncmp(currVal, "Error ", 4) == 0){ break;}
if(strncmp(array[i], "sort ", 4) == 0){
  char tmp[] = "sort ";
  char* t;
  //printf("Here1\n");
  t = malloc(sizeof(prevVal) + sizeof(tmp) + 4);
  strcat(t, tmp);
  strcat(t, prevVal);
  strcpy(p, commandChecker(t));
  free(t);
  //printf("P %s", p);
}
else if(strncmp(array[i], "grep ", 4) == 0){
  char* tmp = array[i];
  char* t;
  t = malloc(sizeof(prevVal) * sizeof(tmp) * 4);
  strcat(t, tmp);
  strcat(t, " ");
  strcat(t, prevVal);
  //printf("%s/n", t);
  strcpy(p, commandChecker(t));
  free(t);
}
else if(strncmp(array[i], "rev ", 3) == 0){
  char* tmp = array[i];
  char* t;
  t = malloc(sizeof(prevVal) * sizeof(tmp) * 4);
  strcat(t, tmp);
  strcat(t, " ");
  strcat(t, prevVal);
  //printf("%s/n", t);
  strcpy(p, commandChecker(t));
  free(t);
}
else if(strncmp(array[i], "wc ", 2) == 0){
  char* tmp = array[i];
  char* t;
  t = malloc(sizeof(prevVal) * sizeof(tmp) * 4);
  strcat(t, tmp);
  strcat(t, " ");
  strcat(t, prevVal);
  //printf("%s/n", t);
  strcpy(p, commandChecker(t));
  free(t);
}
else{p = commandChecker(array[i]);}
strncpy(currVal, p, sizeof(currVal));
//printf("%s\n", currVal);
//printf("%s\n", currVal);
free(p);

}

printf("%s\n", currVal);
//free(currVal);

}

char* grep(char* input)
{
  FILE *f;
  char* returnstring;
  returnstring = malloc(4000);
  char delim[] = " \n\t";
  strcat(returnstring, "\n");
  char* ptr1;
  char* ptr2;
  if (strstr(input, "\""))
  {
    ptr1 = strtok(input, delim);
    ptr2 = strtok(NULL, "\"");
  }
  else
  {
    ptr1 = strtok(input, delim);
    ptr2 = strtok(NULL, delim);
  }
  ptr1 = strtok(NULL, delim);
  while (ptr1 != NULL)
  {
    if(strstr(ptr1, ".txt"))
    {
      if ((f = fopen(ptr1, "r")) == NULL)
      {
        return("Error no such filename\n");
      }
      const char* line;
      line = malloc(sizeof(node_t));
      while(fgets(line, sizeof(line), f) != NULL)
      {
        if (line != NULL && strstr(line, ptr2))
        {
         strcat(returnstring, ptr1);
         break;
        }
      }
      fclose(f);
    }
    ptr1 = strtok(NULL, delim);
  }

  return(returnstring);
}

char* rev(char* input)
{
  char* returnstring;
  FILE *f;
  returnstring = malloc(10000);
  char delim[] = " \n\t";
  char* ptr1 = strtok(input, delim);
  char* ptr2 = strtok(NULL, delim);
  while(ptr2 != NULL)
  {
    if (strstr(ptr2, ".txt"))
    {
  if((f = fopen(ptr2, "r")) == NULL)
  {
    return("Error no such filename\n");
  }
  char* temp;
  temp = malloc(10000);
  while (fgets(temp, 10000, f) != NULL)
  {
    const char* line = temp;
    int len = strlen(line);
    for (int i = len-1; i > -1; i--) {
        strncat(returnstring, &line[i], 1);
    }
  }
  strcat(returnstring, "\n");
  fclose(f);
    }
    ptr2 = strtok(NULL, delim);
  }
  printf(returnstring);
  return(returnstring);
}

char* commandChecker(char* input){
char* checkThis;


checkThis = malloc(5096);
strcpy(checkThis, input);
char* ptr1 = strtok(checkThis, " ");
char* ptr2 = strtok(NULL, " ");


char* ptr4;

  ptr4 = malloc(sizeof(char*) * sizeof(*ptr2) + sizeof(*ptr1));
if(strncmp("echo ", ptr1, 4) == 0){

  strcpy(ptr4, echo(input, 1));
  }

else if(strncmp("alias ", ptr1, 5) == 0){
  strcpy(ptr4, aliasFun(input, 0));
  }

  else if(strncmp("printenv ", ptr1, 7) == 0){
    //printf("%s", input);
    //strcpy(ptr4, input);
    strcpy(ptr4, printenv());
    }
 else if(strncmp("grep ", ptr1, 4) == 0){
   //printf("%s", input);
   //strcpy(ptr4, input);
   strcpy(ptr4, grep(input));
   }
  else if(strncmp("cat ", ptr1, 3) == 0){
     //printf("%s", input);
     //strcpy(ptr4, input);
     strcpy(ptr4, catDecode(input));
     }
     else if(strncmp("sort ", ptr1, 4) == 0){
  strcpy(ptr4, sortNotFile(ptr2));
}
else if(strncmp("rev ", ptr1, 3) == 0){
  strcpy(ptr4, rev(input));
}
else if(strncmp("wc ", ptr1, 2) == 0){
  strcpy(ptr4, wc(input));
}
      else if(strncmp("ls ", ptr1, 2) == 0){
                //printf("%s", input);
                //strcpy(ptr4, input);
                strcpy(ptr4, lse());
                }
  else{strcpy(ptr4, input);}
//printf("Ptr 4 %s\n", ptr4);
return ptr4;
}

char* writeAppend(char* input, int type){
char* ptr1;
        char* ptr2;
        char* ptr3;
         char* delim = " ";
         char* c;
         ptr1 = strtok(input, delim);
         ptr2 = strtok(NULL, delim);
         ptr3 = strtok(NULL, "/0");

         char* ptr4 = commandChecker(ptr1);

         if(type == 1){ c = "w";}
         else{c = "a";}
         FILE* f;
if((f = fopen(ptr3, c) ) != NULL){
    fputs(ptr4, f);
}
fclose(f);
return ptr3;

}


  char* echoFile(char* input, int type){
  char delim[] = "\"";
  char* ptr1 = strtok(input, delim);
      char* ptr2 = strtok(NULL, delim);
      char* ptr3 = strtok(NULL, " ");
      char* ptr4 = strtok(NULL, "\0");
      char* c;
      //printf("$1 is %s, $2 is %s\n", ptr1, ptr2);
      //printf("$1 is %s, $2 is %s\n", ptr3, ptr4);
      strcat(ptr1, ptr2);
      char* p = echo( ptr1, 1);
 //printf("P is %s", p);

      if(type == 1){ c = "w";}
               else{c = "a";}
               FILE* f;
      if((f = fopen(ptr4, c) ) != NULL){
          fputs(p, f);
      }
      fclose(f);
      return ptr4;

  }