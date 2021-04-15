%{
#include <stdio.h>
#include <string.h>
#include "tokensBison.tab.h"
%}
DIGIT       [0-9]
META        [\[\]{},:\"]
QUOTE       ["]
NOTQUOTE    [^"]
NOTECHOS    [^"^\n]
NOTENV    [^"^\n^ ]
PIPE        [|]
TXT         [.txt]
%x          expect_string
%%


"\n"                                                    { return NEWLINE; }
[ \t\r\n]                                               {}
{QUOTE}                                                 { BEGIN(expect_string); yylval.sval = strdup(yytext); return META; }
<expect_string>{NOTQUOTE}*                              { yylval.sval = strdup(yytext); return WORDS; }
<expect_string>{QUOTE}                                  { BEGIN(INITIAL); yylval.sval = strdup(yytext); return META;}

exit|Exit|EXIT|bye                                      { yylval.sval = strdup(yytext); return EXITTOKEN; }
hello|hey|hi                                            { yylval.sval = strdup(yytext); return GREETING; }
setenv[ ][a-zA-Z0-9]+[ ]{QUOTE}{NOTECHOS}+{QUOTE}       { yylval.sval = strdup(yytext); return SETENVQ; }
setenv[ ][a-zA-Z0-9]+[ ]{NOTENV}+                       { yylval.sval = strdup(yytext); return SETENV; }
printenv                                                { yylval.sval = strdup(yytext); return PRINTENV; }
unsetenv[ ][a-zA-Z0-9]+                                 { yylval.sval = strdup(yytext); return UNSETENV; }
cd[ ][a-zA-Z0-9\/.\${}]*                                { yylval.sval = strdup(yytext); return CD; }
(cd|cd[ ][~])                                           { yylval.sval = strdup(yytext); return CDE; }
alias[ ]*[a-zA-Z0-9]*[ ]*[a-zA-Z0-9]*                   { yylval.sval = strdup(yytext); return ALIAS;}
alias[ ][a-zA-Z0-9]+[ ]${META}[a-zA-Z0-9]+{META}        { yylval.sval = strdup(yytext); return ALIASP;}
alias[ ]${META}[a-zA-Z0-9]+{META}[ ][a-zA-Z0-9]+        { yylval.sval = strdup(yytext); return ALIASC;}
alias[ ][a-zA-Z0-9]*[ ]{QUOTE}{NOTECHOS}*{QUOTE}        { yylval.sval = strdup(yytext); return ALIASA;}
ls[ ][a-zA-Z.\/]*                                       { yylval.sval = strdup(yytext); return LS;}
ls                                                      { yylval.sval = strdup(yytext); return LSE;}
unalias[ ]${META}[a-zA-Z0-9]+{META}                     { yylval.sval = strdup(yytext); return UNALIAS;}
unalias[ ][a-zA-Z0-9]+                                  { yylval.sval = strdup(yytext); return UNALIAS;}
echo[ ]{QUOTE}{NOTQUOTE}*{QUOTE}                        { yylval.sval = strdup(yytext); return ECHOS;};
echo[ ]{NOTECHOS}*                                      { yylval.sval = strdup(yytext); return ECHOA;};
cat[ ]>[a-zA-Z0-9]+.txt                                 { yylval.sval = strdup(yytext); return CATNEW;};
cat[ ][a-zA-Z0-9]+.txt[ ]>>[ ][a-zA-Z0-9]+.txt          { yylval.sval = strdup(yytext); return CATAPP;};
cat[ ][a-zA-Z0-9]+.txt[ ]>[ ][a-zA-Z0-9]+.txt           { yylval.sval = strdup(yytext); return CATW;};
cat[ ][a-zA-Z0-9]+.txt[ ]*[a-zA-Z0-9]*{TXT}*            { yylval.sval = strdup(yytext); return CAT;};
pwd([ ][a-zA-Z0-9]*)?                                   { yylval.sval = strdup(yytext); return PWD;};
sort[ ]<[ ][a-zA-Z0-9]+.txt[ ]*>*[ ]*[a-zA-Z0-9]*{TXT}* { yylval.sval = strdup(yytext); return SORT;}


[A-Z][a-z]*                                     { yylval.sval = strdup(yytext); return NAME; }
[a-z]+                                          { yylval.sval = strdup(yytext); return WORDS; }
{DIGIT}+|{DIGIT}*"."{DIGIT}+                    { yylval.number = atoi(yytext); return NUMBER; }
{META}                                          { return META; }

