%code requires {
typedef struct treeNode TreeNode;
}

%{
#define YYPARSER
#include "globals.h"
#include "util.h"
#include "scan.h"
#include "parse.h"

static TreeNode *syntaxTree;
static int yylex(void);
static int yyerror(const char *message);

static TreeNode *append(TreeNode *list, TreeNode *node)
{
  if (!list) return node;
  TreeNode *last = list;
  while (last->sibling) last = last->sibling;
  last->sibling = node;
  return list;
}

static TreeNode *operation(TokenType op, TreeNode *left, TreeNode *right)
{
  TreeNode *node = newExpNode(OpK);
  if (node) {
    node->attr.op = op;
    node->child[0] = left;
    node->child[1] = right;
  }
  return node;
}

static TreeNode *declaration(DeclKind kind, TreeNode *id, ExpType type)
{
  TreeNode *node = newDeclNode(kind);
  if (node) {
    node->attr.name = id->attr.name;
    node->lineno = id->lineno;
    node->type = type;
  }
  return node;
}

static TreeNode *assignment(TreeNode *var, TreeNode *value)
{
  TreeNode *node = newStmtNode(AssignK);
  if (node) {
    node->attr.name = var->attr.name;
    node->lineno = var->lineno;
    if (var->child[0]) {
      node->child[0] = var->child[0];
      node->child[1] = value;
    } else node->child[0] = value;
  }
  return node;
}
%}

%union {
  TreeNode *node;
  int type;
}
%token ERROR ELSE IF INT RETURN VOID WHILE
%token <node> ID NUM
%token ASSIGN PLUS MINUS TIMES OVER LT LEQ GT GEQ EQ NEQ
%token SEMI COMMA LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE
%type <type> type_specifier
%type <node> declaration_list declaration var_declaration fun_declaration
%type <node> params param_list param compound_stmt block_items block_item
%type <node> statement expression_stmt selection_stmt iteration_stmt return_stmt
%type <node> expression var simple_expression relop additive_expression term factor
%type <node> call args arg_list
%precedence IF_WITHOUT_ELSE
%precedence ELSE
%start program

%%
program             : declaration_list { syntaxTree = $1; }
                    ;
declaration_list    : declaration_list declaration { $$ = append($1,$2); }
                    | declaration { $$ = $1; }
                    ;
declaration         : var_declaration { $$ = $1; }
                    | fun_declaration { $$ = $1; }
                    ;
var_declaration     : type_specifier ID SEMI
                        { $$ = declaration(VarK,$2,$1); }
                    | type_specifier ID LBRACK NUM RBRACK SEMI
                        { $$ = declaration(ArrayK,$2,$1);
                          $$->child[0] = $4; }
                    ;
type_specifier      : INT { $$ = Integer; }
                    | VOID { $$ = Void; }
                    ;
fun_declaration     : type_specifier ID LPAREN params RPAREN compound_stmt
                        { $$ = declaration(FunK,$2,$1);
                          $$->child[0] = $4;
                          $$->child[1] = $6; }
                    ;
params              : param_list { $$ = $1; }
                    | VOID { $$ = NULL; }
                    ;
param_list          : param_list COMMA param { $$ = append($1,$3); }
                    | param { $$ = $1; }
                    ;
param               : type_specifier ID
                        { $$ = declaration(ParamVarK,$2,$1); }
                    | type_specifier ID LBRACK RBRACK
                        { $$ = declaration(ParamArrayK,$2,$1); }
                    ;
compound_stmt       : LBRACE block_items RBRACE
                        { $$ = newStmtNode(BlockK); $$->child[0] = $2; }
                    ;
block_items         : block_items block_item { $$ = append($1,$2); }
                    | %empty { $$ = NULL; }
                    ;
block_item          : var_declaration { $$ = $1; }
                    | statement { $$ = $1; }
                    ;
statement           : expression_stmt { $$ = $1; }
                    | compound_stmt { $$ = $1; }
                    | selection_stmt { $$ = $1; }
                    | iteration_stmt { $$ = $1; }
                    | return_stmt { $$ = $1; }
                    ;
expression_stmt     : expression SEMI { $$ = $1; }
                    | SEMI { $$ = NULL; }
                    ;
selection_stmt      : IF LPAREN expression RPAREN statement %prec IF_WITHOUT_ELSE
                        { $$ = newStmtNode(IfK);
                          $$->child[0] = $3; $$->child[1] = $5; }
                    | IF LPAREN expression RPAREN statement ELSE statement
                        { $$ = newStmtNode(IfK);
                          $$->child[0] = $3; $$->child[1] = $5;
                          $$->child[2] = $7; }
                    ;
iteration_stmt      : WHILE LPAREN expression RPAREN statement
                        { $$ = newStmtNode(WhileK);
                          $$->child[0] = $3; $$->child[1] = $5; }
                    ;
return_stmt         : RETURN SEMI
                        { $$ = newStmtNode(ReturnK); }
                    | RETURN expression SEMI
                        { $$ = newStmtNode(ReturnK); $$->child[0] = $2; }
                    ;
expression          : var ASSIGN expression { $$ = assignment($1,$3); }
                    | simple_expression { $$ = $1; }
                    ;
var                 : ID { $$ = $1; }
                    | ID LBRACK expression RBRACK
                        { $$ = $1; $$->child[0] = $3; }
                    ;
simple_expression   : additive_expression relop additive_expression
                        { $$ = $2; $$->child[0] = $1; $$->child[1] = $3; }
                    | additive_expression { $$ = $1; }
                    ;
relop               : LEQ { $$ = operation(LEQ,NULL,NULL); }
                    | LT  { $$ = operation(LT,NULL,NULL); }
                    | GT  { $$ = operation(GT,NULL,NULL); }
                    | GEQ { $$ = operation(GEQ,NULL,NULL); }
                    | EQ  { $$ = operation(EQ,NULL,NULL); }
                    | NEQ { $$ = operation(NEQ,NULL,NULL); }
                    ;
additive_expression : additive_expression PLUS term
                        { $$ = operation(PLUS,$1,$3); }
                    | additive_expression MINUS term
                        { $$ = operation(MINUS,$1,$3); }
                    | term { $$ = $1; }
                    ;
term                : term TIMES factor { $$ = operation(TIMES,$1,$3); }
                    | term OVER factor { $$ = operation(OVER,$1,$3); }
                    | factor { $$ = $1; }
                    ;
factor              : LPAREN expression RPAREN { $$ = $2; }
                    | MINUS factor
                        { $$ = operation(MINUS,$2,NULL); $$->unary = TRUE; }
                    | var { $$ = $1; }
                    | call { $$ = $1; }
                    | NUM { $$ = $1; }
                    ;
call                : ID LPAREN args RPAREN
                        { $$ = newExpNode(CallK);
                          $$->attr.name = $1->attr.name;
                          $$->lineno = $1->lineno;
                          $$->child[0] = $3; }
                    ;
args                : arg_list { $$ = $1; }
                    | %empty { $$ = NULL; }
                    ;
arg_list            : arg_list COMMA expression { $$ = append($1,$3); }
                    | expression { $$ = $1; }
                    ;
%%

static int yylex(void)
{
  TokenType token = getToken();
  yylval.node = NULL;
  if (token == ID) {
    yylval.node = newExpNode(IdK);
    yylval.node->attr.name = copyString(tokenString);
  } else if (token == NUM) {
    yylval.node = newExpNode(ConstK);
    yylval.node->attr.val = atoi(tokenString);
  }
  return token;
}

static int yyerror(const char *message)
{
  if (!Error) {
    pce("Syntax error at line %d: %s\n",lineno,message);
    pce("Current token: ");
    printToken(yychar,tokenString);
  }
  Error = TRUE;
  return 0;
}

TreeNode *parse(void)
{
  syntaxTree = NULL;
  yyparse();
  return syntaxTree;
}
