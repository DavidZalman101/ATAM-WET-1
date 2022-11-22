.global _start
.section .text
# num divides by 4 is the first 2 bit (from the lsb) are zero.
# We will shift the number to the right twice, each time checking the CF.

_start:
	movb (num), %al
	sar %al
	jb _NOT_DIVIDED_HW1
	sar %al
	jb _NOT_DIVIDED_HW1
	movb $0x1, (Bool)	
	jmp _EXIT_HW1

_NOT_DIVIDED_HW1:
	movb $0x0, (Bool)	

_EXIT_HW1:
