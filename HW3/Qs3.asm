.data
# ------------------------Write Your Code Here------------------------------
arr: .word -23, 2354, 34, 10, -3553, 4234, 81, 90, 634, -27 
      .space 40 # Allocate space for the array (10 integers)
     
# ------------------------Write Your Code Here-----------------------------
newline:    .asciiz "\n"
result_true: .asciiz "True\n"
result_false: .asciiz "False\n"



.text
main:
    # ------------------------Write Your Code Here------------------------------
    la $a0, arr
    li $s0, 0  # max
    lw $s1, 0($a0) # min
    li $s2, 0  # sum
    li $s3, 0  # avg
    li $t0, 0
    
    loop:                        # start a loop that iterart on the arr elements
    beq $t0, 10, end_loop
    
    sll $t1, $t0, 2      #find the adress we wand to load the word from
    add $t1, $t1, $a0
    lw $t2, 0($t1)
    
    # check if the the specific element is greater than s0 and update s0 if true
    slt $t3, $s0, $t2          
    beq $t3, $zero, continue_max   
        move $s0, $t2  #updating s0 if needed
    continue_max:
    
    # check if the the specific element is smaller than s1 and update s1 if true
    slt $t3, $t2, $s1
    beq $t3, $zero, continue_min
        move $s1, $t2  #updating s1 if needed
    continue_min:
    
    # add the value of the specific element we reach to to the value of s2
    add $s2, $s2, $t2
    
    addi $t0, $t0, 1             # index(t0) += 1
    j loop  #jumb to loop
    
    end_loop:
    
   # Convert the sum to floating-point 
    mtc1 $s2, $f0
    
    # Load the divisor (10) into a floating-point register
    li $t4, 10
    mtc1 $t4, $f4
    
    # Calculate the average (sum / 10)
    div.s $f0, $f0, $f4
    
    # Store the average in $s3
    mfc1 $s3, $f0
     
    # ------------------------Write Your Code Here-------------------------------
    
    j checkQs3Partialy


checkQs3Partialy:
	li $t5, 4234
	beq $s0, $t5, print_true
	j print_false

print_true:
    # Print True
    li $v0, 4      # System call for print_str
    la $a0, result_true
    syscall
    j end_program

print_false:
    # Print False
    li $v0, 4      # System call for print_str
    la $a0, result_false
    syscall

end_program:
    # Exit the program
    li $v0, 10
    syscall
