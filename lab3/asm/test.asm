.data
	beq_res: .space 12
	bne_res: .space 12
	add_res: .space 4
	sub_res: .space 4
	slt_res: .space 4
	addi_res: .space 4
	slti_res: .space 4
	sw_res:	.space 4
	addr_beq: .word 0x00000000
	addr_bne: .word 0x0000000c
	i: .word 0x12345678
	k: .word 0x11223344
	l: .word 0x22334455
	m: .word 0x000000ff
	n: .word 0x00c0e113
.text
	lw $1, i
	sw $1, sw_res
	
	lw $t0, k
	lw $t1, l
	lw $t2, m
	
	add $s0, $t0, $t1
	sw $s0, add_res
	sub $s0, $t1, $t0
	sw $s0, sub_res
	slt $s0, $t0, $t1
	sw $s0, slt_res
	addi $s0, $t0, 10000
	sw $s0, addi_res
	slti $s0, $t2, 0x0fff
	sw $s0, slti_res
	
	lw $s0, addr_beq
	lw $s1, addr_bne
	lw $t0, n
	lw $t1, i

	# test beq
	# if 0($s0) == 0 && 4($s0) == 1 && 8($s0) == 0 -> beq is always taken
	# if 0($s0) == 1 && 4($s0) == 1 && 8($s0) == 1 -> beq is always not taken
	# if 0($s0) == 0 && 4($s0) == 1 && 8($s0) == 1 -> beq that should be taken is not taken and
	#						  beq that should not be taken is taken

	beq $t1, $t0, A		# should not be taken
	beq $t1, $t1, B		# should be taken
	sw $t0, 0($s0)		# wrong beq (beq is not taken)
A:
	sw $t0, 4($s0)		# wrong beq if (beq is taken)
B:
	beq $t1, $t1, C		# should be taken
	sw $t0, 8($s0) 		# wrong beq (beq is not taken
C:

	#test bne
	# if 0($s1) == 0 && 4($s1) == 1 && 8($s1) == 0 -> bne is always taken
	# if 0($s1) == 1 && 4($s1) == 1 && 8($s1) == 1 -> bne is always not taken
	# if 0($s1) == 0 && 4($s1) == 1 && 8($s1) == 1 -> bne that should be taken is not taken and
	#						  bne that should not be taken is taken
	bne $t1, $t1, D		# should not be taken
	bne $t1, $t0, E		# should be taken
	sw $t0, 0($s1)		# wrong bne (bne is not taken)
D:
	sw $t0, 4($s1)		# wrong bne (bne is taken)
E:
	bne $t1, $t0, F		# should be taken
	sw $t0, 8($s1)
F:
	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
