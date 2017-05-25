.data
	.word 0x0011abcd
	.word 0xffff0101
	.word 0x00000004
	.word 0
	.word 0
	.word 0x00000020

.text
	lw $1, 0($0)
	add $5, $1, $1
	sw $5, 16($0)

	lw $1, 0($0)
	nop
	add $6, $1, $1
	nop
	sw $6, 20($0)

	lw $1, 0($0)
	nop
	nop
	add $7, $1, $1
	nop
	nop
	sw $7, 24($0)

	sw $2, 16($0)
	addi $2, $0, 28
	nop
	nop
	nop
	sw $1, 0($2)

	add $10, $1, $1
	add $7, $10, $10
	sw $7, 32($0)

	lw $9, 24($0)
	sw $9, 36($0) 

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
  nop
  nop
  nop
  nop
