%{
#include "tokens.h"
%}
DIGIT [0-9]
META    [\[\]{},:]
QUOTE   ["]
NOTQUOTE    [^"]

%%

[ \t\r\n] {}
{QUOTE}         {BEGIN(expect_string); return META}
<expect_string>{NOTQUOTE}*  return STRINGLIT;
<expect_string>{QUOTE}      {BEGIN(INITIAL); return META;}

hello|hey|hi    return GREETING;
[A-Z][a-z]*     return NAME;
[a-z]+          return WORDS;
"\n"            return NEWLINE;
{DIGIT}+|{DIGIT}*"."{DIGIT}+    return NUMBER;
{META} return META;

