# MIPS ASSIGNMENT 2
# GOES THROUGH EACH CHARACTER ONE BY ONE CHECKING FOR THE COMMA CHARACTER OR THE NEW-LINE CHARA]
# IF A COMMA CHARACTER SEND THE START AND END INDEX OF TAT PARTICULAR STRING TO A SUB-PROGRAM THAT CALCULATES 
# HEXADECIMAL EQUIVALENT FOR THAT PARTICULAR STRING.
# THEN THE VALUE IS PASSED TO ANOTHER SUBPROGRAM THAT PRINTS OUT THE RESULT.
# CONTINUE TO DO THE SAME UNTIL A NEWLINE CHARACTER.


.data 
	string_space: .space 1001
	comma: .asciiz ","
	undefined: .asciiz "NaN"
	longstring: .asciiz "too large"

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
		# beq, $t2, 10, Exit
		beq $t2, 10, LastSubString
		bne $t2, 44, Next
		j Transition 
	
	LastSubString:
		li $a3, 1
		j Transition
	Next:
	addi $s1, $s1, 1 
	j Loop
	# IF A COMMA, SEND THE START AND THE END INDEX OF THE SUBSTRING TO THE SUBPROGRAM2 TO CONVERT IT INTO EQUIVALENT DECIMAL STRING.
	Transition:
		add $t0, $s1, $s0
		Loop1:
			add $t0, $t0, -1
			lb $t3, ($t0)
			bne $t3, 32, EndFound
			# bne $t3, 9, EndFound
			beq $t3, 44, Error
			j Loop1
		
		EndFound:
		add $t4, $s2, $s0
		Loop3:
			lb $t3, ($t4)
			bne $t3, 32, Done
			# bne $t3, 9, Done
			beq $t3, 44, Error
			add $t4, $t4, 1
			j Loop3
			
	Done:
		sub $t0, $t0, $s0
		sub $t4, $t4, $s0 
		addi $t0, $t0, 1
		add $a0, $t4, $zero # SENDING PARAMETERS TO THE SUBPROGRAM 2 USING THE ARGUMENT REGISTERS.
		add $a1, $t0, $zero
		add $a2, $s0, $zero
		jal subprogram2
	ErrorDestination:
		addi $s1, $s1, 1 # INREASE THE END BECAUSE CURRENTLY POINTING AT THE COMMA CHARACTER.
		add $s2, $s1, $zero # COPY THE END TO THE START FOR THE NEW SUBSTRING TO BE READ.
		j Loop
	
	EmptyString:
		


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
	
		bgt $t9, 8, LongString
		addi $sp, $sp, -4 # USING STACK TO SEND THE CORRESPONDING HEXADECIMAL VALUE TO THE SUBPROGRAM 3.
		sw $t7, ($sp)
		jal subprogram3
		lw $ra, ($sp) # RELOAD THE RETURN ADDRESS FROM THE STACK.
		addi $sp, $sp, 4
		jr $ra
		
		LongString:
			la $a0, longstring
			li $v0, 4
			syscall	
			
			beq $a3, 1, Exit 
			
			la $a0, comma
			li $v0, 4
			syscall
			j ErrorDestination
	

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
		addi, $s4, $s4, -4 # INCLUDES THE SHIFT FOR THE COMMA CHARACTER AS WELL.
		
		bgt $s3, 64, Capital
		bgt $s3, 57, Error
		blt $s3, 48, Error
		addi $s3, $s3, -48
		Final:
			sllv $s5, $s3, $s4
			add $v0, $s5, $zero
			jr $ra
		
		Capital:
			bgt $s3, 70, Small 
			addi $s3, $s3, -55
			j Final
		
		Small:
			blt $s3, 97, Error
			bgt $s3, 102, Error
			addi $s3, $s3, -87
			j Final
			
		Error:
			la $a0, undefined
			li $v0, 4
			syscall	
			
			beq $a3, 1, Exit
			
			la $a0, comma
			li $v0, 4
			syscall
			j ErrorDestination

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
		
		blt $t7, 10, hawa
		next:
		li $k0, 10			# loading the value 10 into $t0
		divu $t7, $k0
		mflo $k0			# loading the quotiend into $s0
		la $a0, 0($k0)
		li $v0, 1
		syscall
		mfhi $k0
		la $a0, 0($k0)
		li $v0, 1
		syscall
		j CommaPrint

		hawa:
		blt $t7, 0, next
		add $a0, $t7, 0
		li $v0, 1
		syscall
		
	CommaPrint:
		beq $a3, 1, Exit
		
		la $a0, comma
		li $v0, 4
		syscall
		jr $ra

	Exit:
		li $v0, 10
		syscall
		
		
	
