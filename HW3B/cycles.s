.data
	array: 			.space 	640			# allocates space for 5 words
	
	newline:		.asciiz	"\n"
	
	promptStr1:		.asciiz	"Enter the length of cycle 1: "
	promptStr2:		.asciiz	"Enter the length of cycle 2: "
	promptStr3:		.asciiz	"Enter the length of cycle 3: "
	promptStr4:		.asciiz	"Enter the length of cycle 4: "
	promptStr5:		.asciiz	"Enter the length of cycle 5: "
	
	bracketLeft:	.asciiz "["
	bracketRight:	.asciiz "]"
	comma:			.asciiz ","
	
	longestCycle:	.asciiz	"Longest cycle is "

	avgOverhead:	.asciiz	"Average overhead is "

.text
	.globl 	longest
	.globl 	overhead
	.globl 	tostring

main:
	la		$a0, promptStr1		# prompt user for index 0
	li		$v0, 4
	syscall
	li 		$v0, 5				# get input
	syscall
	
	blt		$v0, 0, exit		# jumps if negative
	sw		$v0, array			# store input
	
	
	
	la		$a0, promptStr2		# index 1
	li		$v0, 4
	syscall
	li 		$v0, 5
	syscall	
	sw		$v0, array+128


	
	la		$a0, promptStr3		# index 2
	li		$v0, 4
	syscall
	li 		$v0, 5
	syscall
	sw		$v0, array+256



	la		$a0, promptStr4		# index 3
	li		$v0, 4
	syscall
	li 		$v0, 5
	syscall
	sw		$v0, array+384



	la		$a0, promptStr5		# index 4
	li		$v0, 4
	syscall
	li 		$v0, 5
	syscall
	sw		$v0, array+512
	
	
	
	la		$a0, array			# puts array into $a0 for future calls
	
	jal		tostring			# prints array
	
	la		$a0, newline		# prints newline
	li		$v0, 4
	syscall
	
	jal		longest				# finds longest, stored in $v0
	move	$t0, $v0			# stores longest in $t0
	
	la		$a0, longestCycle	# prints longest cycle message
	li		$v0, 4
	syscall
	
	la		$a0, ($t0)			# prints longest value
	li		$v0, 1
	syscall
	
	la		$a0, newline		# prints newline
	li		$v0, 4
	syscall
	
	jal overhead				# calculates average overhead, stored in $v0
	move	$t0, $v0			# stores average overhead in $t0
	
	la		$a0, avgOverhead	# prints average overhead message
	li		$v0, 4
	syscall
	
	la		$a0, ($t0)			# prints average overhead value
	li		$v0, 1
	syscall
	
	la		$a0, newline		# prints newline
	li		$v0, 4
	syscall
	
	j main
	
exit:
	li		$v0, 10
	syscall
	
longest:
	li		$s0, 5				# establishing counter
	li		$v0, -214748364		# putting min value into $v0 for comparision
	
loopBackLongest:
	# calculate address of new index
	subi	$t1, $s0, 1
	mul		$t2, $t1, 128
	lw		$t0, array($t2)
	
	# compare current value to v0
	bgt		$t0, $v0, newMax	# branch to set new max or loop to next
	
	subi	$s0, $s0, 1			# decrement counter
	bne		$s0, 0, loopBackLongest		# loops back
	jr		$ra
	
newMax:
	lw		$v0, array($t2)		# set new max
	
	subi	$s0, $s0, 1			# decrement counter
	bne		$s0, 0, loopBackLongest		# loop back
	jr		$ra





overhead:
	subi	$sp, $sp, 8			# allocate space on stack for $a0, $ra
	sw		$a0, ($sp)			# store $a0 on stack
	sw		$ra, 4($sp)			# store $ra
	
	jal 	longest				# get longest value
	
	move	$t0, $v0			# stores longest in $t0
	
	lw		$a0, ($sp)			# retreive $a0 from stack
	lw		$ra, 4($sp)
	addi	$sp, $sp, 8			# deallocate stack space
	
	
	# calculate sum of values in the array
	li		$s0, 5				# initiating counter
	li		$v0, 0				# sets return value to 0, to be added to

loopBackOverhead:
	# calculate address of new index
	subi	$s0, $s0, 1
	mul		$t2, $s0, 128
	lw		$t3, array($t2)
	
	sub		$t4, $t0, $t3
	
	add		$v0, $v0, $t4		# adds new value on
	
	bne		$s0, 0, loopBackOverhead
	
	div		$v0, $v0, 5
	
	jr		$ra

tostring:
	la		$a0, bracketLeft	# prints left bracket
	li		$v0, 4
	syscall
	
	lw		$a0, array
	li		$v0, 1
	syscall
	
	la		$a0, comma
	li		$v0, 4
	syscall
	
	lw		$a0, array+128
	li		$v0, 1
	syscall
	
	la		$a0, comma
	li		$v0, 4
	syscall
	
	lw		$a0, array+256
	li		$v0, 1
	syscall
	
	la		$a0, comma
	li		$v0, 4
	syscall
	
	lw		$a0, array+384
	li		$v0, 1
	syscall
	
	la		$a0, comma
	li		$v0, 4
	syscall
	
	lw 		$a0, array+512
	li		$v0, 1
	syscall
	
	la 		$a0, bracketRight
	li		$v0, 4
	syscall
	
	jr		$ra
