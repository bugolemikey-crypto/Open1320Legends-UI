"""Find all embedded SWF files in the exe."""
import sys

path = sys.argv[1]
data = open(path, 'rb').read()
print(f"Exe size: {len(data):,} bytes")

# Find CWS (compressed) and FWS (uncompressed) signatures
for sig in [b'CWS', b'FWS']:
    idx = 0
    count = 0
    while True:
        idx = data.find(sig, idx)
        if idx == -1:
            break
        ver = data[idx + 3]
        length = int.from_bytes(data[idx + 4:idx + 8], 'little')
        if 5 <= ver <= 30 and 1000 < length < 30000000:
            print(f"  {sig.decode()} at offset {idx:,}, version={ver}, declared_length={length:,}")
            count += 1
        idx += 1
    print(f"Total {sig.decode()}: {count}")
