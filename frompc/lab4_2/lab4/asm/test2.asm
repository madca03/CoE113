.data
	.word 0x0011abcd
	.word 0xffff0101
	.word 0x00000004
	.word 0
	.word 0
	.word 0x00000020

.text
	lw $1, 0($0)
	lw $2, 4($0)
	lw $3, 8($0)
	nop
	sw $1, 16($0)
	nop
	sw $2, 8($3)