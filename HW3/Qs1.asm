.data
# ------------------------Write Your Code Here------------------------------

# ------------------------Write Your Code Here-----------------------------
newline:    .asciiz "\n"
result_true: .asciiz "True\n"
result_false: .asciiz "False\n"



.text
main:
    # You must use the values of these registers
    li $t0, 15 #A
    li $t1, 30 #B
    # ------------------------Write Your Code Here------------------------------
    # C = A + B
    add $s0, $t0, $t1
    
    # D = A + 200 - 6
    addi $t2, $t0, 200
    subi $s1, $t2, 6     # subtract immediate value 6
    
    # E = B^2
    move $t2, $t1      # $t2 = B (original value)
    li $t3, 1          # $t3 = counter for loop
    
    loop:
        beq $t3, $t2, end_loop  # Exit loop when counter reaches B
        add $t1, $t1, $t2          # B += original B
        addi $t3, $t3, 1           # Increment counter
        j loop

    end_loop:
    move $s2, $t1      # $s2 = E

    
    #F = C + D + E - 2
    add $t3, $s0, $s1
    add $t3, $t3, $s2
    subi $s3, $t3, 2
    
    # ------------------------Write Your Code Here-------------------------------
    
    j checkQs1Partialy


checkQs1Partialy:
	li $t5, 45
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
