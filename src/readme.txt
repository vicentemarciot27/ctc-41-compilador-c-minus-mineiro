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
