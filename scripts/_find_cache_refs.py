"""Find all 'cache/' references in the exe to understand path resolution."""
import sys

data = open(sys.argv[1], 'rb').read()
idx = 0
results = set()
while True:
    idx = data.find(b'cache/', idx)
    if idx == -1:
        break
    chunk = data[idx:idx+80]
    s = ''
    for b in chunk:
        if 32 <= b <= 126:
            s += chr(b)
        else:
            break
    results.add(s)
    idx += 1

for r in sorted(results):
    print(r)
