adicione codigo, baseado no analisador lexico TinyFlex
para analise lexica da linguagem C-

restrições

* arquivos de código devem ter extensão .c
* codigo output do flex (.c) não pode estar nesse diretorio 
  - se executou o flex manualmente, apague. O CMake executa o flex
* o arquivo .l (entrada do flex) deve se chamar cminus.l

-----------------------------------------------------------
notas desta entrega (compilador C- mineiro)

* cminus.l é a entrada do flex usada pelo CMake.

* cminus.l.mineiro é a variante com as palavras reservadas em
  mineirês -- é a brincadeira do "C- mineiro", que dá nome ao
  repositório. Mantido de propósito.
  Não é compilado: o CMake só pega src/*.c e src/cminus.l, e a
  extensão .mineiro fica fora dos dois globs.

* printLine() é declarada em util.h e definida em util.c.
  Sem essa declaração, cminus.l compila a chamada como
  declaração implícita (warning em C17, erro em C23).

-----------------------------------------------------------
etapa SYN (análise sintática)

* cminus.y implementa a gramática C- com Bison e constrói a árvore
  sintática. Inclui declarações e comandos intercalados, blocos aninhados
  e subtração unária, conforme as instruções do laboratório.
* globals.h define os nós da árvore; util.c cria e imprime esses nós.
* main.c executa LEX e SYN. As etapas TAB e GEN ficam desativadas
  até suas implementações.
* Para compilar com CMake, use -DDOPARSE=TRUE. Flex e Bison geram os
  arquivos lexer.c e parser.c no diretório de build, fora de src/.
