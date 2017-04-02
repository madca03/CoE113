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
	sw $2, 8($3)
	sw $1, 16($0)
	lw $4, 20($0)
	sw $3, -8($4)
	add $5, $1, $1
	add $6, $2, $2
	add $7, $1, $2
	add $8, $2, $1
	sw $5, 28($0)
	sw $6, 32($0)
	sw $7, 36($0)
	sw $8, 40($0)
	lw $9, 8($0)
	beq $3, $9, A
	sw $2, 44($0)
A:
	sw $2, 48($0)
	beq $3, $0, B
	sw $1, 52($0)
B:
	sw $1, 56($0)
	sub $5, $1, $1
	sub $6, $2, $2
	sub $7, $1, $2
	sub $8, $2, $1
	sw $5, 60($0)
	sw $6, 64($0)
	sw $7, 68($0)
	sw $8, 72($0)
	slt $5, $1, $2
	slt $6, $2, $1
	sw $5, 76($0)
	sw $6, 80($0)
C:
	add $20, $20, $3
	sub $4, $4, $3
	bne $4, $0, C
	sw $20, 84($0)
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
