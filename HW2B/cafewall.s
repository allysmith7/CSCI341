.data
	frame:			.space 		0x80000
	promptSize:		.asciiz 	"Enter the side length in px: "
	promptCount: 	.asciiz 	"Enter the number of pairs you want: "

.text
main:
	la 		$a0, promptSize 	# loads the prompt value
	li 		$v0, 4				# sets up system call to print a string
	syscall						# prints
	
	li 		$v0, 5				# sets up system call to read in
	syscall 					# gets the input
	
	add 	$a1, $zero, $v0		# stores size input in $a1
	
	la 		$a0, promptCount 	# loads the prompt value
	li 		$v0, 4				# sets up system call to print a string
	syscall						# prints
	
	li 		$v0, 5				# sets up system call to read in
	syscall 					# gets the input
	
	add		$s4, $zero, $v0		# stores input in $s4 to be used later
	mul 	$s5, $s4, 2			# also stores twice the input
	
	addi 	$a0, $zero, 10		# x offset from top left corner
	addi 	$a2, $zero, 10		# y offset from top left corner
	addi 	$a3, $zero, 0x00ffffff	# color
	
	jal 	setUpVertical

	addi 	$v0, $zero, 10	 	# exit
	syscall

square:

	beq  	$a1, $zero, squareReturn 	# zero width: draw nothing

	add 	$t0, $zero, $a3 			# color: white
	la   	$t1, frame
	add		$t7, $zero, $a1
    add  	$a1, $a1, $a0 				# simplify loop tests by switching to first too-far value
	add  	$t7, $t7, $a2
	sll  	$a0, $a0, 2 				# scale x values to bytes (4 bytes per pixel)
	sll  	$a1, $a1, 2
	sll  	$a2, $a2, 11 				# scale y values to bytes (512*4 bytes per display row)
	sll  	$t7, $t7, 11
	addu 	$t2, $a2, $t1 				# translate y values to display row starting addresses
	addu 	$t7, $t7, $t1
	addu 	$a2, $t2, $a0 				# translate y values to square row starting addresses
	addu 	$t7, $t7, $a0
	addu 	$t2, $t2, $a1 				# and compute the ending address for first square row
	addi 	$t4, $zero, 0x800 			# bytes per display row

squareYloop:
	move 	$t3,$a2 					# pointer to current pixel for X loop; start at left edge

squareXloop:
	sw 		$t0, 0($t3)
	addiu 	$t3, $t3, 4
	bne 	$t3, $t2, squareXloop 		# keep going if not past the right edge of the square

	addu 	$a2, $a2, $t4 				# advance one row for the left edge
	addu 	$t2, $t2, $t4 				# and right edge pointers
	bne 	$a2, $t7, squareYloop 		# keep going if not off the bottom of the square

squareReturn:
    jr 		$ra
    
drawPair:
	addi	$a3, $zero, 0x000000FF 		# sets color to blue

	subi 	$sp, $sp, 16				# allocates memory on stack
	sw		$ra, ($sp)					# saves $ra
	sw		$a0, 4($sp)					# saves $a0-$a2
	sw		$a1, 8($sp)
	sw		$a2, 12($sp)

	jal 	square						# draws white square

	lw 		$a2, 12($sp)				# retrieves $a0-$a2
	lw		$a1, 8($sp)
	lw		$a0, 4($sp)

	add 	$a0, $a0, $a1				# shifts x offset by size
	addi	$a3, $zero, 0x00FFFFFF		# changes color to white

	jal		square						# draws blue square

	lw 		$a2, 12($sp)				# retrieves $a0-$a2
	lw		$a1, 8($sp)
	lw		$a0, 4($sp)

	lw		$ra, ($sp)					# retrieves $ra
	addi	$sp, $sp, 16				# frees memory on stack

	jr		$ra							# jumps back

drawRow:
	subi	$sp, $sp, 12				# allocates memory to stack
	sw		$ra, ($sp)					# stores $ra
	sw		$s4, 4($sp)					# stores s4 and s5
	sw		$s5, 8($sp)
	
	beq		$s0, $s4, checkIfOffset		# check if it is the first pair in the row
continue:	
	jal		drawPair					# draws a pair
	
	lw		$ra, ($sp)					# retrieves $ra
	lw		$s4, 4($sp)					# retrieves s4 and s5
	lw		$s5, 8($sp)
	addi	$sp, $sp, 12				# frees memory from stack
	
	subi	$s0, $s0, 1					# decrements counter
	
	add		$a0, $a0, $a1				# changes x offset by 2 times the size
	add		$a0, $a0, $a1			
	
	bne 	$s0, $zero, drawRow			# loops back if it hasn't reached end condition
	
	jr		$ra							# otherwise it returns to caller
	
setUpHorizontal:
	add 	$s0, $zero, $s4				# counter for loop, uses user input in $s4
	
	subi	$sp, $sp, 8					# allocates memory on stack
	sw		$ra, ($sp)					# stores $ra
	sw		$a0, 4($sp)					# stores a0 since it will be changed in drawRow
	
	jal		drawRow
	
	lw		$ra, ($sp)					# retrieves $ra
	lw		$a0, 4($sp)					# retrieves $a0
	addi	$sp, $sp, 8					# frees memory from the stack
	
	jr		$ra							# jumps back to caller
	
drawNextRow:
	subi	$sp, $sp, 4					# allocates memory on stack
	sw		$ra, ($sp)					# stores sp
	
	jal 	setUpHorizontal
	
	lw		$ra, ($sp)					# reloads ra
	addi	$sp, $sp, 4					# frees memory
	
	add		$a2, $a2, $a1				# shifts down by size
	addi	$a2, $a2, 2					# adds 'mortar' gap
	
	subi	$s1, $s1, 1					# decrements counter
	
	bne		$s1, $zero, drawNextRow		# loops back if end condition isn't met
	
	jr		$ra							# jumps back to caller
	
setUpVertical:
	add		$s1, $zero, $s5				# sets up loop counter
	
	subi	$sp, $sp, 4					# allocate memory on stack
	sw		$ra, ($sp)					# stores $ra
	
	jal 	drawNextRow

	lw		$ra, ($sp)					# retrieves $ra
	addi	$sp, $sp, 4					# frees memory from stack
	
	jr		$ra							# jumps back to caller
	
offset:
	div		$t9, $a1, 2					# calculates half of the size
	add		$a0, $a0, $t9				# adds it to the x offset
	j		continue					# jumps back to the drawRow procedure
	
checkIfOffset:
	andi 	$t8, $s1, 0x1				# if $s1 (row number) is odd, $t8 will be 1
	bne		$t8, $zero, offset			# if $t8 is 1, branches to offset
	
	j continue							# otherwise it will just go back to drawRow
	
	
