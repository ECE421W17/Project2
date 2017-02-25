%module messageprinter

%{
#include <unistd.h>
#include <stdio.h>
extern void wait_and_print(unsigned time, char * msg);
%}

extern void wait_and_print(unsigned time, char * msg);
