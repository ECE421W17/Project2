#include <unistd.h>
#include <stdio.h>

void wait_and_print(unsigned time, char * msg) {
    sleep(time);
    printf("%s\n", msg);
}
