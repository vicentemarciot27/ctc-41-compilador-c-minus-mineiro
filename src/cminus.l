/****************************************************/
/* File: cminus.l                                   */
/* Lex specification for C-                         */
/* Project for CES41: Compiladores                  */
/****************************************************/

%option noyywrap 
/* opção noyywrap pode ser necessária para novas versões do flex
  limitação: não compila mais de um arquivo fonte de uma só vez (não precisamos disso)
  https://stackoverflow.com/questions/1480138/undefined-reference-to-yylex 
*/ 

%{
#include "globals.h"
#include "util.h"
#include "scan.h"
/* lexeme of identifier or reserved word */
char tokenString[MAXTOKENLEN+1];
%}
digit       [0-9]
number      {digit}+
letter      [a-zA-Z]
identifier  {letter}+
newline     \r?\n
whitespace  [ \t\r]+
comment     \/\*([^*]|\*+[^*/])*\*+\/
%%
"else"          {return ELSE;}
"if"            {return IF;}
"int"           {return INT;}
"return"        {return RETURN;}
"void"          {return VOID;}
"while"         {return WHILE;}
"="             {return ASSIGN;}
"+"             {return PLUS;}
"-"             {return MINUS;}
"*"             {return TIMES;}
"/"             {return OVER;}
"<"             {return LT;}
"<="            {return LEQ;}
">"             {return GT;}
">="            {return GEQ;}
"=="            {return EQ;}
"!="            {return NEQ;}
";"             {return SEMI;}
","             {return COMMA;}
"("             {return LPAREN;}
")"             {return RPAREN;}
"["             {return LBRACK;}
"]"             {return RBRACK;}
"{"             {return LBRACE;}
"}"             {return RBRACE;}
{number}        {return NUM;}
{identifier}    {return ID;}
{comment}       {
                  for (int i = 0; yytext[i] != '\0'; i++) {
                      if (yytext[i] == '\n') lineno++;
                  }
                }
{newline}       {lineno++;}
{whitespace}    {/* skip whitespace */}
.               {return ERROR;}
%%
TokenType getToken(void)
{ static int firstTime = TRUE;
  static int lastPrintedLine = 0;
  TokenType currentToken;
  if (firstTime)
  { firstTime = FALSE;
    lineno++;
    yyin = source;
    yyout = listing;
  }
  currentToken = yylex();

  if (currentToken != ENDFILE && yytext != NULL) {
      strncpy(tokenString, yytext, MAXTOKENLEN);
      tokenString[MAXTOKENLEN] = '\0';
    } else {
      tokenString[0] = '\0';
  }

  if (EchoSource) {
    while (lastPrintedLine < lineno) {
      lastPrintedLine++;
      int tempLineno = lineno;
      lineno = lastPrintedLine;
      printLine(redundant_source);
      lineno = tempLineno;
    }
  }

  if (TraceScan) {
    pc("\t%d: ", lineno);
    printToken(currentToken, tokenString);
  }
  return currentToken;
}