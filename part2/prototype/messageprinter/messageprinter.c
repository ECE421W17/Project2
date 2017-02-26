#include <unistd.h>
#include <stdio.h>
#include <time.h>

void wait_and_print(unsigned time, char * msg) {
    //pid_t f;
    //f = fork();
    //if (f==0) {
        struct timespec time_amount;
        time_amount.tv_sec = time/1000;
        time_amount.tv_nsec = (long) (time % 1000) * 1000000;
        nanosleep(&time_amount, NULL);
        //sleep(time);
        printf("\n%s\n", msg);
    //}
}
