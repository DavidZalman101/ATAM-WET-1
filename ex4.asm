.global _start

.section .text
/*
	*	%rax - points to the current running node.
	*	%rbx - hold the value of the current running pointer.
	*	%rcx - holds the value of the new node.
	*	%rdx - hold the pointer to the father of the current running node (if exists)
	*	%r15 - flag - current_node = left_son : righ_son ? 1 : 0
	*	
	*
	*
	*
	*
	*
	*
*/

_start:

# initialize values

	movq (root), %rax	# %rax = &root = currnet node
	movq %rax, %rdx		# %rdx will keep track of the last current node
	test %rax, %rax		# check if tree is empty
	je EMPTY_HW1 

	movq (%rax), %rbx	# %rbx = current_val
	movq (new_node), %rcx	# %rcv = new_node_val

CHECK_CURRENT_NODE_HW1:
	cmp %rcx, %rbx		# check if current node_val == new_node_val
	jg GO_LEFT_HW1
	jl GO_RIGHT_HW1
	jmp END_HW1

GO_LEFT_HW1:
	movq %rax, %rdx		# keep track of last node
	movq $0x1, %r15		#update the falg that reminds us which son we are
	leaq 8(%rax), %rax		
	movq (%rax), %rax	# %rax = &left_son
	test %rax, %rax		# check if we reached the end of the tree
	je INSERT_HW1	
	movq (%rax), %rbx	# %rax = left_son_val		
	jmp CHECK_CURRENT_NODE_HW1

GO_RIGHT_HW1:
	movq %rax, %rdx		# keep track of last node
	movq $0x0, %r15		#update the flag that reminds us which son we are
	leaq 16(%rax), %rax	
	movq (%rax), %rax	# %rax = $right_son
	test %rax, %rax		# check if we reached the end of the tree
	je INSERT_HW1		
	movq (%rax), %rbx	# %rax = right_son_val
	jmp CHECK_CURRENT_NODE_HW1
	
INSERT_HW1:
	test %r15, %r15
	je HE_IS_MY_RIGHT_SON_HW1
	jmp HE_IS_MY_LEFT_SON_HW1

HE_IS_MY_RIGHT_SON_HW1:
	lea 16(%rdx), %rdx	
	movq $new_node, (%rdx)
	jmp END_HW1

HE_IS_MY_LEFT_SON_HW1:
	lea 8(%rdx), %rdx
	movq $new_node, (%rdx)
	jmp END_HW1
EMPTY_HW1:
	movq $new_node, (root)

END_HW1:
