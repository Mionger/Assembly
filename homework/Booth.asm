###################################################################################

# Register Contents	:
# -----------------------
# $s0 = loop counter
# $s1 = X (multiplier) 
# $s2 = Y (multiplicand)
# $s3 = U --> holds the results from each step in the algorithm
# $s4 = V --> holds the overflow from U, when right-shift
# $s5 = X-1 --> holds the least significant bit from X before each right-shift
# $s6 = N --> an extra bit to the left of U to perform multiplication
# 	      when multiplicand is the largest negative number
#
###################################################################################

.data	
msg_input_multiplicand:		.asciiz "\nPlease enter the multiplicand : "
msg_input_multiplier:		.asciiz "\nPlease enter the multiplier : "
print_result:				.asciiz "The result is : "

.text

main:
	# initialize loop counter = 0, U=0, V=0, X-1=0, N=0
	addi 		$s0, $zero, 0
	addi 		$s3, $zero, 0
	addi 		$s4, $zero, 0
	addi 		$s5, $zero, 0
	addi 		$s6, $zero, 0

	# ask for multiplier
	li   		$v0, 4
	la   		$a0, msg_input_multiplier
	syscall

	# get integer into $s1
	li   		$v0, 5
	syscall
	add  		$s1, $zero, $v0

	# ask for multiplicand
	li   		$v0, 4
	la   		$a0, msg_input_multiplicand
	syscall

	# get integer into $s2
	li   		$v0, 5
	syscall
	add  		$s2, $zero, $v0

loop_start:

	# check for the loop counter
	beq  $s0, 33, exit

	andi 		$t0, $s1, 1		# $t0 = LSB of X
	beq  		$t0, $zero, x_lsb_0	# if ($t0 == 0) then goto x_lsb_0
	j    		x_lsb_1			# if ($t1 == 1) then goto x_lsb_1

x_lsb_0: 				# when the LSB of X = 0
	beq  		$s5, $zero, case_00	# if (X-1 == 0) then goto case_00
	j    		case_01			# if (X-1 == 1) then goto case_01

x_lsb_1:				# when the LSB of X = 1
	beq  		$s5, $zero, case_10	# if (X-1 == 0) then goto case_10
	j    		case_11			# if (X-1 == 1) then goto case_11

case_00:
	andi 		$t0, $s3, 1		# LSB of U for overflow checking
	bne  		$t0, $zero, V		# if LSB of U not zero, goto V, i.e. U overflows
	srl  		$s4, $s4, 1		# shift right logical V by 1-bit
	j    		shift			# goto shift other variables

case_01:
	# check for special case -is multiplier the largest negative number?
	beq  		$s2, -2147483648, do_special_add

	# do addition and shifting
	add 		$s3, $s3, $s2		# add Y to U
	andi 		$s5, $s5, 0		# X=0, so next time X-1=0
	andi 		$t0, $s3, 1		# LSB of U for overflow checking
	bne  		$t0, $zero, V		# if LSB of U not zero, goto V, i.e. U overflows
	srl  		$s4, $s4, 1		# shift right logical V by 1-bit
	j    		shift			# goto shift other variables

case_10:
	# check for special case -is multiplier the largest negative number?
	beq  		$s2, -2147483648, do_special_sub

	# do subtract and shifting
	sub  		$s3, $s3, $s2		# sub Y from U
	ori  		$s5, $s5, 1		# X=1, so next time X-1=1
	andi 		$t0, $s3, 1		# LSB of U for overflow checking
	bne  		$t0, $zero, V		# if LSB of U not zero, goto V, i.e. U overflows
	srl  		$s4, $s4, 1		# shift right logical V by 1-bit
	j    		shift			# goto shift other variables

case_11:
	andi 		$t0, $s3, 1		# LSB of U for overflow checking
	bne  		$t0, $zero, V		# if LSB of U not zero, goto update
	srl  		$s4, $s4, 1		# shift right logical V by 1-bit
	j    		shift 			# goto shift other variables

V:
	andi 		$t0, $s4, 0x80000000	# What is the MSB of V?
	bne  		$t0, $zero, v_msb_1	# If MSB == 1, goto v_msb_1
	srl  		$s4, $s4, 1		# MSB == 0, so first shift right logical V by 1-bit
	ori  		$s4, $s4, 0x80000000	# then make MSB of V = 1
	j    		shift			# goto shift other variables

v_msb_1:
	srl  		$s4, $s4, 1		# shift right logical V by 1-bit
	ori  		$s4, $s4, 0x80000000	# MSB 0f V = 1
	j    		shift			# goto shift other variables

shift:
	sra  		$s3, $s3, 1		# shift right arithmetic U by 1-bit
	ror  		$s1, $s1, 1		# rotate right X by 1-bit
	addi 		$s0, $s0, 1		# decrement loop counter
	beq  		$s0, 32, save		# if it is last step, save the contents of the regs for result
	j    		loop_start			# loop again

save:
	add  		$t1, $zero, $s3		# save U in $t1
	add  		$t2, $zero, $s4		# save V in $t2
	j    		loop_start			# loop again	

do_special_sub:				# to ignore overflow on U by adding variable N as MSB of U
	subu 		$s3, $s3, $s2		# sub Y from U
	andi 		$s6, $s6, 0		# set N=0
	ori  		$s5, $s5, 1		# X=1, so next time X-1=1
	andi 		$t0, $s3, 1		# LSB of U for overflow checking
	bne  		$t0, $zero, V		# if LSB of U not zero, goto V, i.e. U overflows
	srl  		$s4, $s4, 1		# shift right logical V by 1-bit
	j    		shift_special		# goto shift_special, we gotta check N for updating U

do_special_add:				# to ignore overflow on U by adding variable N as MSB of U
	addu 		$s3, $s3, $s2		# add Y to U
	ori  		$s6, $s6, 1		# set N=1
	andi 		$s5, $s5, 0		# X=0, so next time X-1=0
	andi 		$t0, $s3, 1		# LSB of U for overflow checking
	bne  		$t0, $zero, V		# if LSB of U not zero, goto V, i.e. U overflows
	srl  		$s4, $s4, 1		# shift right logical V by 1-bit
	j    		shift_special		# goto shift_special, we gotta check N for updating U
	
	
shift_special:
	beq  		$s6, $zero, n_0	# if (N==0) then goto n_0
	sra  		$s3, $s3, 1		# shift right arithmetic U by 1-bit
	ror  		$s1, $s1, 1		# rotate right X by 1-bit
	addi 		$s0, $s0, 1		# decrement loop counter
	beq  		$s0, 32, save		# if it is last step, save the contents of the regs for result
	j    		loop_start			# loop again

n_0:
	srl  		$s3, $s3, 1		# shift right logic U by 1-bit, because N=0
	ror  		$s1, $s1, 1		# rotate right X by 1-bit
	addi 		$s0, $s0, 1		# decrement loop counter
	beq  		$s0, 32, save		# if it is last step, save the contents of the regs for result
	j    		loop_start			# loop again

exit:
	# Print result
	li   		$v0, 4
	la   		$a0, print_result
	syscall
	
	# Call U
	li   		$v0, 35
	add  		$a0, $zero, $t1
	syscall
	# Call V
	li   		$v0, 35
	add  		$a0, $zero, $t2
	syscall
	
	# Exit
	li   		$v0, 10
	syscall
