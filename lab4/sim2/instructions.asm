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
addi $7, $3, 60
addi $8, $4, -16
addi $9, $5, -32768
nop
nop
sw $7, 84($0)
sw $8, 88($0)
sw $9, 92($0)
slti $7, $1, 32767
slti $8, $2, -32768
slti $9, $4, 20
nop
nop
sw $7, 96($0)
sw $8, 100($0)
sw $9, 104($0)
lw $9, 8($0)
nop
nop
nop
beq $3, $9, 2
sw $2, 44($0)
sw $2, 108($0)
sw $2, 48($0)
beq $3, $0, 1
sw $1, 52($0)
sw $1, 56($0)
bne $3, $0, 2
sw $1, 112($0)
sw $1, 116($0)
sw $1, 120($0)
bne $3, $9, 1
sw $1, 124($0)
sw $1, 128($0)
j 70
add $10, $1, $1
sw $10, 132($0)
sw $1, 136($0)
sw $2, 140($0)
sw $3, 144($0)
sw $10, 148($0)
sw $1, 152($0)
jal 80
sw $1, 156($0)
sw $2, 180($0)
j 88
add $1, $3, $4
add $2, $3, $4
sw $1, 160($0)
add $10, $3, $4
sw $1, 168($0)
sw $2, 172($0)
sw $31, 164($0)
sw $10, 176($0)
jr $31
add $7, $1, $1
add $8, $2, $2
add $9, $1, $1
nop
nop
sw $7, 184($0)
sw $8, 188($0)
sw $9, 192($0)
beq $0, $0, 3
bne $1, $2, 4
sw $1, 196($0)
sw $2, 200($0)
nop
sw $3, 204($0)
bne $0, $1, 4
beq $0, $0, 5
sw $1, 208($0)
sw $2, 212($0)
sw $3, 216($0)
sw $4, 220($0)
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
