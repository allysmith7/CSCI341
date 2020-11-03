.data
	array: 			.space 	640			# allocates space for 5 words
	
	promptStr1:		.asciiz	"Enter the length of cycle 1: "
	promptStr2:		.asciiz	"Enter the length of cycle 2: "
	promptStr3:		.asciiz	"Enter the length of cycle 3: "
	promptStr4:		.asciiz	"Enter the length of cycle 4: "
	promptStr5:		.asciiz	"Enter the length of cycle 5: "
	
	bracketLeft:	.asciiz "["
	bracketRight:	.asciiz "]"
	comma:			.asciiz ","

.text
	.globl 	longest
	.globl 	overhead
	.globl 	tostring

main:
	la		$a0, promptStr1		# prompt user
	li		$v0, 4
	syscall
	li 		$v0, 5				# get input
	syscall
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
	
	li		$v0, 10
	syscall
	
longest:

overhead:

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