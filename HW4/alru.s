# Cole Smith
# CSCI 341
# 9/6/2020
# Program 2A
# This program simulates approximate LRU of a cache
.data
	initial:	.asciiz		"Initial state: "
	accessed:	.asciiz		"Entry accessed: "

	newline:	.asciiz		"\n"
	space:		.asciiz		" "

.text

main:
	la		$a0, initial	# prints prompt for initial state
	li		$v0, 4
	syscall

	li		$v0, 5			# gets user input for initial state
	syscall

	# exits if value is outside of [0,7]
	blt		$v0, 0, exit
	bgt		$v0, 7, exit

	# decomposes initial state into binary, with bits 0-2 stored in $a0-$a2 respectively
	andi	$a0, $v0, 1		# stores bit 0
	srl		$v0, $v0, 1		# shifts $v0 over by 1 to isolate bit 1 in the 0th spot
	andi	$a1, $v0, 1		# stores bit 1
	srl		$v0, $v0, 1
	andi	$a2, $v0, 1		# stores bit 2 

loopBack:
	subi	$sp, $sp, 12	# decrements stack pointer
	sw		$a0, ($sp)		# stores $a0-$a2
	sw		$a1, 4($sp)
	sw		$a2, 8($sp)

	jal print

	# prompts user for next entry accessed & gets input
	la		$a0, accessed
	li		$v0, 4
	syscall

	li		$v0, 5
	syscall

	lw		$a0, ($sp)		# loads $a0-a2
	lw		$a1, 4($sp)
	lw		$a2, 8($sp)
	addi	$sp, $sp, 12	# frees space on the stack

	# exits if the input is invalid
	blt		$v0, 0, exit
	bgt		$v0, 3, exit

	# branches to update appropriate bit
	beq		$v0, 0, zero
	beq		$v0, 1, one
	beq		$v0, 2, two
	beq		$v0, 3, three
	
exit:
	li		$v0, 10
	syscall

print:
	# values used to tell procedures to stop printing after printing both pairs
	li		$t0, 0	# firstPairPrinted = false
	li		$t1, 0	# secondPairPrinted = false

	# jumps to a given procedure depending on which pair should be printed first
	bne		$a2, 0, printFirstPair
	bne		$a2, 1, printSecondPair

printFirstPair:
	and		$t2, $t0, $t1
	beq		$t2, 1, exitPrint

	li		$t0, 1

	# restores $a1 to ensure it holds the correct value during comparison
	lw		$a1, 4($sp)

	# jumps to a given procedure depending which element should be printed first
	bne		$a1, 0, printFirstPairFirst
	bne		$a1, 1, printFirstPairSecond

printFirstPairFirst:
	# prints the first element in the first pair, then the second element in the first pair
	li		$a0, 0
	li		$v0, 1
	syscall

	la		$a0, space
	li		$v0, 4
	syscall

	li		$a0, 1
	li		$v0, 1
	syscall

	la		$a0, space
	li		$v0, 4
	syscall

	# jumps to printing the second pair
	j printSecondPair

printFirstPairSecond:
	# prints the second element in the first pair, then the first element in the first pair
	li		$a0, 1
	li		$v0, 1
	syscall

	la		$a0, space
	li		$v0, 4
	syscall

	li		$a0, 0
	li		$v0, 1
	syscall

	la		$a0, space
	li		$v0, 4
	syscall

	# jumps to printing second pair
	j printSecondPair

printSecondPair:
	and		$t2, $t0, $t1
	beq		$t2, 1, exitPrint

	li		$t1, 1

	# restores $a0 to ensure it holds the correct value during comparison
	lw		$a0, ($sp)

	#jumps to a given procedure depending on which element should be printed first
	bne		$a0, 0, printSecondPairFirst
	bne		$a0, 1, printSecondPairSecond

printSecondPairFirst:
	# prints the first element in the second pair, then the second element in the second pair
	li		$a0, 2
	li		$v0, 1
	syscall

	la		$a0, space
	li		$v0, 4
	syscall

	li		$a0, 3
	li		$v0, 1
	syscall

	la		$a0, space
	li		$v0, 4
	syscall

	# jumps to printing the first pair
	j printFirstPair

printSecondPairSecond:
	# prints the second element in the second pair, then the first element in the second pair
	li		$a0, 3
	li		$v0, 1
	syscall

	la		$a0, space
	li		$v0, 4
	syscall

	li		$a0, 2
	li		$v0, 1
	syscall

	la		$a0, space
	li		$v0, 4
	syscall

	# jumps to printing the first pair
	j printFirstPair

exitPrint:
	la		$a0, newline
	li		$v0, 4
	syscall

	jr		$ra

zero:
	# set value of pair bit
	li		$a2, 1

	# set value of entry bit
	li		$a1, 1

	# jumps back
	j loopBack
	
one:
	# set value of pair bit
	li		$a2, 1

	# set value of entry bit
	li		$a1, 0

	# jumps back
	j loopBack

two:
	# set value of pair bit
	li		$a2, 0

	# set value of entry bit
	li		$a0, 1

	# jumps back
	j loopBack

three:
	# set value of pair bit
	li		$a2, 0

	# set value of entry bit
	li		$a0, 0

	# jumps back
	j loopBack
