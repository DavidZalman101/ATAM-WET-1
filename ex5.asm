.global _start
/*
______________________________________________________________________________________________________________________________________________________________________________
	
	We will iterate over the list in the following way (assuming the list is not empty):

[head]----->[  |  ]----->[  |  ]----->[  |  ]----->[  |  ]----->[  |  ]----->[  |  ]----->[  |  ]----->[  |  ]----->[  |  ]----->NULL
   %rax-----^    %rbx----^        

	

______________________________________________________________________________________________________________________________________________________________________________
	*	%rax - The runnig node pointer - will be useful if we'll want to know prev_node_?
	*	%rbx - Will be the node after the running_node_pointer. will let us know if he one of the node_?
	*	%rcx - Will take roll as the counter. We want to find exactly 2 nodes with data if the given value
	*	%rdx - Will hold the data (number) that %rbx hold, remember, rbx is the node after the running node pointer! Will help us figure out if we found a node_?
	*	%r9  - Will hold the address of node_1, if exists
	*	%r8  - Will hold the address of prev_node_1, if exists.
   	*	%r10 - Will hold the address of node_2, if exists
	*	%r11 - Will hold the address of prev_node_2, if exists.
	*	%r12 - Will hold the value of val. help us reduce the # of times we read from memory.
	*	%r13 - Will hold the address of the node after node_1.
	*	%r14 - Will hold the address of the node after node_2.
______________________________________________________________________________________________________________________________________________________________________________


	THE SPECIAL CASES WE TOOK CARE OF:
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	<> IF ONE OF THE WANTED NODES IS THE FIRST NODE OF THE LIST. (WHY DOES IT INTEREST US? NECUASE OF <HEAD>, INSERTING DATA INTO HIM IS DIFFERENT THAN A REGILAR NODE)
	
	<> IF THE 2 WANTED NODES ARE FOLLOWING EACH OTHER. [NODE_A] -> [NODE_B]

	<> COMBINATION OF THE LAST TWO CASES.
______________________________________________________________________________________________________________________________________________________________________________
*/

.section .text
_start:
	xor %rcx, %rcx			# %rcx = 0 
	movl (val), %eax		# %r12 = val. THIS IS WHERE I SPENT A DAY DEBUGGING JUST BECAUSE I USED Q INSTED OF L!!! >_<
	movq %rax, %r12

	movq head, %rax			# %rax = &first_node. 

	test %rax, %rax			# %rax =<?>= NULL
	je END_HW1				

					# We want to check if there is a special case where the first node of the list is node_1
					# if that is the case: prev_node_1 = head	
					# [head = prev_node_1] -> [node_1]

	movq (%rax), %r15		# %r15 = first_node.val
	cmp %r12, %r15			# first_node.val =<?>= val
	je NODE_1_IS_THE_NODE_HW1 	
	
					# At this point we either alrady found node_1 and prev_node_1 (first node, head) or not.

					# just iterating over the list
ITERATION_ON_LIST_HW1:
	movq 8(%rax), %rbx		# %rbx = &next_node
	test %rbx, %rbx			# %rbx =<?>= NULL. meaning: did we reach the end of the list
	je FINISHED_ITERATING_HW1
	movq (%rbx), %rdx		# %rdx = next_node.val 

	cmp %r12, %rdx			# next_node.val =<?>= val. meaning: did we find a node we looked for?
	je FOUND_A_NODE_HW1

CONTINUE_ITERATION_ON_LIST_HW1:
	movq 8(%rax), %rax		# %rax = &next_node. note: we like having a node behind! easy to change the list that way
	jmp ITERATION_ON_LIST_HW1		
	
					# We finish iterating the list, lets conclude what we found out.
FINISHED_ITERATING_HW1:
	cmp $2, %rcx			# counter =<?>= 2. meaning: did we find the 2 nodes we looked for alrady? if so, not good, too many...
	jne END_HW1		
	jmp SWAP_HW1			# there were exactly 2, swap them
		

NODE_1_IS_THE_NODE_HW1:			# [prev_node_1] = [head] 
	inc %rcx			# incease the counter of nodes we found
	movq %rax, %r9			# %r9 = node_1 = &first node.	set node_1
	movq $head, %r8			# %r8 = prev_1_node = &head.	set prev node_1
	movq $1, %r13			# turn on the flag. why? will help us when swapping! see at SWAP code
	jmp ITERATION_ON_LIST_HW1	# continue iteration 

					# we found one of the nodes we were looking for!
FOUND_A_NODE_HW1:
	inc %rcx			# counter ++
	cmp $1, %rcx			# is this the first node we found?
	je FIRST_NODE_FOUND_HW1
	cmp $2, %rcx			# is this the second node we found?
	je SECOND_NODE_FOUND_HW1
	jmp END_HW1			# we found too many! therefor, end the program, no changes will be made!

					# remeber the node_1
FIRST_NODE_FOUND_HW1:
	leaq (%rax), %r8		# %r8 = prev_node_1	
	movq 8(%rax), %r9		# %r9 = node_1
	jmp CONTINUE_ITERATION_ON_LIST_HW1
					# remember the node_2
SECOND_NODE_FOUND_HW1:
	leaq (%rax), %r10		# %r10 = prev_node_2	
	movq 8(%rax), %r11		# %r11 = node_2
	jmp CONTINUE_ITERATION_ON_LIST_HW1

					# swap the nodes we found
SWAP_HW1:
					# SPECIAL CASE: check node_1 and node_2 are following each other. ...-> [node_1] -> [node_2] -> ...
	cmp %r10, %r9
	je NODES_ARE_FOLLOWING_HW1 
	test %r13, %r13			# SPECIAL CASE: check if node_1 if node_1 is the first node in the list
	jne SPECIAL_CASE_HW1		# lazy name...

					# here we take care when prev_node_1 is not the head
	movq 8(%r9), %r13		# %r13 will hold the address of the node after node_1		...->[prev_node_1] -> [node_1] -> [after_node_1] ->...
	movq 8(%r11), %r14		# %r14 will hold the address ot the node after node_2		...->[prev_node_2] -> [node_2] -> [after_node_2] ->...
	
	movq %r11, 8(%r8)		# [pre_node_1] -> [node_2]
	movq %r13, 8(%r11)		# [node_2] -> [after_node_1]
	movq %r9, 8(%r10)		# [pre_node_2] -> [node_1]
	movq %r14, 8(%r9)		# [node_1] -> [after_node_2]
	jmp END_HW1
	 

SPECIAL_CASE_HW1:
	movq 8(%r9), %r13		# %r13 will hold the address of the node after node_1
	movq 8(%r11), %r14		# %r14 will hold the address ot the node after node_2
	 
	movq %r11, (head)		# [head] -> [node_2]
	movq %r13, 8(%r11)		# [node_2] -> [after_node_1]
	movq %r14, 8(%r9)		# [node_1] -> [after_node_2]
	movq %r9, 8(%r10)		# [prev_node_2] -> [node_1]
	jmp END_HW1
	


NODES_ARE_FOLLOWING_HW1:
	test %r13, %r13			# check if this is teh case where prov_node_1 is the head
	jne NODES_ARE_FILLOWING_AND_NODE_1_IS_THE_FIRST_NODE_HW1_HW1			# node_1 is the first node in the list
	
					# [prev_node_1] -> [node_1] -> [node_2] -> [next] ->...
					# [prev_node_1] -> [node_2] -> [node_1] -> [next] ->...
	
	movq %r11, 8(%r8)		#  [prev_node_1] -> [node_2] -> [next] ->...
	movq 8(%r11), %rax		
	movq %rax, 8(%r9)		# [node_1] -> [next] ->...
	movq %r9, 8(%r11)		# [node_2] -> [node_1] -> [next] ->...
	jmp END_HW1

NODES_ARE_FILLOWING_AND_NODE_1_IS_THE_FIRST_NODE_HW1_HW1:
					#	[HEAD] -> [node_1] -> [node_2] -> [next] ->...
					#	[HEAD] -> [node_2] -> [node_1] -> [next] ->...
	movq %r11, (head)		# [HEAD]->[node_2] ->...
	movq 8(%r11), %rax		# [node_1]->[next] ->...
	movq %rax, 8(%r9) 
	movq %r9, 8(%r11)		# [node_2] -> [node_1] ->...
	
END_HW1:
	add %rax, %rbx

