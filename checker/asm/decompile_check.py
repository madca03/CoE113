with open('source1.word') as f:
    content_1 = f.readlines()

with open('mips.word') as f:
    content_2 = f.readlines()

for index, line in enumerate(content_1):
    if int(line,16) != int(content_2[index],16):
        print("incorrect at line %d" % (index))
        break
