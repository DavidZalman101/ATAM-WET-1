/*

array1 [ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
rax_____^

*/

/*

array2 [ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
rbx_____^

*/


/*

mergedArray [ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
rcx__________^

*/

/*
*(rcx) = rdx
*(rax) = r8
*(rbx) = r9

*/




.global _start
.section .text
_start:
	movq $array1, %rax	# %rax = &array1
	movq $array2, %rbx	# %rbx = &array2
	movq $mergedArray, %rcx # %rcx = $mergedArray
	
	movl (%rax), %r8d	# %r8  = *(array1)
	movl (%rbx), %r9d	# %r9  = *(array2)
	movl (%rcx), %edx	# %rdx = *(mergedArray)	

BOTH_ARRAYS_HW1:

	test %r8, %r8		# check if array1 is already at 0	
	je ONLY_ARRAY_2_HW1
	test %r9, %r9		# check if array2 is already at 0
	je ONLY_ARRAY_1_HW1

	jmp GET_MAX_HW1		# %r15 = MAX
	# NOTE: indexs were already moved and values were updated (array1\2)
CONT_HW1:	
		
	cmp %r15, %rdx		#check if the given MAX already exists in merged
	je BOTH_ARRAYS_HW1
				# doesn't already exist
	movl %r15d, %edx
	movl %edx, (%rcx)	# *(mergedArray) = MAX
	addq $0x4, %rcx		# mergedArray ++
	jmp BOTH_ARRAYS_HW1
	# will never reach here
	jmp END_HW1

ONLY_ARRAY_1_HW1:
	test %r8, %r8		# check if array1 is already at 0
	je END_HW1
	
	movl (%rax), %r8d	# %r8 = *Array1
	addq $0x4, %rax		# Array1 ++
	cmp %r8d, %edx		# check if given number already exists in merged
	je ONLY_ARRAY_1_HW1
	
	movl %r8d, %edx		# %rdx = %r8
	movl (%rax), %r8d	# %r8 = *Array1 NOTICE: NEXT NUMBER
	movl %edx, (%rcx)	# *mergedArray = %rdx
	addq $0x4, %rcx		# mergedArray ++
	jmp ONLY_ARRAY_1_HW1	

ONLY_ARRAY_2_HW1:
	test %r9, %r9		# check if array2 is already at 0
	je END_HW1
	
	movl (%rbx), %r9d	# %r9 = *Array2
	addq $0x4, %rbx		# Array2 ++
	cmp %r9d, %edx		# check if given number already exists in merged
	je ONLY_ARRAY_2_HW1
	
	movl %r9d, %edx		# %rdx = %r9
	movl (%rbx), %r9d	# %r9 = *Array2 NOTICE: NEXT NUMBER
	movl %edx, (%rcx)	# *mergedArray = %rdx
	addq $0x4, %rcx		# mergedArray ++
	jmp ONLY_ARRAY_2_HW1	

GET_MAX_HW1:
	cmp %r9d, %r8d 		# *array1 >?> *array2
	ja ARR1_MAX_HW1

	movl %r9d, %r15d		# *array1 =< *array2
	addq $0x4, %rbx		# Array1 ++
	movl (%rbx), %r9d	# %r8 = *(Array1) : NOTICE NEXT VALUE
	jmp CONT_HW1

ARR1_MAX_HW1:
	movl %r8d, %r15d		# *array1 > *array2
	addq $0x4, %rax		# Array2 ++
	movl (%rax), %r8d	# %r9 = *(Array2) : NOTICE NEXT VAULE
	jmp CONT_HW1
	
END_HW1:	





