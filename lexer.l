%{
#include <stdio.h>
#include <string.h>
#include "tokensBison.tab.h"
%}
DIGIT       [0-9]
META        [\[\]{},|:\"]
QUOTE       ["]
NOTQUOTE    [^"]
NOTECHOS    [^"^\n]
NOTENV    [^"^\n^ ]
PIPE        [|]
NOTNEWLINE  [^\n^|]

NOTNEWLINE2  [^\n]
TXT         [.txt]
%x          expect_string
%%


"\n"                                                    { return NEWLINE; }
[ \t\r\n]                                               {}
{QUOTE}                                                 { BEGIN(expect_string); yylval.sval = strdup(yytext); return META; }
<expect_string>{NOTQUOTE}*                              { yylval.sval = strdup(yytext); return WORDS; }
<expect_string>{QUOTE}                                  { BEGIN(INITIAL); yylval.sval = strdup(yytext); return META;}


{NOTNEWLINE}+[ ]{PIPE}[ ]{NOTNEWLINE}+[ ]*{PIPE}*{NOTNEWLINE2}* { yylval.sval = strdup(yytext); return PIPPET;}
exit|Exit|EXIT|bye                                  { yylval.sval = strdup(yytext); return EXITTOKEN; }
hello|hey|hi                                        { yylval.sval = strdup(yytext); return GREETING; }
setenv[ ][a-zA-Z0-9]+[ ]{QUOTE}{NOTECHOS}+{QUOTE}   { yylval.sval = strdup(yytext); return SETENVQ; }
setenv[ ][a-zA-Z0-9]+[ ]{NOTENV}+                   { yylval.sval = strdup(yytext); return SETENV; }
printenv                                            { yylval.sval = strdup(yytext); return PRINTENV; }
unsetenv[ ][a-zA-Z0-9]+                             { yylval.sval = strdup(yytext); return UNSETENV; }
cd[ ][a-zA-Z0-9\/.\${}]*                            { yylval.sval = strdup(yytext); return CD; }
(cd|cd[ ][~])                                       { yylval.sval = strdup(yytext); return CDE; }
alias[ ]*[a-zA-Z0-9]*[ ]*[a-zA-Z0-9]*               { yylval.sval = strdup(yytext); return ALIAS;}
alias[ ][a-zA-Z0-9]+[ ]${META}[a-zA-Z0-9]+{META}    { yylval.sval = strdup(yytext); return ALIASP;}
alias[ ]${META}[a-zA-Z0-9]+{META}[ ][a-zA-Z0-9]+    { yylval.sval = strdup(yytext); return ALIASC;}
alias[ ][a-zA-Z0-9]*[ ]{QUOTE}{NOTECHOS}*{QUOTE}    { yylval.sval = strdup(yytext); return ALIASA;}
unalias[ ]${META}[a-zA-Z0-9]+{META}                 { yylval.sval = strdup(yytext); return UNALIAS;}
unalias[ ][a-zA-Z0-9]+                              { yylval.sval = strdup(yytext); return UNALIAS;}
echo[ ]{QUOTE}{NOTQUOTE}*{QUOTE}[ ]>[ ][a-zA-Z0-9]+.txt { yylval.sval = strdup(yytext); return ECHOWRITE;};
echo[ ]{QUOTE}{NOTQUOTE}*{QUOTE}[ ]>>[ ][a-zA-Z0-9]+.txt { yylval.sval = strdup(yytext); return ECHOAPPEND;};

cat[ ][a-zA-Z0-9]+.txt[ ]*[a-zA-Z0-9]*{TXT}*        { yylval.sval = strdup(yytext); return CAT;};
cat[ ]>[a-zA-Z0-9]+.txt                             { yylval.sval = strdup(yytext); return CATNEW;}
cat[ ][a-zA-Z0-9]+.txt[ ]>>[ ][a-zA-Z0-9]+.txt      { yylval.sval = strdup(yytext); return CATAPP;}
cat[ ][a-zA-Z0-9]+.txt[ ]>[ ][a-zA-Z0-9]+.txt       { yylval.sval = strdup(yytext); return CATW;};
echo[ ]{QUOTE}{NOTQUOTE}*{QUOTE}                    { yylval.sval = strdup(yytext); return ECHOS;};
echo[ ]{NOTECHOS}*                                  { yylval.sval = strdup(yytext); return ECHOA;};

pwd([ ][a-zA-Z0-9]*)?                               { yylval.sval = strdup(yytext); return PWD;}
ls[ ][a-zA-Z.\/]*                                     { yylval.sval = strdup(yytext); return LS;}
ls                                                  { yylval.sval = strdup(yytext); return LSE;}

wc([ ].*)+                                          { yylval.sval = strdup(yytext); return WC;};
sort[ ]<[ ][a-zA-Z0-9]+.txt[ ]*>*[ ]*[a-zA-Z0-9]*{TXT}* { yylval.sval = strdup(yytext); return SORT;}
date                                                { yylval.sval = strdup(yytext); return DATE;}

grep[ ].*[ ].*                                      { yylval.sval = strdup(yytext); return GREP;}
rev[ ].*                                            { yylval.sval = strdup(yytext); return REV;}
[a-zA-Z0-9]+[ ]>[ ][a-zA-Z0-9]+.txt                 { yylval.sval = strdup(yytext); return WRITEOVER;};
[a-zA-Z0-9]+[ ]>>[ ][a-zA-Z0-9]+.txt                 { yylval.sval = strdup(yytext); return APPENDTO;};

[A-Z][a-z]*                                     { yylval.sval = strdup(yytext); return NAME; }
[a-z]+                                          { yylval.sval = strdup(yytext); return WORDS; }
{DIGIT}+|{DIGIT}*"."{DIGIT}+                    { yylval.number = atoi(yytext); return NUMBER; }
{META}                                          { return META; }

