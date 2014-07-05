# _strlen function 
# C Prototype: int _strlen(char* string)
# string is passed as eax
# eax will contain return value.
# if string is null eax will be zero
# 
# Used Caller Registers :ecx
_strlen:
		
		# exit early if eax is null
		test	%eax,%eax
		jz		exit_strlen_zero
		
		# Prologue, setup the stack frame
		# although not absolutely required as this is an internal 
		# function but playing by convention rules is probably useful
		# for now
		push		%ebp
		mov			%esp,				%ebp
		
		# edi is a callee saved register.
		push	%edi
		
		# Lets get down to strlen business
		mov		%eax,				%edi	# move our string pointer into edi
											# as that's where scasb is expecting things
											
		xor		%ecx,				%ecx	# set ecx to zero
		not		%ecx
		
		xor		%al,				%al		# set al to zero
		
		cld									# clear the direction flag
		repnz scasb
		not		%ecx
		
		lea	 -1(%ecx),%eax
		
		# restore the value of ecx
		pop		%edi
		
		# Epilogue 
		pop		%ebp
		ret
exit_strlen_zero:
		xor %eax,					%eax
		ret
