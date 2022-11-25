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

BACK_HW1:
	test %dx, %dx
	je _NEGATIVE_CONT_HW1
	jmp _NON_NEGATIVE_CONT_HW1

_NEGATIVE_HW1:
	movw $0x00, %dx 		# %rdx = 0
	movq $destination, %rax		 
	xor $0xffffffff, %ecx
	inc %ecx
	jmp INSERT_DATA_TO_STACK_HW1
_NEGATIVE_CONT_HW1:
	movq $destination, %rax		# %rax = &destination
	jmp _FUNC_HW1

_NON_NEGATIVE_HW1:
	movq $destination, %rax		 
	movw $0x01, %dx 		# %rdx = 1
	jmp INSERT_DATA_TO_STACK_HW1
_NON_NEGATIVE_CONT_HW1:
	lea -1(%rax, %rcx, 1), %rax  	# %rax = &destination + |num|
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
	

	popq %r8
	movb %r8b, (%rax)
	test %dx, %dx
	je _INC_HW1
	jmp _DEC_HW1

_CONT_HW1:
	dec %ecx
	jmp _FUNC_HW1 
					# push 
INSERT_DATA_TO_STACK_HW1:
	movq %rcx, %r11			# r11 = counter = num
	test %r11, %r11
	je _EXIT_HW1			# counter = 0 -> there is nothing to copy 
ITERETE_HW1:
	movb (%rbx), %r10b		# r10 = *(%rbx)
	inc %rbx			# rbx++
	push %r10			# store in the stack
	dec %r11
	test %r11, %r11			# check if there is more to push to the stack
	je _CHECK_WHERE_TO_RETURN_HW1
	jmp ITERETE_HW1
	
_CHECK_WHERE_TO_RETURN_HW1:
	test %dx, %dx
	je _NEGATIVE_CONT_HW1
	jmp _NON_NEGATIVE_CONT_HW1
	
_EXIT_HW1:

