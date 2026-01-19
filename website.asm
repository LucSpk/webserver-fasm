format ELF64 executable

SYS_write equ 1
SYS_exite equ 60
SYS_socket equ 41

AF_INET equ 2
SOCK_STREAM equ 1

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

    mov dword [sockfd], eax
    exit EXIT_SUCCESS

error: 
    write STDERR, error_msg, error_msg_len
    exit EXIT_FAILURE

segment readable writeable
sockfd dd 0
start db "Starting Web Server!", 10
start_len = $ - start

socket_trace_msg db "Creating a socket...", 10
socket_trace_msg_len = $ - socket_trace_msg

error_msg db "ERROR!", 10
error_msg_len = $ - error_msg