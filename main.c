#include <stdio.h>
#include "tokens.h"

int yylex();
extern char* yytext;
void printLine(int line){printf("%4d | ", line);}
int main() {
    printLine(1);
    int line = 1;
    while(1){
        int token = yylex();
        if(token == 0){break;}
        if(token == WORDS){
            printf("Word | %s", yytext);
        }
        else if(token == NAME){
            printf("Name | %s", yytext);
        }
        else if(token == NUMBER){
            printf("Number | %s", yytext);
        }
        else if(token == GREETING){
            printf("Greeting | %s", yytext);
        }
        else{
            printf("Unknown | %s", yytext);
        }

    }
    return 0;
}