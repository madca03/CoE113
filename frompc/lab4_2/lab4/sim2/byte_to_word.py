fp = open('instmem.txt')
fwp = open('instmem.word', 'w')

i = 0
d = []
for line in fp:
    line = line.strip()
    if (i == 4):
        fwp.write("%s%s%s%s\n" % (d[0], d[1], d[2], d[3]))
        d = []
        i = 0

    d.append(line)
    i = i + 1

fp.close()
fwp.close()
