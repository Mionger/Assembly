.data
    DataBuff:       .space      16     
    # absolute path
    FileName:       .asciiz      "YOUR_PATH\\YOUR_FILE_NAME.FILENAME_EXTENSION"

.text
main_start:
    # open input file
    la		$a0, FileName		
    li		$a1, 0		        # $a1 =0 '0'means read
    li		$a2, 0		        # $a1 =0 
    li		$v0, 13		        # $v0 = 13
    syscall
    add     $s0, $v0, $zero
    
    # read from file
    add		$a0, $s0, $zero		# $a0 = $s1 + $zero
    la		$a1, DataBuff		#
    li		$a2, 16		        # $a2 = 16
    li		$v0, 14		        # $v0 = 14 
    syscall

    # close file
    add     $a0, $s0, $zero		
    li      $v0, 16
    syscall 
    
    # change
    la		$t0, DataBuff		
    lw		$t1, 0($t0)		
    addi	$t1, $t1, 1			
    sw		$t1, 0($t0)	

    # open input file
    la		$a0, FileName		
    li		$a1, 1		        # $a1 =1 '1'means write
    li		$a2, 0		        # $a1 =0 
    li		$v0, 13		        # $v0 = 13
    syscall
    add     $s0, $v0, $zero	

    # check
    # add     $a0, $s0, $zero
    # li      $v0, 1
    # syscall

    # write to file
    add		$a0, $s0, $zero		# $a0 = $s1 + $zero
    la		$a1, DataBuff		#
    li		$a2, 16		        # $a2 = 16
    li		$v0, 15		        # $v0 = 15 
    syscall

    add     $a0, $v0, $zero
    li      $v0, 1
    syscall
    
    # close file
    add     $a0, $s0, $zero		
    li      $v0, 16
    syscall 

    # over
    li		$v0, 10		        # $v0 = 10 
    syscall
    
