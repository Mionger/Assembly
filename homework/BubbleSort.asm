.data
msg_size:
  .asciiz "Plaese input the size of array : \n"
msg_input:
  .asciiz "Please input the integers to be sorted : \n"
msg_output:
  .asciiz "The result is : \n"

.text
.globl  main

main:
    la      $a0, msg_size           # Plaese input the size of array : 
    li      $v0, 4
    syscall

    li      $v0, 5                  
    syscall

    add		$s0, $v0, $zero		    # $s0 = $v01 + 0
    la      $a0, msg_input          # 输出提示用户开始输入数据
    li      $v0, 4
    syscall

    add		$a0, $gp, $zero		
    add		$a1, $s0, $zero		
    j       read
read_exit:              

    add     $a0, $gp, $zero
    add     $a1, $s0, $zero
    j       sort
sort_exit:

    li      $v0, 4
    la      $a0, msg_output
    syscall

    add     $a0, $gp, $zero
    add     $a1, $s0, $zero
    j       print
print_exit:

    li		$v0, 10		# $v0 = 10 
    syscall
  

read:
    addi    $sp, $sp, -4      
    sw      $s0, 0($sp)
    li      $s0, 0                
read_:
    sltu    $t0, $s0, $a1    
    beq     $t0, $zero, exit_read  
    sll     $t0, $s0, 2         
    add     $t1, $a0, $t0      
    add     $t2, $a0, $zero
    li      $v0, 5              
    syscall
    sw      $v0, 0($t1)            
    add     $a0, $t2, $zero
    addi    $s0, $s0, 1        
    j       read_
exit_read:
    lw      $s0, 0($sp)            
    addi    $sp, $sp, 4        
    j       read_exit


sort:
    addi    $sp, $sp, -16       
    sw      $s3, 12($sp)          
    sw      $s2, 8($sp)          
    sw      $s1, 4($sp)          # j
    sw      $s0, 0($sp)          # i
    add     $s2, $a0, $zero
    add     $s3, $a1, $zero
    and     $s0, $s0, $zero
forOut:
    slt     $t0, $s0, $s3      
    beq     $t0, $zero, exit_out  
    addi    $s1, $s0, -1       
forIn:
    slti    $t0, $s1, 0        
    bne     $t0, $zero, exit_in   
    sll     $t1, $s1, 2         
    add     $t2, $s2, $t1		
    lw      $t3, 0($t2)            
    lw      $t4, 4($t2)            
    slt     $t0, $t3, $t4
    bne     $t0, $zero, exit_in   
    add     $a0, $s2, $zero
    add     $a1, $s1, $zero                       
    j       swap
swap_exit:
    addi    $s1, $s1, -1       # j--
    j       forIn
exit_in:
    addi    $s0, $s0, 1        # i++
    j       forOut                
exit_out:
    lw      $s0, 0($sp)
    lw      $s1, 4($sp)
    lw      $s2, 8($sp)
    lw      $s3, 12($sp) 
    addi    $sp, $sp, 16
    j       sort_exit
swap:
    sll     $t0, $a1, 2     
    add     $t0, $a0, $t0 
    lw      $t1, 0($t0)        
    lw      $t2, 4($t0)        
    sw      $t1, 4($t0)        
    sw      $t2, 0($t0)        
    j       swap_exit             


print:
    addi    $sp, $sp, -4
    sw      $s0, 0($sp)      
    li      $s0, 0              
print_:
    sltu    $t0, $s0, $a1
    beq     $t0, $zero, exit_print
    sll     $t0, $s0, 2
    add     $t1, $a0, $t0
    add     $t2, $a0, $zero
    lw      $a0, 0($t1)
    li      $v0, 1
    syscall
    li      $a0, ' '
    li      $v0, 11
    syscall 
    add     $a0, $t2, $zero
    addi    $s0, $s0, 1
    j       print_
exit_print:
    lw      $s0, 0($sp)
    addi    $sp, $sp, 4
    j       print_exit