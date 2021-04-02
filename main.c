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
            printf("Word | %s\n", yytext);
        }
        else if(token == NAME){
            printf("Name | %s\n", yytext);
        }
        else if(token == NUMBER){
            printf("Number | %s\n", yytext);
        }
        else if(token == GREETING){
            printf("Greeting | %s\n", yytext);
        }
        else if(token == STRINGLIT){
            printf("String | %s\n", yytext);
        }
        else if(token == NEWLINE){
            printf("Newline | %s", yytext);
        }
        else if(token == META){
            printf("Meta | %s\n", yytext);
        }

        else{
            printf("Unknown | %s\n", yytext);
        }

    }
    return 0;
}