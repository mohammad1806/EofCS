.data

# allocate 6 bytes to store the input we receive from the user
input_buffer:	.space 10

# initialize the balance to 1000$ and the PIN to default "1234".
Balance:	.word 1000
PIN:		.asciiz "1234"

#printing new line 
new_line: 	.asciiz "\n"

# initialize strings to print for PIN thing.
entr_pin:       .asciiz "Enter PIN: "
incorrect_pin:	.asciiz "Error: Incorrect PIN\n"

# add all menu options to an array of adresses
ATM_menu: 	.word main_menu, frt_opt, sec_opt, thrd_opt, frth_opt

# initialize all menu options
main_menu:	.asciiz "Main Menu:\n"
frt_opt:	.asciiz "1. Check Balance\n"
sec_opt:	.asciiz "2. Deposit Money\n"
thrd_opt:	.asciiz "3. Withdraw Money\n"
frth_opt:	.asciiz "4. Exit\n"

# initialize all error messages we might print.
errmsge_pin:	.asciiz "Error: No attempts remaining. Exiting program"
errmsge_IINL: 	.asciiz "Error: Input is not legal\n"
errmsge_DM:	.asciiz "Error: Deposit amount cannot exceed $5000\n"
errmsge_WM:	.asciiz "Error: Insufficient funds or withdrawal limit exceeded\n"

# initialize exit message
exit:		.asciiz "Thank you for using the ATM. Goodbye!"

# strings to print for each option
strb:		.asciiz "Current Balance: $"
strDA:		.asciiz "Enter deposit amount: "
strWA:		.asciiz "Enter withdrawal amount: "
.text 



	li $t9, 3
	PIN_loop:	# starting a loop to the three attempts to enter the PIN
		beq $t9, $zero, print_errPIN   #loop condition
        	li $v0, 4		       
		la $a0, entr_pin               #printing the suitable string
		syscall	
	
		li $v0, 8
   		la $a0, input_buffer           #receive an dstore the pin that user enters
   		li $a1, 10
   		syscall 
   		
   		lw $t8, input_buffer
   		lw $t7, PIN
   		beq $t8, $t7, end_PIN_loop     #ckecking the correctness of the pin ( if pin = "1234" -> exit the loop)
   		
   		li $v0, 4
		la $a0, incorrect_pin          #print a suitable error message
		syscall
		
   		sub $t9, $t9, 1
   		j PIN_loop
   	end_PIN_loop: # ending the loop
  
main:	
   	
	la $s0, ATM_menu
	li $t6, 5
	printMenu_loop:		#starting a loop for printing the menu options
	beq $t6, $zero, end_menu_loop
	li $v0, 4
	lw $a0, 0($s0)
	syscall
	add $s0, $s0, 4 #jumbing to the next element
	sub $t6, $t6, 1
	j printMenu_loop
	end_menu_loop:
	
   	li $v0, 8             # receive and store the number of option that the user pick
   	la $a0, input_buffer
   	li $a1, 6
   	syscall 
   	lb $t0, 0($a0)
    	                      # perform the suitable operation for which the user pick
    	beq $t0, 49, check_Bal
    	beq $t0, 50, deposit_mon
    	beq $t0, 51, withdraw_mon
    	beq $t0, 52, close_ATM
    	
    	j main
    

check_Bal:   
	li $v0, 4	#printing a suitable string for "check balance" operation and the balance we store
	la $a0, strb
	syscall 
	li $v0, 1
	lw $a0, Balance
	syscall
	li $v0, 4	#printing a new line
	la $a0, new_line
	syscall
	j main
	
deposit_mon:

	li $v0, 4	#printing a suitable string for "deposit money" operation
	la $a0, strDA 
	syscall	
	
	li $v0, 8
   	la $a0, input_buffer  #read ant store the input we receive from the user
   	li $a1, 6
   	syscall 
   		
   		jal str_toInt			#calling the "str_toInt" function with the parm $a0 to convert the string we receive to int
   		bgt $v0, 5000, print_errDM	# so we can deal with.
   		lw $t0, Balance
   		add $t0, $t0, $v0
   		sw $t0, Balance
   		
   	j main
   		

withdraw_mon:
	li $v0, 4	#printing a suitable string for "withdraw money" operation
	la $a0, strWA
	syscall	
	
	li $v0, 8
   	la $a0, input_buffer   #read ant store the input we receive from the user
   	li $a1, 6
   	syscall 
   	
   		jal str_toInt			#calling the "str_toInt" function with the parm $a0 to convert the string we receive to int
   		bgt $v0, 500, print_errWM	# so we can deal with.
   		lw $t0, Balance
   		bgt $v0, $t0, print_errWM
   		sub $t0, $t0, $v0
   		sw $t0, Balance
   		
   	j main
	
close_ATM:
	jal print_exit   # printing a suitable string for "exit" operatin and close the program
	li $v0, 10
	syscall 

#functions i helped with--------------------------------------------------------------------------------------------------------#
# this function converts a string to an integer and checks validity of the string
str_toInt:
	li $v0, 0             # Initialize result to 0

        loop:
        lb $t1, 0($a0)     # Load the current character

        # Check for end of string
        beq $t1, 10, end_conversion

        # Check if the character is a numeric digit or newline
        blt $t1, 48, invalid_character
        bgt $t1, 57, invalid_character
        beq $t1, 10, end_conversion  # Handle newline character

        # Convert character to integer
        sub $t1, $t1, 48    # Convert ASCII to integer ('0' -> 0, '1' -> 1, ..., '9' -> 9)

        # Update the result (multiply existing result by 10 and add the new digit)
        mul $v0, $v0, 10
        add $v0, $v0, $t1

        addi $a0, $a0, 1    # Move to the next character
        j loop

    invalid_character:
        jal print_errIINL  #this label call the function that prints an error massge for invalid input
        j main

    end_conversion:
        jr $ra        #return to the line we call this function from
         
#all printing function include error masseges and ending the program
print_errIINL:
	li $v0, 4
	la $a0, errmsge_IINL #illegal input error massege
	syscall	
	j main
print_errDM:
	li $v0, 4
	la $a0, errmsge_DM   #diposit money error massege
	syscall
	j main
print_errWM:
	li $v0, 4
	la $a0, errmsge_WM   # withdraw money error massege
	syscall
	j main
print_exit:
	li $v0, 4
	la $a0, exit     #ending the program message
	syscall 
	jr $ra
print_errPIN:
	li $v0, 4
	la $a0, errmsge_pin  #incorrect pin error massage and ends the program 
	syscall
	li $v0, 10
	syscall
	

