%{
#include <stdio.h>
#include <string.h>
#include "tokensBison.tab.h"
%}
DIGIT       [0-9]
META        [\[\]{},:\"]
QUOTE       ["]
NOTQUOTE    [^"]
PIPE        [|]
%x          expect_string
%%


"\n"                                            { return NEWLINE; }
[ \t\r\n]                                       {}
{QUOTE}                                         { BEGIN(expect_string); yylval.sval = strdup(yytext); return META; }
<expect_string>{NOTQUOTE}*                      { yylval.sval = strdup(yytext); return WORDS; }
<expect_string>{QUOTE}                          { BEGIN(INITIAL); yylval.sval = strdup(yytext); return META;}

exit|Exit|EXIT|bye                              { yylval.sval = strdup(yytext); return EXITTOKEN; }
hello|hey|hi                                    { yylval.sval = strdup(yytext); return GREETING; }
setenv[ ][a-zA-Z0-9]+[ ][a-zA-Z0-9]+            { yylval.sval = strdup(yytext); return SETENV; }
printenv                                        { yylval.sval = strdup(yytext); return PRINTENV; }
unsetenv[ ][a-zA-Z0-9]+                         { yylval.sval = strdup(yytext); return UNSETENV; }
cd[ ].*                                         { yylval.sval = strdup(yytext); return CD; }
cd                                              { yylval.sval = strdup(yytext); return CDE; }
alias[ ]*[a-zA-Z0-9]*[ ]*[a-zA-Z0-9]*           { yylval.sval = strdup(yytext); return ALIAS;}
ls[ ][a-zA-Z.]*                                 { yylval.sval = strdup(yytext); return LS;}
ls                                              { yylval.sval = strdup(yytext); return LSE;}
unalias[ ][a-zA-Z0-9]+                          { yylval.sval = strdup(yytext); return UNALIAS;}


[A-Z][a-z]*                                     { yylval.sval = strdup(yytext); return NAME; }
[a-z]+                                          { yylval.sval = strdup(yytext); return WORDS; }
{DIGIT}+|{DIGIT}*"."{DIGIT}+                    { yylval.number = atoi(yytext); return NUMBER; }
{META}                                          { return META; }

