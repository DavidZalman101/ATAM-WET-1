.global _start
/*	
	We will iterate over the list in the following way (assuming the list is not empty):

[head]----->[  |  ]----->[  |  ]----->[  |  ]----->[  |  ]----->[  |  ]----->[  |  ]----->[  |  ]----->[  |  ]----->[  |  ]----->NULL
   %rax-----^    %rbx----^        
*/	
/*
	%rax - The runnig node pointer - will be useful if we'll want to know prev_node_?
	%rbx - Will be the node after the running_node_pointer. will let us know if he one of the node_?
	%rcx - Will take roll as the counter. We want to find exactly 2 nodes with data if the given value
	%rdx - Will hold the data (number) that %rbx hold, remember, rbx is the node after the running node pointer! Will help us figure out if we found a node_?
	%r9  - Will hold the address of node_1, if exists
	%r8  - Will hold the address of prev_node_1, if exists.
   	%r10 - Will hold the address of node_2, if exists
	%r11 - Will hold the address of prev_node_2, if exists.
	%r12 - Will hold the value of val. help us reduce the # of times we read from memory.
*/

.section .text
_start:
	xor %rcx, %rcx			# reset the couunter to be 0
	movl (val), %eax		# hold the val in %r12
	movq %rax, %r12

	movq head, %rax			# %rax = &first_node. note: %rax will be the running pointer

	test %rax, %rax			# check whether the list is empy
	je END				# &first_node == NULL ?
					# if it is: there is nothing to do, end the prog.

					# We want to check if there is a special case where the first node is node_1
					# if that is the case: prev_node_1 = head	

	movq (%rax), %r15		# %r15 = value of the first node
	cmp %r12, %r15		# check whether the first node is node_1
	je NODE_1_IS_THE_FIRST_NODE 	# it is: head will be the prev_node_1 and the first node will be node_1 
	
					# At this point we either alrady found node_1 and prev_node_1 (first node, head) or not.

ITERATION_ON_LIST:
	movq 8(%rax), %rbx		# %rbx = &next pointer
	test %rbx, %rbx			# check if we reached the end of the list
	je FINISHED_ITERATING
	movq (%rbx), %rdx		# %rdx = value that the next node holds

	cmp %r12, %rdx			# check if we found another node
	je FOUND_A_NODE

CONTINUE_ITERATION_ON_LIST:
	movq 8(%rax), %rax		# move the runnig node pointer to the next node ( whre rbx is at now )
	jmp ITERATION_ON_LIST		# iterate
	
FINISHED_ITERATING:
	cmp $2, %rcx			# check if there were exactly 2 nodes
	jne END		
	jmp SWAP			# there were exactly 2, swap them
		

NODE_1_IS_THE_FIRST_NODE:		# set head to be prev_node_1 and the first node to be node_1
	inc %rcx			# incease the counter of nodes we found
	movq %rax, %r9			# %r9 = node_1 = &first node.	set node_1
	movq $head, %r8			# %r8 = prev_1_node = &head.	set prev node_1
	movq $1, %r13			# turn on flag			# TODO: REMEMBER WHY THE FUCK I WANTED THIS FLAG
	jmp ITERATION_ON_LIST 		# continue iteration 

# TODO: what happened when we found more than 2?
FOUND_A_NODE:
	inc %rcx			# counter ++
	cmp $1, %rcx
	je FIRST_NODE_FOUND
	cmp $2, %rcx
	je SECOND_NODE_FOUND
	jmp END				# if we reached here that means we have more than 2 nodes in the list with the value val

# reminder: %rax = &the running pointer (will be prev_node_1), and %rbx will be node_1
FIRST_NODE_FOUND:
	leaq (%rax), %r8		# %r8 = prev_node_1	
	movq 8(%rax), %r9		# %r9 = node_1
	jmp CONTINUE_ITERATION_ON_LIST

# reminder: %rax = &the running pointer (will be prev_node_2), and %rbx will be node_2
SECOND_NODE_FOUND:
	leaq (%rax), %r10		# %r10 = prev_node_2	
	movq 8(%rax), %r11		# %r11 = node_2
	jmp CONTINUE_ITERATION_ON_LIST

SWAP:
					# Check if node_1 and node_2 are following eachh other (very annoying specail case)
	cmp %r10, %r9
	je NODES_ARE_FOLLOWING 
	test %r13, %r13			# check if this is the case where prev_node_1 is the head
	jne SPECIAL_CASE
					# here we take care when prev_node_1 is not the head
	# prev_node_1 will point (as a next node) at node_2
	# prev_node_2 will point (as a next node) at node_1
	# node_1 will point (as a next node) to whom node_2 pointed to.
	# node_2 will point (as a next node) to whom node_1 pointed to.
	movq 8(%r9), %r13		# %r13 will hold the address of the node after node_1
	movq 8(%r11), %r14		# %r14 will hold the address ot the node after node_2
	
	movq %r11, 8(%r8)		# [pre_node_1] -> [node_2]
	movq %r13, 8(%r11)		# [node_2] -> [after_node_1]
	movq %r9, 8(%r10)		# [pre_node_2] -> [node_1]
	movq %r14, 8(%r9)		# [node_1] -> [after_node_2]
	jmp END
	 

SPECIAL_CASE:
	movq 8(%r9), %r13		# %r13 will hold the address of the node after node_1
	movq 8(%r11), %r14		# %r14 will hold the address ot the node after node_2
	 
	movq %r11, (head)		# [head] -> [node_2]
	movq %r13, 8(%r11)		# [node_2] -> [after_node_1]
	movq %r14, 8(%r9)		# [node_1] -> [after_node_2]
	movq %r9, 8(%r10)		# [prev_node_2] -> [node_1]
	jmp END
	


NODES_ARE_FOLLOWING:
	test %r13, %r13			# check if this is teh case where prov_node_1 is the head
	jne HERE			# node_1 is the first node in the list
	
					# [prev_node_1] -> [node_1] -> [node_2] -> [next] ->...
					# [prev_node_1] -> [node_2] -> [node_1] -> [next] ->...
	
	movq %r11, 8(%r8)		#  [prev_node_1] -> [node_2] -> [next] ->...
	movq 8(%r11), %rax		
	movq %rax, 8(%r9)		# [node_1] -> [next] ->...
	movq %r9, 8(%r11)		# [node_2] -> [node_1] -> [next] ->...
	jmp END

HERE:
				#	[HEAD] -> [node_1] -> [node_2] -> [next] ->...
				#	[HEAD] -> [node_2] -> [node_1] -> [next] ->...
	movq %r11, (head)	# [HEAD]->[node_2] ->...
	movq 8(%r11), %rax	# [node_1]->[next] ->...
	movq %rax, 8(%r9) 
	movq %r9, 8(%r11)	# [node_2] -> [node_1] ->...
	
END:
	add %rax, %rbx

