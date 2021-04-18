#include <stdio.h>

#include "tokensBison.tab.h"

int yylex();
int yyparse();

void printLine(int line){printf("%4d | ", line);}

int main() {
int token;
    printf("$:");
    while(1){
        yyparse();

        if(token == 0){break;}
    }
    return 0;
}