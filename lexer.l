%{
#include <stdio.h>
#include <string.h>
#include "tokensBison.tab.h"
%}
DIGIT [0-9]
META    [\[\]{},:\"]
QUOTE   ["]
NOTQUOTE    [^"]
%x          expect_string
%%


"\n"            { return NEWLINE; }
[ \t\r\n] {}
{QUOTE}                     { BEGIN(expect_string); yylval.sval = strdup(yytext); return META; }
<expect_string>{NOTQUOTE}*  { yylval.sval = strdup(yytext); return STRINGLIT; }
<expect_string>{QUOTE}      { BEGIN(INITIAL); yylval.sval = strdup(yytext); return META;}

exit|Exit|EXIT  { yylval.sval = strdup(yytext); return EXITTOKEN; }
hello|hey|hi    { yylval.sval = strdup(yytext); return GREETING; }


[A-Z][a-z]*     { yylval.sval = strdup(yytext); return NAME; }
[a-z]+          { yylval.sval = strdup(yytext); return WORDS; }
{DIGIT}+|{DIGIT}*"."{DIGIT}+     { yylval.number = atoi(yytext); return NUMBER; }
{META} { return META; }
[\<\>\|\\&]	{ yylval.sval = strdup(yytext); return META; }
