.data
	string: .space 128
	newl:	.asciiz "\n"
	null:	.asciiz "\0"
	
	promptStr:	.asciiz "Enter a string: "
	promptInt:	.asciiz "Enter an integer: "
	
	lowerBound:	.word 48
	upperBound:	.word 57

.text
	.globl rotate
	.globl replace
	.globl atoi

main:
	la		$a0, promptStr	# prints prompt
	li		$v0, 4
	syscall

	la		$a0, string
	li		$a1, 128
	li 		$v0, 8			# gets user input
	syscall

	la 		$a1, newl		
	la 		$a2, null
	li 		$v0, 0			# sets counter to 0
	
	subi	$sp, $sp, 12
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)
	sw		$a2, 8($sp)
	
	jal 	replace
	
	la		$a0, string
	li		$v0, 4
	syscall
	
	li 		$v0, 10
	syscall


	
replace:
	lb		$t0, 0($a0)			# loads first byte from $a0 into $t0
	lb		$t1, 0($a1)			# loads first byte of "old"
	lb		$t2, 0($a2)			# loads first byte of "new"
	beqz	$t0, endReplace		# checks to see if the character is 0, which is the ASCII code for the null terminator, aka end of string
	addi	$a0, $a0, 1			# adds one to $a0 to move to next character
	bne 	$t0, $t1, replace	# loops back if the old character isn't found
	
	# if it is found, the following code will run
	sb 		$t2, -1($a0)		# uses offset of -1 since we already shifted $a0
	addi	$v0, $v0, 1			# increments counter
	j replace

endReplace:
	jr 		$ra					# jumps back to where it was called from


rotate:

atoi:
	lb		$t0, 0($a0)
	lw		$t3, lowerBound		# stores upper & lower bound of ASCII values
	lw		$t4, upperBound
	slt		$t1, $t0, $t3		# $t1 = ($t0 < $t3 ? 1 : 0)
	sgt		$t2, $t0, $t4		# $t2 = ($t0 > $t4 ? 1 : 0)
	or 		$t1, $t1, $t2		# if it is either less than lower- or greater than upper-bound, $t1 = 1, else 0
	
	# jump to invalid character
	
	# else, convert to int
	
	# if next character exists, mult by 10 and repeat
	
	
