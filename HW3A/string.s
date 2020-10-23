.data
	string: .space 128
	newl:	.asciiz "\n"
	null:	.asciiz "\0"
	
	promptStr:	.asciiz "Enter a string: "
	promptInt:	.asciiz "Enter an integer: "
	
	lowerBound:	.word 48
	upperBound:	.word 57
	
	lowerBoundLowerCase: .word 97
	upperBoundLowerCase: .word 122
	lowerBoundUpperCase: .word 65
	upperBoundUpperCase: .word 90

.text
	.globl rotate
	.globl replace
	.globl atoi

main:
	la		$a0, promptStr	# prompts user for a string
	li		$v0, 4
	syscall

	la		$a0, string		# gets user input
	li		$a1, 128
	li 		$v0, 8
	syscall

	la 		$a1, newl		# set up for replace call	
	la 		$a2, null
	li 		$v0, 0
	
	jal replace

	la		$a0, string		# print out the string
	li		$v0, 4
	syscall
	
	la		$a0, newl		# prints a newline
	syscall
	
	la		$a0, promptInt	# prompts user for integer
	syscall
	
	li		$v0, 5			# gets user input
	syscall
	
	la		$a0, string		# puts the string in $a0
	move	$a1, $v0		# sets $a1 to user's value for rotate amount
	
	subi	$sp, $sp, 4		# stores $a0 on the stack
	sw		$a0, ($sp)

	jal 	rotate
	
	lw		$a0, ($sp)		# retreives $a0 from stack
	addi	$sp, $sp, 4
	
	li 		$v0, 4			# prints new string
	syscall
	
	la		$a0, newl		# prints newline
	syscall
	
	la		$a0, promptInt	# prompts user for integer
	li		$a1, 128
	syscall
	
	la		$a0, string
	li		$v0, 8			# gets user input as *string*
	syscall
	
	la		$a1, newl
	la		$a2, null
	
	jal 	replace
	
	la		$a0, string
	li		$v0, 0
	li		$v1, 0
	
	jal		atoi
	
	la		$a0, ($v0)		# prints out integer value
	li		$v0, 1
	syscall
	
	la		$a0, newl
	li		$v0, 4
	syscall
	
	li 		$v0, 10
	syscall

rotate:
	lb		$t0, 0($a0)			# gets character in the least significant byte
	beq 	$t0, 0, endRotate	# checks to see if the character is 0, null terminator
	lw		$t3, lowerBoundLowerCase		# stores upper & lower bound of ASCII values
	lw		$t4, upperBoundLowerCase
	lw		$t5, lowerBoundUpperCase
	lw		$t6, upperBoundUpperCase
	
	beq		$a1, 0, endRotate	# if the shift amount is 0 it ends
	bgt		$a1, 26, modShift	# if the shift amount is > 26, it jumps to mod it by 26

continue:
	sge		$t1, $t0, $t3		# $t1 = ($t0 > $t3 ? 1 : 0)
	sle		$t2, $t0, $t4		# $t2 = ($t0 < $t4 ? 1 : 0)
	and		$t1, $t1, $t2		# if it is either less than lower- or greater than upper-bound, $t1 = 0, else 1

	sge		$t7, $t0, $t5		# $t7 = ($t0 > $t5 ? 1 : 0)
	sle		$t8, $t0, $t6		# $t8 = ($t0 < $t6 ? 1 : 0)
	and		$t7, $t7, $t8

	or		$t9, $t1, $t7		# if it is either invalid in the uppercase or lowercase way, then it is 1

	addi	$a0, $a0, 1			# adds one to $a0 to move to next character
	bne		$t9, 1, rotate		# loops back around if it is invalid

	add		$t0, $t0, $a1		# rotates character

return:
	# checks if characters are out of bounds
	sgt		$t2, $t0, $t4		# checks if above uppercase upper boundary
	and		$t1, $t1, $t2		# ands values togther, 1 if it was wihthin uppercase boundary before and no longer is
	beq		$t1, 1, modUpperCase
	
	sgt		$t8, $t0, $t6		# checks if above lowercase upper boundary
	and		$t7, $t7, $t8		# ands values togther, 1 if it was wihthin lowercase boundary before and no longer is
	beq		$t1, 1, modLowerCase

	sb 		$t0, -1($a0)		# writes it into memory
	
	j rotate
	
modShift:
	li		$t9, 26
	div 	$a1, $t9			# divides by lowercase upper bound
	mfhi	$t9					# moves remainder to temp register
	add		$a1, $zero, $t9		# $t0 = remainder + lowercaseLowerBound
	
modLowerCase:
	div 	$t0, $t4			# divides by lowercase upper bound
	mfhi	$t9					# moves remainder to temp register
	add		$t0, $t3, $t1		# $t0 = remainder + lowercaseLowerBound

	j		return				# returns to place in new program with new $t0 value

modUpperCase:
	div 	$t0, $t6			# divides by lowercase upper bound
	mfhi	$t1					# moves remainder to temp register
	add		$t0, $t5, $t1		# $t0 = remainder + lowercaseLowerBound
	subi	$t0, $t0, 1			# subtracts 1 from new value to account for z wrapping to a

	j		return				# returns to place in new program with new $t0 value

endRotate:
	jr 		$ra
	
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

atoi:
	lb		$t0, 0($a0)			# gets character in the least significant byte
	beq 	$t0, 0, endAtoi		# checks to see if the character is 0, null terminator
	lw		$t3, lowerBound		# stores upper & lower bound of ASCII values
	lw		$t4, upperBound
	slt		$t1, $t0, $t3		# $t1 = ($t0 < $t3 ? 1 : 0)
	sgt		$t2, $t0, $t4		# $t2 = ($t0 > $t4 ? 1 : 0)
	or		$t1, $t1, $t2		# if it is either less than lower- or greater than upper-bound, $t1 = 0, else 1
	addi	$v1, $v1, 1			# increment counter
	addi	$a0, $a0, 1			# increment index
	
	beq		$t1, 1, invalid		# if it is invalid, jump to invalid character
	
	# else, convert to int by shifting ascii value by 48
	addi	$t1, $t0, -48
	add		$v0, $v0, $t1

	# mult by 10 and repeat
	mul 	$v0, $v0, 10
	j		atoi
	
invalid:
	la 		$v0, ($v1)			# puts counter into $v0
	mul		$v0, $v0, -1		# mult counter by -1
	jr		$ra					# return

endAtoi:
	div 	$v0, $v0, 10		# divide by 10
	jr 		$ra					# return

