.data
# ------------------------Write Your Code Here------------------------------
arr: .space 40 # Allocate space for the array (10 integers)
# ------------------------Write Your Code Here-------------------------------
newline:    .asciiz "\n"
result_true: .asciiz "True\n"
result_false: .asciiz "False\n"

.text
main:
    #first 2 elements, dont forget to store them in arr
    li $t0, 0 
    li $t1, 1
    # ------------------------Write Your Code Here------------------------------
    la $a0, arr              # storing the adress of the array in $a0
    sw $t0, 0($a0)
    sw $t1, 4($a0)           # inserting the 0,1 in the array
    
    #index to insert into
    li $t5, 2                
    
    loop:                    # the loop of "fibonacci" 
    
    beq $t5, 10, end_loop    #the end condition
    add $t6, $t0, $t1
    sll $t7, $t5, 2
    add $t7, $t7, $a0
    sw $t6, 0($t7)           #store the word in the wanted index
    move $t0, $t1            # updating t0,t1 to the new valuse in fibonacci sequence
    move $t1, $t6
    addi $t5, $t5, 1         #increment index by 1

    j loop
    
    end_loop:                # ending label
    
    # ------------------------Write Your Code Here-------------------------------
    la $s0, arr
    j check_array

check_array:
    # Check if the first element is 0 and the second one is 1
    lw $t1, 0($s0)   # Load the first element from the array pointed by $s0
    lw $t2, 4($s0)   # Load the second element from the array pointed by $s0

    li $t3, 0       # Constant value for comparison
    li $t4, 1     # Constant value for comparison

    # Check the conditions
    beq $t1, $t3, check_second_element
    j print_false

check_second_element:
    beq $t2, $t4, print_true
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
