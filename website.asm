format ELF64 executable

SYS_write = 1
SYS_exite = 60
SYS_socket = 41

AF_INET = 2
SOCK_STREAM = 1

STDOUT = 1
STDERR = 2

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
    socket AF_INET, SOCK_STREAM, 0
    ;;socket 69, 420, 0
    cmp rax, 0
    jl error

    mov dword [sockfd], eax
    exit 0

error: 
    write STDERR, error_msg, error_msg_len
    exit 1

segment readable writeable
sockfd dd 0
start db "Starting Web Server!", 10
start_len = $ - start

error_msg db "ERROR!", 10
error_msg_len = $ - error_msg