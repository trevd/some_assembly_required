#
# simple-cat.S - Prints the contents of a file to stdout
# usage : simple-cat <filename>
#
# 
#
#define __ASSEMBLY__
#include <asm/unistd.h>
#include <asm/mman.h>
#include <asm/types.h>
#include <asm/errno.h>
#include <asm.h>

.section .bss 
	# reserve 96 bytes for struct_stat
	.lcomm struct_stat,96			
	# st_size is 44 bytes into the structure
	#define st_size	struct_stat+44	
	
# text section - this is where our code lives
.section .text		

# make our entry point knowing to the linker
.global _start		

#	Program entry point
_start:				
		# Prologue setup a stack frame
		push	%ebp			
		mov		%esp,			%ebp
				
		# int lstat(const char *path, struct stat *buf);
		# lstat( 12(%ebp) , struct_stat )
		mov		$struct_stat,		%ecx
		
		# 12(%ebp) = argv[1]
		# 
		mov		12(%ebp),			%ebx
		mov		$__NR_lstat64,		%eax 	
		int		$SYSCALL
		# test eax and jump if the signed flag is set 
		# i.e eax = -1
		test 	%eax, 				%eax
		js		exit_cannot_lstat_file
		
			
		# int open(const char *pathname, int flags);
		# open ( 12(%ebp) , O_RDONLY )
		mov		$O_RDONLY,			%ecx
		mov		12(%ebp),			%ebx
		mov		$__NR_open,		%eax 	
		int		$SYSCALL
		# test eax and jump if the signed flag is set 
		# i.e eax = -1
		test 	%eax, 				%eax
		js		exit_cannot_open_file
		
		# push eax onto the stack. this is the filedescriptor 
		# return by open
__open_result:		push	%eax
		
		
		# void *mmap(void *addr, size_t length, int prot, int flags,int fd, off_t offset);
		# mmap2( NULL,st_size,PROT_READ,MAP_SHARED,fd,MAP_OFFSET_ZERO)
		# mmap uses eax,ebx,ecx,edx,esi,edi,ebp
		# push ebp onto the stack as mmap2 needs it for it's offset
		push	%ebp
		mov		$MAP_OFFSET_ZERO, %ebp
		shr		$MMAP2_SHIFT, %edi
		mov		%eax, %edi			# eax needs to contain a valid file decriptor
		mov		$MAP_PRIVATE, %esi
		mov		$PROT_READ, %edx
		mov		st_size, %ecx
		mov		$NULL,%ebx
		mov		$__NR_mmap2,	%eax
		int		$SYSCALL
		# restore %ebp now that mmap2 is done with it
		pop		%ebp
		
		# check the return value of mmap2
		cmp    $-MAX_ERRNO, %eax
		ja		exit_cannot_mmap_file
		
		#	push the result of mmap2 onto the stack as we will
		# 	need it to unmap		
__mmap2_result: push	%eax
				
		# ssize_t write(int fd, const void *buf, size_t count);
		# write(STDOUT_FILENO, mapped_file_ptr, size_t st_size)
		mov		st_size,			%edx
		mov		%eax,				%ecx 	# eax needs to contain a valid pointer to
											# a string buffer. in our case acquired
											# by mmap2
		mov		$STDOUT_FILENO,		%ebx	
		mov		$__NR_write,		%eax 	
		int		$SYSCALL
		
		# int munmap(void *addr, size_t length);
		# munmap(mapped_file_ptr, st_size);
		mov		st_size,			%ecx
		pop		%ebx	  			# pop the value which was pushed at __mmap2_result
		mov		$__NR_munmap,	%eax 	
		int		$SYSCALL
		
		# int close(int fd);
		# close(fd);
		pop		%ebx			# pop the value which was pushed at __open_result
		mov		$__NR_close,		%eax 	
		int		$SYSCALL
		
		
		
exit_success:
		mov 	$EXIT_SUCCESS,%ebx
		jmp		exit	
exit_cannot_lstat_file:
		mov 	$EXIT_FAILURE,%ebx
		jmp		exit
exit_cannot_open_file:
		mov 	$EXIT_FAILURE,	%ebx
		jmp		exit		
exit_cannot_mmap_file:
		# int close(int fd);
		# close(fd);
		pop		%ebx
		mov		$__NR_close,		%eax 	
		int		$SYSCALL
		mov 	$EXIT_FAILURE,%ebx
exit:
		# void exit(int status);
		# see above for EXIT_ status
		mov		$__NR_exit,		%eax
		pop		%ebp
		int		$SYSCALL


#undef __ASSEMBLY__
