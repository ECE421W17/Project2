%module messageprinter

%{
extern void wait_and_print(unsigned time, char * msg);
%}
