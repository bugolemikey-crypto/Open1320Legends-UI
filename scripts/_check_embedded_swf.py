"""Check if newuserform.swf is embedded in the exe."""
import sys

data = open(sys.argv[1], 'rb').read()
idx = 0
while True:
    idx = data.find(b'newuserform', idx)
    if idx == -1:
        break
    chunk = data[max(0, idx - 2000):idx + 100]
    for sig in [b'CWS', b'FWS']:
        pos = chunk.find(sig)
        if pos >= 0:
            abs_pos = max(0, idx - 2000) + pos
            # Read SWF header at that position
            ver = data[abs_pos + 3]
            length = int.from_bytes(data[abs_pos + 4:abs_pos + 8], 'little')
            print(f"SWF signature {sig} at offset {abs_pos}, version={ver}, length={length}")
    idx += 1

# Also check: is there a second full SWF that looks like newuserform (427x300 stage)?
# The main.swf is at offset ~4794808, but maybe newuserform is also embedded
print(f"\nSearching for all CWS/FWS SWF headers in exe...")
idx = 0
swfs = []
while True:
    cws = data.find(b'CWS', idx)
    fws = data.find(b'FWS', idx)
    if cws == -1 and fws == -1:
        break
    pos = min(p for p in [cws, fws] if p >= 0)
    sig = data[pos:pos+3]
    ver = data[pos + 3]
    length = int.from_bytes(data[pos + 4:pos + 8], 'little')
    if 1000 < length < 500000 and ver <= 20:  # Reasonable SWF size
        swfs.append((pos, sig, ver, length))
    idx = pos + 1

print(f"Found {len(swfs)} potential embedded SWFs:")
for pos, sig, ver, length in swfs[:20]:
    print(f"  offset={pos}, sig={sig}, ver={ver}, length={length:,}")
