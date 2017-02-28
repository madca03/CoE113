.data
	i: .word 0x12345678
	j: .word 0
.text
	lw $t0, i
	sw $t0 j