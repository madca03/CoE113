.data
	beq_res: .space 12	
	bne_res: .space 12	
	addr_beq: .word 0x00000000
	addr_bne: .word 0x0000000c
	i: .word 0x12345678
	j: .word 0x87654321
	k: .word 0xabcdef12
	l: .word 0x00001000
	m: .word 0x00000200
	n: .word 0x00c0e113
	val_2: .word 0x00000002
	val_3: .word 0x00000003
	add_res: .word 0
	sub_res: .word 0
	slt_res: .word 0
	slti_res: .word 0
	addi_res: .word 0
	val_4: .word 0x00112233
	val_5: .word 0x00112233


.text
	# test load word and store word
	lw $t1, i
	sw $t1, j

	lw $t2, val_2		# load operand = 2
	lw $t3, val_3		# load operand = 3
	lw $s6, val_4
	lw $s7, val_5

	# test add
	add $t4, $s6, $s7
	sw $t4, add_res		# store result of add (expected: add_res = 5 = 0x00000005)

	# test sub
	sub $t5, $s6, $s7
	sw $t5, sub_res		# store result of sub (expected: sub_res = -1 = 0xffffffff)

	# test addi		# Note: instruction doesn't work
	addi $t6, $s6, 1000
	sw $t6, addi_res	# store result of addi (expected: addi_res = 1002 = 0x000003ea)

	# test slt
	slt $t7, $t2, $t3
	sw $t7, slt_res		# store result of slt (expected: slt_res = 1 = 0x00000001)

	# test slti
	slti $t8, $t2, 5 	# set $t8 to 1
	sw $t8, slti_res	# store result of slti (expected: slti_res = 1 = 0x00000001)
			
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
end:
	
