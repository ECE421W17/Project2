#include <unistd.h>
#include <stdio.h>
#include <time.h>

void wait_and_print(unsigned time, char * msg) {
    struct timespec time_amount;
    time_amount.tv_sec = time/1000; // Get seconds
    time_amount.tv_nsec = (long) (time % 1000) * 1000000; // Get milliseconds
    nanosleep(&time_amount, NULL);
    printf("\n%s\n", msg);
}
