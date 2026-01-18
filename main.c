#include <stdio.h>
#include <sys/socket.h>

int main(void) {
    // Usar o comando cc -o main main.c && ./main para rodar
    printf("AF_INET = %d\n", AF_INET);
    printf("SOCK_STREAM = %d\n", SOCK_STREAM);
    return 0;
}