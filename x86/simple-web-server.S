#
# simple-web=server.S - A Simple Web Server Demonstrating Socket Usage
# usage : simple-web-server <port number>
# 
# 
#
#define __ASSEMBLY__
#include <asm/unistd.h>
#include <inet.h>
#include <asm.h>

#define ACCEPT_READ_BUFFER_SIZE		1024

.section .rodata
http_200: .asciz "HTTP/1.1 200 OK\nContent-type: text/html\n\r\nOK\r\n"
http_200_len: .int 46

# text section - this is where our code lives
.section .text		


# make our entry point knowing to the linker
.global _start		

#	Program entry point
_start:				
		# Prologue setup a stack frame
		push	%ebp			
		mov		%esp,			%ebp
		

		# int socket(int domain, int type, int protocol);
		# socket(AF_INET, SOCK_STREAM, IPPROTO_IP)

		# x86 uses the socketcall syscall for all it's socket stuff
		# arguments are pushed onto the stack
		# ecx points to the start of the arguments
		# ebx is the call type e.g socket, bind etc
		push	$IPPROTO_IP
		push 	$SOCK_STREAM
		push	$AF_INET
		
		mov		%esp,			 	%ecx
		mov		$SYS_SOCKET,		%ebx
		mov		$__NR_socketcall,	%eax
		int		$SYSCALL
		add		$12,				%esp
		
		# store the socket fd which is the result of socketcall in a register
		# %edi isn't going to be trashed by anything so we can leave it there
		mov		%eax,	%edi
		

		# int setsockopt(int sockfd, int level, int optname, const void *optval, socklen_t optlen);
		# setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &socklen_t, socklen_t)
		push 	$SIZE_OF_SOCKLEN_T
		push	%esp
		push	$SO_REUSEADDR
		push	$SOL_SOCKET
		push	%edi							# push sockfd
		mov		%esp,				%ecx 		# ecx points at the arguments
		mov		$SYS_SETSOCKOPT,	%ebx
		mov		$__NR_socketcall,	%eax
		int		$SYSCALL
		
		# Get the Port Number to use
		# First convert our argument to in integer 
		mov		12(%ebp),		%eax
		# see atos.S for implementation
		# atos - ascii to short
		call	_atos
		
		# rotate eax to the right by 8 to get the binary representation
		# of the port number
		ror		$0x08,	%ax
		
		
		# Biding the socket with an address type
		# int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
		# bind(sockfd, [AF_INET, argv[1], INADDR_ANY], 16)
		push	$INADDR_ANY
		pushw 	%ax					# sin_port
		pushw	$AF_INET
		mov		%esp,				%ecx 		# ecx points at the arguments
		
		push	$16
		push	%ecx
		push	%edi							# push sockfd	
		mov		%esp,				%ecx 		# ecx points at the arguments
		
		mov		$SYS_BIND,		%ebx
		mov		$__NR_socketcall,	%eax
		int		$SYSCALL
		
		
		# Preparing to listen the incoming connection (passive socket)
		# int listen(int sockfd, int backlog);
		# listen(sockfd, 0);
		push	$0								# backlog
		push	%edi							# push sockfd	
		mov		%esp,				%ecx 		# ecx points at the arguments
		mov		$SYS_LISTEN,		%ebx
		mov		$__NR_socketcall,	%eax
		int		$SYSCALL

		
accept_incoming:		
		# Accepting the incoming connection
		# int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
		# accept(sockfd, &addr, &addrlen)
		
		#  Add the size of sockaddr_in on the stack as this is where we
		#  store client info this is the same as the c variable declaration 
		# struct sockaddr addr; 
		sub		$SIZE_OF_SOCKADDR_IN, %esp
		#	get the address of the sockaddr struct and store it in eax
		lea		(%esp),		%eax
		
		# push the size of sockaddr onto the stack
		push	$SIZE_OF_SOCKADDR_IN
		# get a pointer to the size of value and store it in ecx
		lea		(%esp),		%ecx
		
		
		# int acceptfd = accept(sockfd [ push edx ], &addr[push eax], &addrlen [push ecx])
		push	%ecx
		push	%eax
		push	%edi							# push sockfd
		mov		%esp,				%ecx 		# ecx points at the arguments
		mov		$SYS_ACCEPT,		%ebx
		mov		$__NR_socketcall,	%eax
		int		$SYSCALL
		
		# We need to stash acceptfd [ %eax ] somewhere as eax will
		# be trash by the next system call. We could push and leave
		# it on the stack but then we'd need to keep track of the stack
		# state - we'll stash it in esi instead
		mov		%eax,		%esi
		
		
		# ssize_t read(int fd, void *buf, size_t count);
		# read(acceptfd [ %eax ] , buf [ %esp ] , count [ ACCEPT_READ_BUFFER_SIZE ]  	
		
		mov		$ACCEPT_READ_BUFFER_SIZE, %edx			# push count into edx
		
		# We need allocate space on the stack for the buffer
		# We used the sub instruction to substract the buffer size
		# from the stack pointer [ %esp ] 
		# Stack move towards low address which is why it's sub even
		# though the we are "Adding to the Stack"
		sub		$ACCEPT_READ_BUFFER_SIZE, 	%esp		
														
		mov		%esp,	%ecx							# move buffer pointer [ esp ] into ecx
		mov		%eax,	%ebx							# move sockfd [ eax ] returned by the
														# previous accept function
		mov		$__NR_read,		%eax	
		int		$SYSCALL
		
		
		# Write the request buffer out to the command line
		# This will print the user agent etc
		# ssize_t write(int fd, const void *buf, size_t count);
		# write(stdout, buf [ ecx ], size_t st_size [ eax ])
		
		# Note: %ecx is already pointing at the buffer that we want to write
		
		mov		%eax,			%edx					# move the number of bytes read [eax] by the
														# previous read call into edx
		mov		$STDOUT_FILENO,		%ebx
		mov		$__NR_write,		%eax 	
		int		$SYSCALL
		
		
		# Write 200 Ok header
		# ssize_t write(int fd, const void *buf, size_t count);
		# write(acceptfd, mapped_file_ptr, size_t st_size)
		mov		http_200_len,			%edx
		mov		$http_200,	%ecx
		mov		%esi,		%ebx		# acceptfd 
		mov		$__NR_write,		%eax 	
		int		$SYSCALL

		mov		%esi,		%ebx	# acceptfd
		mov		$__NR_close,		%eax 	
		int		$SYSCALL
		
		
		mov		%edi,		%edx
		jmp 	accept_incoming
		
		mov		$1,				%ebx
		mov		$__NR_exit,		%eax
		pop		%ebp
		int		$SYSCALL


