import sys

if len(sys.argv) < 3:
    print('Usage: python decompiler_check.py <source_file> <dest_file>')
    exit(0)

with open(sys.argv[1]) as f:
    content_1 = f.readlines()

with open(sys.argv[2]) as f:
    content_2 = f.readlines()

for index, line in enumerate(content_1):
    if int(line,16) != int(content_2[index],16):
        print("incorrect at line %d" % (index))
        break
