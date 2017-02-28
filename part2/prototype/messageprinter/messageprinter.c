#include <unistd.h>
#include <stdio.h>
#include <time.h>
#include <errno.h>

int wait_and_print(long sec, long nsec, char * msg) {
    struct timespec time_amount;
    time_amount.tv_sec = sec; // Get seconds
    time_amount.tv_nsec = nsec; // Get milliseconds
    nanosleep(&time_amount, NULL);
    if (errno == 4 || errno == 14 || errno == 22) {
      return -1;
    }
    printf("\n%s\n", msg);
    return 0;
}

// int main() {
//   wait_and_print(1, 1, "yo");
// }
