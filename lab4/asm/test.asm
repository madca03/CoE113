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
	lw $4, 20($0)
	add $5, $1, $1
	add $6, $2, $2
	add $7, $1, $2
	add $8, $2, $1
	sw $3, -8($4)
	sw $5, 28($0)
	sw $6, 32($0)
	sw $7, 36($0)
	sw $8, 40($0)
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
	nop
	nop
	sw $5, 76($0)
	sw $6, 80($0)
	lw $9, 8($0)
	nop
	nop
	nop
	
	beq $3, $9, A
	sw $2, 44($0)
	sw $2, 84($0)
A:
	sw $2, 48($0)
	beq $3, $0, B
	sw $1, 52($0)
B:
	sw $1, 56($0)
	
	bne $3, $0, C
	sw $1, 88($0)
	sw $1, 92($0)
	#nop
	#nop
	#nop
C:
	sw $1, 96($0)
	bne $3, $9, D
	sw $1, 100($0)
D:
	sw $1, 104($0)
	
	j E
	sw $1, 108($0)
	nop
	nop
	nop
	nop
	nop
E:
	sw $1, 112($0)
	j F
	sw $2, 116($0)
	sw $1, 120($0)
F:
	sw $1, 124($0)
	jal G
	sw $1, 128($0)
G:
	sw $1, 132($0)
	nop
	sw $31, 136($0)
	jal H
	sw $2, 140($0)
	sw $1, 144($0)
H:
	sw $1, 148($0)
	nop
	sw $31, 152($0)
	
	jal I
	nop
	sw $2, 156($0)
	jal J
	sw $1, 168($0)
I:
	sw $1, 160($0)
	nop
	jr $ra

J:
	nop
	nop
	sw $31, 164($0)
	slti $9, $1, 0
	slti $10, $1, 0x7fff
	slti $11, $1, -30000
	slti $12 $2, -32000
	slti $13, $2, 0x1234
	sw $9, 172($0)
	sw $10, 176($0)
	sw $11, 180($0)
	sw $12, 184($0)
	sw $13, 188($0)
	
	addi $5, $1, 0x1234
	addi $6, $2, 0x5678
	addi $7, $1, 0x7fff
	addi $8, $2, 0
	addi $ra, $ra, 120
	sw $5, 192($0)
	sw $6, 196($0)
	sw $7, 200($0)
	sw $8, 204($0)
	sw $ra, 208($0)
	jr $ra
	sw $1, 212($0)
	sw $1, 216($0)
	sw $1, 220($0)
	sw $1, 224($0)
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
