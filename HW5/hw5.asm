.data

#my data structure
Size:			.word 0
buffer: 		.space 104
CustomersRecords: 	.space 40

main_Menu: 		.asciiz "\nMain Menu:\n1. add_customer\n2. display_customer\n3. update_balance\n4. delete_customer\n5. exit_program\nEnter your choice (1-5): "

#error messages
invalid_choice:		.asciiz "Invalid choice. Please enter a number between 1 and 5.\n"
err_cus:		.asciiz "Error: Customer "
al_ex:			.asciiz " already exists\n"
doesnt_ex:		.asciiz " doesn't exist\n"
invalid_bal:		.asciiz "Error: The inputted balance isn't valid\n"

#success messages
success_cus:		.asciiz "Success: Customer "
success:		.asciiz "Success: "
added:			.asciiz " was added\n"
deleted:		.asciiz " deleted\n"
exit:			.asciiz "Exiting program"

#input messages
enter_id:		.asciiz "Enter ID: "
enter_Name:		.asciiz "Enter Name: "
enter_bal:		.asciiz "Enter Balance: "
enter_newbal:		.asciiz "Enter New Balance: "

co_sp:			.asciiz ", "
new_line:		.asciiz "\n"
.text 

	la $s0, CustomersRecords
main:

	li $v0, 4
	la $a0, main_Menu  #printing main menu
	syscall 
	
	li $v0, 5
	syscall 
	move $t0, $v0 #saving the inputted opt in a temp register
	
	#calling a suitable function
	#option 1
	bne $t0, 1, continue2
	jal read_id
	jal read_name
	jal read_bal
	j add_customer
      continue2:
	#option 2
	bne $t0, 2, continue3
	jal read_id
	j display_customer
      continue3:
	#option 3
	bne $t0, 3, continue4
	jal read_id
	jal read_bal
	j update_balance
      continue4:
	#option 4
	bne $t0, 4, continue5
	jal read_id
	j delete_customer
      continue5:
	#option 5
	beq $t0, 5, exit_prog
	
	li $v0, 4
	la $a0, invalid_choice #print invalid choice if non of the functions have been called
	syscall
	
	j main
	
      read_id:
	#read id from user
	li $v0, 4
	la $a0, enter_id
	syscall 
	li $v0, 5
	syscall 
	move $a1, $v0
	jr $ra
	
      read_name:
	sub $sp, $sp, 4
	sw $a1, 0($sp)
	#reading the name from user
	li $v0, 4
	la $a0, enter_Name
	syscall 
	li $v0, 8
	la $a0, buffer      #storing the input on the buffer we allocate
	li $a1, 100
	syscall
	lw $a1, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
      read_bal:
        sub $sp, $sp, 4
        sw $a0, 0($sp)
        
	#reading the balance
	li $v0, 4
	bne $t0, 3, not
	la $a0, enter_newbal
	j print
	not:
	la $a0, enter_bal
	print:
	syscall 
	li $v0, 5
	syscall
	move $a2, $v0
	
	lw $a0, 0($sp)
	addi $sp, $sp, 4
	jr $ra
#1
add_customer:
	
	jal create_customer  #callimng create customer function
	
	lw $t0, Size
	addi $t0, $t0, 1
	sw $t0, Size		#increasing the size by 1 and updating $s0 to point to the next empty place
	addi $s0, $s0, 4
	
	jal print_success_adding
	j main
#2
display_customer:
	
	jal check_id #calling ckeck id function
	bne $v0, 1, error_doesnt_ex
	
	move $a3, $v1
	jal print_cus_rec
	
	j main
#3
update_balance:
	
	jal check_id		#checking id
	move $t0, $v0           
	jal check_bal		#checking balance
	move $t1, $v0
	
	bne $t0, 1, error_doesnt_ex
	bne $t1, 1, error_bal          #calling functions that prints a suitable message
	
	sw $a2, 104($v1)
	
	move $a3, $v1
	jal print_cus_rec
	j main
#4
delete_customer:
	
	#calling check id function
	jal check_id
	bne $v0, 1, error_doesnt_ex
	
	#replacing the element we want to delete with the element that exist in the last and then delete the last element.
	sub $s0, $s0, 4	
	lw $t0, 0($s0)
	sw $t0, 0($a3)			#replace the element we want to delete with $t2
	sw $zero, 0($s0)		#set the last element to zero
	lw $t0, Size
	sub $t0, $t0, 1
	sw $t0, Size			#decreasing the size by 1
	jal print_removed
	j main
#5
exit_prog:

	#exiting the program
	li $v0, 4
	la $a0, exit
	syscall 
	li $v0, 10
	syscall
#<==========================================================================================================>#
#functions i helped with
#this function checks if the inputs are valid and create a record and add it to the structure
create_customer:
	sub $sp, $sp, 8
	sw $ra, 0($sp)
	sw $a1, 4($sp)
	
	jal check_id
	bne $v0, 0, error_already_exist
	
	jal check_bal
	bne $v0, 1, error_bal
	
	li $v0, 9
	li $a0, 108    #allocating memory in heap (sbrk)
	syscall 
	move $s1, $v0
	
	sw $a1, 0($s1)
	sw $a2, 104($s1)	#storing the id and the balance in the write place
	la $a1, 4($s1)    #distination address
	la $a0, buffer    #sorce address
	jal copy_string_to_heap
	sw $s1, 0($s0)
	
	lw $ra, 0($sp)
	lw $a1, 4($sp)
	add $sp, $sp, 8
	jr $ra
	
#this function copy the inputted string from buffer to the suitable place in the memory we allocate in th eheap
copy_string_to_heap:

    	li $t0, 0  # Initialize index to 0

	copy_loop:

    	lb $t1, 0($a0)       # Load a byte from the source
    	beq $t1, 10, copy_done  # If the byte is \n, end of string reached

    	sb $t1, 0($a1)       # Store the byte in the destination
    	addi $a1, $a1, 1      # Move to the next byte in the destination
    	addi $a0, $a0, 1      # Move to the next byte in the source
    	j copy_loop

	copy_done:

    	jr $ra
	
#checks if id exist and returns 1 if yes and 0 if no, 
#also returns the base address for printing the record and the address that this record stored in the array
check_id:

	li $v0, 0
	la $t0, CustomersRecords
	lw $t1, Size
	li $t2, 0
	loop:        #iterates over the array of addresses
	
	beq $t2, $t1, endloop
	lw $t3, 0($t0)
	lw $t4, 0($t3)
	bne $a1, $t4, notequal
	li $v0, 1
	move $v1, $t3		#moving base address to $v1
	move $a3, $t0           #for deleting 
	j endloop
	
	notequal:
	addi $t0, $t0, 4
	addi $t2, $t2, 1
	
	j loop
	endloop:

	jr $ra

#this function checks the validity of the balance
check_bal:
	
	li $v0, 1
	ble $a2, 99999, true
	li $v0, 0
	true:
	bge $a2, 0, checked
	li $v0, 0
	
	checked: 
	jr $ra

#all printing functions <===========================================>
#printing a customers record given its address
print_cus_rec: 
	
	li $v0, 4
	la $a0, success
	syscall 
	li $v0, 1
	lw $a0, 0($a3)
	syscall 
	
	li $v0, 4
	la $a0, co_sp
	syscall 
	la $a0, 4($a3)
	syscall 
	la $a0, co_sp
	syscall 
	
	li $v0, 1
	lw $a0, 104($a3)
	syscall
	
	li $v0, 4
	la $a0, new_line
	syscall 
	
	jr $ra
	
#printing a suitable message if adding done successfuly
print_success_adding: 
	
	li $v0, 4
	la $a0, success_cus
	syscall 
	
	li $v0, 1
	move $a0, $a1
	syscall 
	
	li $v0, 4
	la $a0, added
	syscall
	
	jr $ra

#printing a suitable message if removing done successfuly
print_removed: 
	
	li $v0, 4
	la $a0, success_cus
	syscall 
	
	li $v0, 1
	move $a0, $a1
	syscall 
	
	li $v0, 4
	la $a0, deleted
	syscall 
	
	jr $ra
	
#<==================================================================>
#printing error messages
error_already_exist:
	
	li $v0, 4
	la $a0, err_cus
	syscall 
	
	li $v0, 1
	move $a0, $a1
	syscall 
	
	li $v0, 4
	la $a0, al_ex
	syscall 
	
	j main

error_bal:
	
	li $v0, 4
	la $a0, invalid_bal
	syscall 
	
	j main

error_doesnt_ex:

	li $v0, 4
	la $a0, err_cus
	syscall 
	
	li $v0, 1
	move $a0, $a1
	syscall 
	
	li $v0, 4
	la $a0, doesnt_ex
	syscall 
	
	j main
