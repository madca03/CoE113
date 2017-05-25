import sys

if len(sys.argv) != 3:
    sys.exit("Wrong number of arguments")

fp = open(sys.argv[1])
fwp = open(sys.argv[2], 'w')

j = 0
mem_depth = 1024;

for line in fp:
    line = line.strip()
    for i in range(4):
        fwp.write('%s\n' % line[(i*2):(i*2)+2])
        j = j + 1

        if j == mem_depth:
            fp.close()
            fwp.close()
            sys.exit()

fp.close()
fwp.close()
