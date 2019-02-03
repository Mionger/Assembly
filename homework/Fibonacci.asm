.data
    msg_input:    .asciiz     "Please press the goal index:"
    msg_done:     .asciiz     "The result is:"

.text
main_start:
    #initialize
    and     $s2, $s2, $zero     # $s2 = Fibonacci[1]
    and     $s3, $s3, $zero     
    addi	$s3, $s3, 1	        # $s3 = Fibonacci[2]
    	
    #print message
    li		$v0, 4
    la		$a0, msg_input
    syscall
    
    #get the index
    li		$v0, 5		
    syscall
    and     $s4, $s4, $zero
    add		$s4, $s4, $v0		

    #initialize index iterator
    and     $t1, $t1, $zero
    addi	$t1, $t1, 2			# i = 2
do:
    #set index
    addi    $t1, $t1, 1         # i++

    #calculate Fibonacci[3]
    add		$t0, $s2, $s3		# $t0 = Fibonacci[3] = Fibonacci[1] + Fibonacci[2]
    and     $s2, $s2, $zero
    add     $s2, $s2, $s3
    and     $s3, $s3, $zero
    add     $s3, $s3, $t0

check_done:
    sltu    $t2, $t1, $s4
    beq		$t2, $zero, done	# if $t2 == $zero then done

    j		do				# jump to do

done:
    #print message
    li		$v0, 4
    la		$a0, msg_done
    syscall

    and     $s1, $s1, $zero
    add     $s1, $s1, $t0

    and     $a0, $a0, $zero
    add     $a0, $a0, $t0
    li		$v0, 1		# $v0 = 1 
    syscall

    #over
    li		$v0, 10		
    syscall

    
    


    
    
    
    
     
    

    
    