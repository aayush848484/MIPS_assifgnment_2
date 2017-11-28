# MIPS ASSIGNMENT 2
# GOES THROUGH EACH CHARACTER ONE BY ONE CHECKING FOR THE COMMA CHARACTER OR THE NEW-LINE CHARA]
# IF A COMMA CHARACTER SEND THE START AND END INDEX OF TAT PARTICULAR STRING TO A SUB-PROGRAM THAT CALCULATES 
# HEXADECIMAL EQUIVALENT FOR THAT PARTICULAR STRING.
# <<<< PRINTING THE VALUES >>>>>>>>>>
# 

.data # DATA DECLARATION
string_space: .space 1001 # Array space of 1000 bytes for the input string.

.text
main: # STARTING POINT OF THE APPLICATION.


#######################################################
###############TAKING THE INPUT FROM THE USER.#########
la $a0, string_space
li $a1, 1001

li $v0, 8
syscall

########################################################
# INITIALIZING THE $S2 WITH 0 TO KEEP TRACK OF THE START POINT FOR THE CONVERSION SUB-ROUTINE.

li $s2, 0 # $s2 keeps track of the start of the string to be sent to the helper subprogram.

########################################################
# GOING THROUGH EACH CHARACTER IN THE STRING TO FIND THE END OF STRING.

li $s1, 0 # $s1 keeps track of the end of the sub-string to be sent to the helper sub-program.
la $s0, string_space
Loop:
	add $t1, $s0, $s1
	addi $s1, 1
	lb $t2, 0($t1)
	beq, $t2, 10, Exit 
	bne $t2, 44, Loop
# If a comma, call the sub-program with the following parameters:
# 1. Start index contained in $S2
# 2. End index contained in $S1
# 3. Start index of the string_space contained in $s0

add $a0, $s2, $zero 
add $a1, $s1, $zero
add $a2, $s0, $zero 
jal sub-program-2
add $s2, $s1, $zero # Start of the new sub-string is equal to end of the previous of substring once sub-program 2 is executed.
j Loop


sub-program-2:
###############################################################################
# Converts a hexadecimal string to it's unsigned decimal equivalent and prints it.
#
# Arg registers used: $a0, $a1, $a2
# Tmp registers used: <<< >>>
# $a0 : Index for the start of the sub-string.
# $a1 : Index for the end of the sub-string.
# $a2 : Index for the start of the input-string.
# 
# Returns: None [Prints the hexadecimal equivalent on the screen]
# 
# Called by main
# Calls: sub-program-1, sub-program-2

# Update the return address to the stack.
addi $sp, -4
sw $ra, 0($sp)

add $t0, $a0, $zero
add $t1, $a1, $zero
add $t2, $a2, $zero


# Need to find the length of the string to find the number of left shifts.

sub $t5, $t1, $t0
li $t6, 4
mult $t5, $t6
mflo $t5 # Here $t5 contains the number of shifts that needs to be made for the first character of the sub-string passed.


# Add start to $t2 and start reading from that point.
add $t3, $t0, $t2

# Going through the loop, reduce the $t5 content by 4 each time. 
li $t7, 0
Loop:
	lb $t4, ($t3)
	# Send this character to the sub-program-1 to calculate the hexadecimal equivalent 
	# for that particular character.
	add $a0, $t4
	add $a1, $t5
	jal sub-program-1
	# Sub-program uses $v0 to return the hexadecimal equivalent. Use or to merge the value to the temporary value.
	add $s5, $v0, $zero
	or $t7, $t7, $s5
	addi $t0, $t0, 1
	bne $t0, $t1, Loop
	
# Once the sub-string is read completely, use sub-program 3 to print the content of that register. 
addi $sp, $sp, -5
sw $ra, 1($sp)
sb $t7, 0($sp)
jal sub-program-3
# Sub-program 3 updates the stack so that the head points to the return address for this function.
lw $ra, ($sp)
jr $ra

sub-program-1:
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

add $t0, $a0, $zero
add $t1, $a1, $zero


sll $t2, $t0, $t1
add $v0, $t2, $zero
jr $ra

sub-program-3:
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

lb $t0, 0($sp)
addi $sp, $sp, -1

# Using system call to print the string. 
li $v0, 1
add $a0, $t0, $zero

syscall
lw $ra, 0($sp)
addi $sp, $sp, -4
jr $ra



Exit:
li $v0, 100
syscall
