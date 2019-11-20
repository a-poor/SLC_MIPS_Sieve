# Computer Organization - Fall 2019
#
# Austin Poor
#
# Programming the Sieve of Eratosthenes (in MIPS)


main:
    # read size of sieve into s1
    li $v0, 5
    syscall
    move $s1, $v0

    # allocate buffer of that many bytes, store address in s0
    li $v0, 9
    move $a0, $s1
    syscall
    move $s0, $v0

    # marked elapsed miliseconds in s3
    li $v0, 30
    syscall
    move $s3, $a0

    # execute the sieve; store # of primes found in s2
    move $a0, $s0
    move $a1, $s1
    jal sieve
    move $s2, $v0

    # compute elapsed milisecond in s3
    li $v0, 30
    syscall
    sub $s3, $a0, $s3

    # print all primes found by sieve
    move $a0, $s0
    move $a1, $s1
    jal print_primes

    # print number of primes found
    move $a0, $s2
    jal print_int
    jal print_newline

    # halt
    li $v0, 10
    syscall


##################################################
sieve: # buffer_pointer = $a0, sieve_size = $a1
    addi $sp, $sp, -12 # save values to the stack
    sw   $a0, 0($sp)
    sw   $a1, 4($sp)
    sw   $ra, 8($sp)
    jal fill_buffer # fill the buffer with 1s
    lw   $ra, 8($sp)
    lw   $a1, 4($sp)
    lw   $a0, 0($sp)
    addi $sp, $sp, 12
    lb  $zero, 0($a0) # 0 is not prime
    lb  $zero, 1($a0) # 1 is not prime
    
    li  $t0, 2   # Store current index in buffer
    li  $t1, 0   # Store number of primes found
sv_buff_loop:
    slt  $t2, $t0, $a1 # check index < size of buffer
    beq  $t2, $zero, sv_buff_loop_end
    
    add $t2, $t0, $a0 # check if buff[index] already not prime
    lb  $t3, 0($t2)
    beq $t3, $zero, sv_inner_loop_end
    
    addi $t1, $t1, 1 # increment number of primes
    
    move $t3, $t0    # sieve from 2xIndex to end of buffer
sv_inner_loop:
    add  $t3, $t3, $t0
    slt  $t4, $t3, $a1 # check if number past buffer size
    beq  $t4, $zero, sv_inner_loop_end
    add  $t4, $a0, $t3
    sb   $zero, 0($t4)
    j    sv_inner_loop
sv_inner_loop_end:
    addi $t0, $t0, 1 # move to the next number
    j    sv_buff_loop
sv_buff_loop_end:
    move $v0, $t1
    jr $ra


##################################################
print_primes:
    move $t0, $a0
    move $t1, $a1
    li   $t0, 2  # start from 2
print_loop_start:
    slt  $t1, $t0, $a1
    beq  $t1, $zero, print_loop_exit
    add  $t1, $t0, $a0
    lb   $t2, 0($t1)
    beq  $t2, $zero, print_loop_increment
    addi $sp, $sp, -12
    sw   $a0, 0($sp)
    sw   $a1, 4($sp)
    sw   $ra, 8($sp)
    move $a0, $t0
    jal  print_int
    jal  print_newline
    lw   $ra, 8($sp)
    lw   $a1, 4($sp)
    lw   $a0, 0($sp)
    addi $sp, $sp, 12
print_loop_increment:
    addi $t0, $t0, 1
    j    print_loop_start
print_loop_exit:
    jr   $ra
    
    
##################################################
fill_buffer: # buffer_pointer = $a0, sieve_size = $a1
    li $t0, 0 # buffer index
    li $t1, 1
fill_loop:
    add $t2, $t0, $a0
    sb $t1, 0($t2)
    addi $t0, $t0, 1
    bne $t0, $a1, fill_loop
    jr $ra



##################################################
# Pseudo-standard library routines:
#   wrappers around MARS syscalls
#

# print_int: displays supplied integer (in $a0) on console
print_int:
	li $v0, 1
	syscall
    li $v0, 0   # destroys v0
    li $a0, 0   # destroys a0
	jr $ra


# print_newline: displays newline in console
print_newline:
	li $v0, 11
    li $a0, 10
	syscall
    li $v0, 0   # destroys v0
    li $a0, 0   # destroys a0
	jr $ra
