#ifndef _ASM_H
#define _ASM_H
#define __ASSEMBLY__

## from stdlib.h
# Pogram exit codes
#define EXIT_SUCCESS			0
#define EXIT_FAILURE		1

## from unistd.h

## Standard file descriptor numbers.
#define STDIN_FILENO	0
#define STDOUT_FILENO	1
#define STDERR_FILENO	2

## from fcntl.h
## file access flags
#define O_RDONLY	0



## Extra Assembly Helpers 
#define MAX_ERRNO 4095

## mmap related
#define MAP_OFFSET_ZERO			0
#define MMAP2_SHIFT 12 // 2**12 == 4096

#define NULL		0

#define SYSCALL		0x80
#endif
