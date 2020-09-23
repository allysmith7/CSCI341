# Cole Smith
# CSCI 341
# 9/6/2020
# Program 2A
# This program takes user input in the form of an integer and prints out the value of the sign bit
# 		and the individual bytes from most to least significant.
.data

newline:	.asciiz "\n"
spacing:	.asciiz " "
prompt:		.asciiz "Enter an integer: "
sign:		.asciiz "Sign bit is: "
byte:		.asciiz "Bytes are: "

.text

main:
	# takes integer input from the user
	la $a0, prompt 		# loads the prompt value
	li $v0, 4			# sets up system call to print a string
	syscall				# prints
	
	li $v0, 5			# sets up system call to read in
	syscall 			# gets the input
	
	move $t0, $v0		# stores the input in $t0 for future use
	
	# isolate sign bit
	srl $t1, $t0, 31	# shifts right 31 bits to isolate sign bit
	la $a0, sign		# loads the string
	li $v0, 4			# sets syscall to print a string
	syscall				# prints string
	
	la $a0, ($t1)		# loads bit into $a0 for printing
	li $v0, 1			# sets syscall to print an *integer*
	syscall				# prints
	
	la $a0, newline		# loads a newline character
	li $v0, 4			# sets syscall to print a string
	syscall				# prints
	
	
	# isolates bytes
	# $t2 is the leftmost byte $t3 second leftmost, etc.
	
	# sets up $t2 to hold leftmost byte
	srl $t2, $t0, 24
	
	# $t3
	sll $t3, $t0, 8		# eliminate leftmost byte
	srl $t3, $t3, 24	# eliminate three rightmost bytes
	
	# $t4
	sll $t4, $t0, 16	# eliminate two leftmost bytes
	srl $t4, $t4, 24	# eliminate three rightmost bytes
	
	# $t5
	sll $t5, $t0, 24	# eliminate three leftmost bytes
	srl $t5, $t5, 24	# eliminate three rightmost bytes
	
	# sets up print calls
	la $a0, byte		# loads prompt
	li $v0, 4			# sets up syscall to print string
	syscall				# prints
	
	li $v0, 1			# sets up syscall to print integers
	la $a0, ($t2)		# loads leftmost byte
	syscall				# prints
	li $v0, 4			# sets syscall to print strings
	la $a0, spacing		# loads spacing into $a0 
	syscall				# prints
	
	li $v0, 1			# sets up syscall to print integers
	la $a0, ($t3)		# loads 2nd leftmost byte
	syscall				# prints
	li $v0, 4			# sets syscall to print strings
	la $a0, spacing		# loads spacing into $a0 
	syscall				# prints
	
	li $v0, 1			# sets up syscall to print integers
	la $a0, ($t4)		# loads 2nd rightmost byte
	syscall				# prints
	li $v0, 4			# sets syscall to print strings
	la $a0, spacing		# loads spacing into $a0 
	syscall				# prints
	
	li $v0, 1			# sets up syscall to print integers
	la $a0, ($t5)		# loads rightmost byte
	syscall				# prints
	li $v0, 4			# sets syscall to print strings
	la $a0, spacing		# loads spacing into $a0 
	syscall				# prints
	
	# end the program
	li $v0, 10			# sets syscall to exit
	syscall				# exits
