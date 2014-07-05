#define __ASSEMBLY__
# _atos function 
# convert string to an integer
# C Style Prototype: int _atos(char* string)
# string is passed as eax
# eax will contain return value.
# returns string is null eax will be zero
# text section - this is where our code lives
.section .text		


# make our entry point knowing to the linker
.global _atos		
_atos:
		
		# exit early if eax is null
		test	%eax,%eax
		jz		exit_atos_zero
		
		# Prologue, setup the stack frame
		push		%ebp
		mov			%esp,				%ebp
		
		# Prologue 1. Local variables
		# result variable - initialize to zero
		xor	 %ecx, %ecx

atos_loop:
		# move 1 byte from our char array in eax into edx
		movzbl	(%eax), %edx
		# check if we are at the end of the string
		cmp $0,%dl
		jz epilogue
		# get to integer value of the char by substracting
		# 48 from the ascii char value
		subl	$48, %edx
		# mulitply ecx by 10 
		imul $10, %ecx
		# add our integer value to ecx
		add		%edx, %ecx 
		# move eax to the next byte in the array
		inc %eax
		jnz atos_loop

# Epilogue 
epilogue:
		mov 	%ecx,	%eax;
		pop		%ebp
		ret
exit_atos_zero:
		xor %eax,					%eax
		ret
