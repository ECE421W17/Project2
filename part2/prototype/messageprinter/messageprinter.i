%module messageprinter

%{
#include <unistd.h>
#include <stdio.h>
#include <time.h>
#include <errno.h>
extern int wait_and_print(long sec, long nsec, char * msg);
%}

%inline %{
extern int errno;
%}

extern int wait_and_print(long sec, long nsec, char * msg);
