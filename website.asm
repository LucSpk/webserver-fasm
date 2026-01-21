format ELF64 executable

SYS_write equ 1
SYS_exite equ 60
SYS_socket equ 41
SYS_bind equ 49

AF_INET equ 2
SOCK_STREAM equ 1
INADDR_ANY = 0

STDOUT equ 1
STDERR equ 2

EXIT_SUCCESS equ 0
EXIT_FAILURE equ 1


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
macro syscall3 number, a, b, c 
{
    mov rax, number
    mov rdi, a
    mov rax, b
    mov rax, c
    syscall
}

macro bind sockfd, addr, addrlen
{
    syscall3 SYS_bind, sockfd, addr, addrlen
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

    bind [sockfd], servaddr.sin_family, servaddr.sin_addr
    cmp rax, 0
    jl error
 
    write STDOUT, ok_msg, ok_msg_len

    exit EXIT_SUCCESS

error: 
    write STDERR, error_msg, error_msg_len
    exit EXIT_FAILURE

segment readable writeable
sockfd dq 0
servaddr.sin_family dw 0
servaddr.sin_port dw 0
servaddr.sin_addr dd 0
servaddr.sin_zero dq 0
sizeof_servaddr = $ - servaddr.sin_family

start db "INFO: Starting Web Server!", 10
start_len = $ - start

ok_msg db "INFO: OK!", 10
ok_msg_len = $ - ok_msg

socket_trace_msg db "INFO: Creating a socket...", 10
socket_trace_msg_len = $ - socket_trace_msg

bind_trace_msg db "INFO: Binding the socket...", 10
bind_trace_msg_len = $ - bind_trace_msg

error_msg db "ERROR!", 10
error_msg_len = $ - error_msg