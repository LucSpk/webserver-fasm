format ELF64 executable

SYS_write = 1
SYS_exite = 60
SYS_socket = 41

AF_INET = 2
SOCK_STREAM = 1

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
    
    write 1, start, start_len
    socket AF_INET, SOCK_STREAM, 0
    mov dword [sockfd], eax
    exit 0

segment readable writeable
sockfd dd 0
start db "Starting Web Server!", 10
start_len = $ - start