# MIPS ASSIGNMENT 2
# GOES THROUGH EACH CHARACTER ONE BY ONE CHECKING FOR THE COMMA CHARACTER OR THE NEW-LINE CHARA]
# IF A COMMA CHARACTER SEND THE START AND END INDEX OF TAT PARTICULAR STRING TO A SUB-PROGRAM THAT CALCULATES 
# HEXADECIMAL EQUIVALENT FOR THAT PARTICULAR STRING.
# THEN THE VALUE IS PASSED TO ANOTHER SUBPROGRAM THAT PRINTS OUT THE RESULT.
# CONTINUE TO DO THE SAME UNTIL A NEWLINE CHARACTER.


.data 
	string_space: .space 1001
	comma: .asciiz ","

.text
	main:
	la $a0, string_space
	li $a1, 1001
	li $v0, 8
	syscall
	li $s2, 0 # $S2 TRACKS THE START OF THE SUBSTRING.
	li $s1, 0 # $S1 TRACKS THE END OF THE SUBSTRING.
	la $s0, string_space # $S0 TRACKS THE START OF THE STRING.
	Loop:
		add $t1, $s0, $s1
		lb $t2, 0($t1)
		beq, $t2, 10, Exit 
		bne $t2, 44, Next
		j Transition 
		
	Next:
	addi $s1, $s1, 1 
	j Loop
	# IF A COMMA, SEND THE START AND THE END INDEX OF THE SUBSTRING TO THE SUBPROGRAM2 TO CONVERT IT INTO EQUIVALENT DECIMAL STRING.
	Transition:
	add $a0, $s2, $zero # SENDING PARAMETERS TO THE SUBPROGRAM 2 USING THE ARGUMENT REGISTERS.
	add $a1, $s1, $zero
	add $a2, $s0, $zero
	jal subprogram2
	addi $s1, $s1, 1 # INREASE THE END BECAUSE CURRENTLY POINTING AT THE COMMA CHARACTER.
	add $s2, $s1, $zero # COPY THE END TO THE START FOR THE NEW SUBSTRING TO BE READ.
	j Loop


	subprogram2:
		###############################################################################
		# Converts a hexadecimal string to it's unsigned decimal equivalent and prints it.
		#
		# Arg registers used: $a0, $a1, $a2	
		# Tmp registers used: <<< >>>
		# $a0 : Index for the start of the sub-string.
		# $a1 : Number of characters to read from.
		# $a2 : Index for the start of the input-string.
		# 
		# Returns: None [Prints the hexadecimal equivalent on the screen]
		# 
		# Called by main
		# Calls: sub-program-1, sub-program-2

		addi $sp, $sp, -4 # STORE THE RETURN ADDRESS TO THE STACK BECAUSE THIS IS A NON-LEAF FUNCTION.
		sw $ra, 0($sp)
		add $t0, $a0, $zero # RESTORING THE VALUES FROM THE ARGUMENT REGISTER INTO THE REGISTERS.
		add $s6 , $a1, $zero
		add $s7 , $a2, $zero
		sub $t9, $s6, $t0 # REGISTER $T9 COUNTS THE LENGTH OF THE SUB-STRING TO BE READ.
		li $t6, 4
		mult $t9, $t6
		mflo $t5 # REGISTER $T5 CALCULATES THE NUMBER OF SHIFTS TO BE MADE FOR THE FIRST CHARACTER IN THE SUB-STRNG.
		li $t7, 0
		Loop2:
			add $t3, $t0, $s7
			lb $t4, ($t3) # SEND THE LOADED CHARACTER TO THE SUBPROGRAM 2 TO CONVERT TO ITS DECIMAL EQUIVALENT.
			add $a0, $t4, $zero
			add $a1, $t5, $zero
			jal subprogram1
			add $s5, $v0, $zero # USING OR TO ADD TO THE TOTAL OF THE EACH CHARACTER IN THE SUBSTRING.
			or $t7, $t7, $s5
			addi $t0, $t0, 1 # INCREASE THE COUNTER BY 1 AFTER EACH LOOP.
			addi $t5, $t5, -4 # REDUCE THE NUMBER OF SHIFTS TO BE MADE AFTER EACH ITERATION.
			bne $t0, $s6, Loop2

		addi $sp, $sp, -4 # USING STACK TO SEND THE CORRESPONDING HEXADECIMAL VALUE TO THE SUBPROGRAM 3.
		sw $t7, ($sp)
		jal subprogram3
		lw $ra, ($sp) # RELOAD THE RETURN ADDRESS FROM THE STACK.
		addi $sp, $sp, 4
		jr $ra
	

	subprogram1:
		###################################################################################
		# Converts a hexadecimal character to it's unsigned decimal equivalent and returns the value to the calling function.
		#
		# Arg registers used: $a0, $a1
		# Tmp registers used: <<< >>>
		# $a0 : Address for that particular character.
		# $a1 : Number denoting the number of left-shifts to be made.
		# 
		# Post: $v0 contains the return value
		# Returns: The decimal equivalent of the input-character.
		# 
		# Called by sub-program-2
		# Calls: None
		
		add $s3, $a0, $zero
		add $s4, $a1, $zero
		addi, $s4, $s4, -4 
		addi $s3, $s3, -87
		sllv $s5, $s3, $s4
		add $v0, $s5, $zero
		jr $ra

	subprogram3:
		###################################################################################
		# Prints out the unsigned decimal equivalent of the value passed in the register. 
		#
		# Arg registers used: None < The parameter is passed through the stack.>
		# Tmp registers used: <<< >>>
		# 
		# Post: Prints out the decimal value.
		# Returns: None
		# 
		# Called by sub-program-2
		# Calls: None

		lw $t7, ($sp)
		addi $sp, $sp, 4
		li $v0, 1
		add $a0, $t7, $zero
		syscall
		jr $ra

	Exit:
		li $v0, 10
		syscall
	
