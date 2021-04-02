%{
#include "tokens.h"
%}
DIGIT [0-9]
%%
[ \t\r\n] {}
hello|hey|hi    return GREETING;
[A-Z][a-z]*     return NAME;
[a-z]+          return WORDS;
{DIGIT}+|{DIGIT}*"."{DIGIT}+    return NUMBER;
