import sys

if len(sys.argv) < 3:
    print('Usage: python decompiler.py <source_file> <dest_file>')
    exit(0)

with open(sys.argv[1]) as f:
    content = f.readlines()
fp = open(sys.argv[2], 'w')

content = [x.strip() for x in content]
for index, line in enumerate(content):
    bin_code = bin(int(line,16))[2:].zfill(32)
    opcode = bin_code[0:6]
    rs = bin_code[6:11]
    rt = bin_code[11:16]
    rd = bin_code[16:21]
    shamt = bin_code[21:26]
    funct = bin_code[26:]
    imm = bin_code[16:]

    if (int(imm,2) & (1 << 16-1) != 0):
        imm_signed = int(imm,2) - (1 << 16)
    else:
        imm_signed = int(imm,2)

    if (opcode == '100011'):
        op_str = 'lw'
    elif (opcode == '101011'):
        op_str = 'sw'
    elif (opcode == '000000'):
        if (funct == '100000'):
            op_str = 'add'
        elif (funct == '100010'):
            op_str = 'sub'
        elif (funct == '101010'):
            op_str = 'slt'
        elif (funct == '000000'):
            op_str = 'nop'
    elif (opcode == '000100'):
        op_str = 'beq'
    elif (opcode == '000101'):
        op_str = 'bne'
    else:
        op_str = 'none'

    # if op_str == 'lw' or op_str == 'sw':
    #     fp.write('%d %s - %s %s %s %s %s %s - %s $%d, %d($%d)\n' % (index, line, opcode, rs, rt, rd, shamt, funct,
    #                                                              op_str, int(rt,2), imm_signed, int(rs,2)))
    # elif op_str == 'add' or op_str == 'sub' or op_str == 'slt':
    #     fp.write('%d %s - %s %s %s %s %s %s - %s $%d, $%d, $%d\n' % (index, line, opcode, rs, rt, rd, shamt, funct,
    #                                                              op_str, int(rd,2), int(rs,2), int(rt,2)))
    # elif op_str == 'beq' or op_str == 'bne':
    #     fp.write('%d %s - %s %s %s %s %s %s - %s $%d, $%d, %d\n' % (index, line, opcode, rs, rt, rd, shamt, funct,
    #                                                              op_str, int(rs,2), int(rt,2), imm_signed))
    # else:
    #     fp.write('%d %s - %s %s %s %s %s %s - %s\n' % (index, line, opcode, rs, rt, rd, shamt, funct, op_str))

    if op_str == 'lw' or op_str == 'sw':
        fp.write('\t%s $%d, %d($%d)\n' % (op_str, int(rt,2), imm_signed, int(rs,2)))
    elif op_str == 'add' or op_str == 'sub' or op_str == 'slt':
        fp.write('\t%s $%d, $%d, $%d\n' % (op_str, int(rd,2), int(rs,2), int(rt,2)))
    elif op_str == 'beq' or op_str == 'bne':
        fp.write('\t%s $%d, $%d, %d\n' % (op_str, int(rs,2), int(rt,2), imm_signed))
    else:
        fp.write('\t%s\n' % (op_str))
