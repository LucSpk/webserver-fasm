format ELF64 executable

SYS_write equ 1
SYS_exite equ 60

SYS_socket equ 41
SYS_accept equ 43
SYS_bind equ 49
SYS_listen equ 50
SYS_close equ 3

AF_INET equ 2
SOCK_STREAM equ 1
INADDR_ANY = 0

STDOUT equ 1
STDERR equ 2

EXIT_SUCCESS equ 0
EXIT_FAILURE equ 1

MAX_CONN equ 5


macro syscall1 number, a
{
    mov rax, number
    mov rdi, a
    syscall
}

macro syscall2 number, a, b
{
    mov rax, number
    mov rdi, a
    mov rsi, b
    syscall
}

macro syscall3 number, a, b, c 
{
    mov rax, number
    mov rdi, a
    mov rsi, b
    mov rdx, c
    syscall
}

macro write fd, buf, count {
    mov rax, SYS_write
    mov rdi, fd
    mov rsi, buf
    mov rdx, count
    syscall
}

macro socket domain, type, protocol 
{
    MOV rax, SYS_socket
    MOV rdi, domain
    MOV rsi, type
    MOV rdx, protocol
    SYSCALL
}

macro close fd
{
    syscall1 SYS_close, fd
}

macro bind sockfd, addr, addrlen
{
    syscall3 SYS_bind, sockfd, addr, addrlen
}

macro listen sockfd, backlog
{
    syscall2 SYS_listen, sockfd, backlog
}    

macro accept sockfd, addr, addrlen
{
    syscall3 SYS_accept, sockfd, addr, addrlen
} 

macro exit code {
    mov rax, SYS_exite
    mov rdi, code
    syscall
}

segment readable executable
entry main

main: 
    write STDOUT, start, start_len

    write STDOUT, socket_trace_msg, socket_trace_msg_len
    socket AF_INET, SOCK_STREAM, 0
    ;;socket 69, 420, 0
    cmp rax, 0
    jl error

    mov qword [sockfd], rax

    write STDOUT, bind_trace_msg, bind_trace_msg_len
    mov word [servaddr.sin_family], AF_INET
    mov word [servaddr.sin_port], 14619         ;; Isso corresponde a porta 6969 -> o valor 6969 tem 2 bytes que quando invertido da 14619. Note que 6969 em hexa é 0x1b39 e seu inverso 0x391b é 14619
    mov dword [servaddr.sin_addr], INADDR_ANY
    bind [sockfd], servaddr.sin_family, sizeof_servaddr
    cmp rax, 0
    jl error

    write STDOUT, listen_trace_msg, listen_trace_msg_len
    listen [sockfd], MAX_CONN
    cmp rax, 0
    jl error

    ;; Vai esperar a conexao de um client, pode usar o comando telnet 127.0.0.1 6969 para conectar. Precisa do 'inetutils' instalado, pode usar para instalar -> sudo pacman -S inetutils.
    write STDOUT, accept_trace_msg, accept_trace_msg_len
    accept [sockfd], cliaddr.sin_family, cliaddr_len
    cmp rax, 0
    jl error

    mov qword [connfd], rax
    write [connfd], hello, hello_len    
 
    write STDOUT, ok_msg, ok_msg_len
    close [connfd]
    close [sockfd]
    exit EXIT_SUCCESS

error: 
    write STDERR, error_msg, error_msg_len
    close [connfd]
    close [sockfd]
    exit EXIT_FAILURE

segment readable writeable

struc servaddr_in
{
    .sin_family dw 0
    .sin_port dw 0
    .sin_addr dd 0
    .sin_zero dq 0
}

sockfd dq -1
connfd dq -1
servaddr servaddr_in
sizeof_servaddr = $ - servaddr.sin_family

cliaddr servaddr_in
cliaddr_len dd sizeof_servaddr

hello db "Hello from flat assembler!", 10
hello_len = $ - hello


start db "INFO: Starting Web Server!", 10
start_len = $ - start

ok_msg db "INFO: OK!", 10
ok_msg_len = $ - ok_msg

socket_trace_msg db "INFO: Creating a socket...", 10
socket_trace_msg_len = $ - socket_trace_msg

bind_trace_msg db "INFO: Binding the socket...", 10
bind_trace_msg_len = $ - bind_trace_msg

listen_trace_msg db "INFO: Listening to the socket...", 10
listen_trace_msg_len = $ - listen_trace_msg

accept_trace_msg db "INFO: Waiting for client connections...", 10
accept_trace_msg_len = $ - accept_trace_msg

error_msg db "ERROR!", 10
error_msg_len = $ - error_msg