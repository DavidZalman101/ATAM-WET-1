.global _start
# We will go over the destination from left to right if num is non negative
# otherwise, we will go from the destination + |num| from right to left

/*
				num = rcx >= 0
SOURCE:	[ ][ ][ ][ ][ ][ ][ ][ ] DESTINATION: [ ][ ][ ][ ][ ][ ][ ][ ]
rbx------^                              rax----^

				inc = rdx = +1
*/

/*
				num = rcx <  0
SOURCE:	[ ][ ][ ][ ][ ][ ][ ][ ]  DESTINATION: [ ][ ][ ][ ][ ][ ][ ][ ]
rbx------^              			              rax----^
	
				inc = rdx = -1
*/
.section .text
_start:
# 
	movl (num), %ecx 		# %rcx = num
	movq $source, %rbx		# %rbx = &source
	test %ecx, %ecx		        # cheking if num is non-negative	
	js _NEGATIVE_HW1
	jmp _NON_NEGATIVE_HW1

_NON_NEGATIVE_HW1:
	movq $destination, %rax		# %rax = &destination
	movw $0x01, %dx 		# %rdx = +1
	jmp _FUNC_HW1

_NEGATIVE_HW1:
	movq $destination, %rax		 
	xor $0xffffffff, %ecx
	lea (%rax, %rcx, 1), %rax  	# %rax = &destination + |num|
	inc %ecx
	movw $-0x01, %dx 		# %rdx = -1
	jmp _FUNC_HW1

_INC_HW1:
	inc %rax
	jmp _CONT_HW1

_DEC_HW1:
	dec %rax
	jmp _CONT_HW1

_FUNC_HW1:
	test %ecx, %ecx			# checking if we copied all
	je _EXIT_HW1	
	
	movb (%rbx), %r8b
	movb %r8b, (%rax)		# *(%rax) = *(%rbx)
	inc %rbx			#  %rbx ++
	test %dx, %dx
	js _DEC_HW1
	jmp _INC_HW1
_CONT_HW1:
	dec %ecx
	jmp _FUNC_HW1 

_EXIT_HW1:

