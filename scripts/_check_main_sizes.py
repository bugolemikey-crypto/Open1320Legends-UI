import struct, os

def get_png_dims(path):
    with open(path, 'rb') as f:
        f.read(8)
        f.read(4)
        f.read(4)
        w, h = struct.unpack('>II', f.read(8))
        return w, h

def get_swf_dims(path):
    """Read width/height from SWF header (handles compressed/uncompressed)."""
    import zlib
    with open(path, 'rb') as f:
        sig = f.read(3)
        version = f.read(1)
        file_len = struct.unpack('<I', f.read(4))[0]
        if sig == b'CWS':
            data = zlib.decompress(f.read())
        elif sig == b'FWS':
            data = f.read()
        else:
            return None
        # RECT structure - bits packed
        nbits = (data[0] >> 3) & 0x1f
        total_bits = 5 + 4 * nbits
        total_bytes = (total_bits + 7) // 8
        raw = int.from_bytes(data[:total_bytes], 'big')
        shift = 8 * total_bytes - 5
        xmin = (raw >> (shift - nbits)) & ((1 << nbits) - 1)
        xmax = (raw >> (shift - 2*nbits)) & ((1 << nbits) - 1)
        ymin = (raw >> (shift - 3*nbits)) & ((1 << nbits) - 1)
        ymax = (raw >> (shift - 4*nbits)) & ((1 << nbits) - 1)
        # twips to pixels (20 twips per pixel)
        return (xmax - xmin) // 20, (ymax - ymin) // 20

# Check login_form SWF dimensions
swf = r'C:\Users\hunte\Downloads\Open1320Legends-UI\exports\login_form\newuserform.swf'
dims = get_swf_dims(swf)
print(f'newuserform.swf stage size: {dims[0]}x{dims[1]} px')

# Also check main client
swf2 = r'C:\Users\hunte\Downloads\Open1320Legends-UI\source\main.swf'
dims2 = get_swf_dims(swf2)
print(f'main.swf stage size: {dims2[0]}x{dims2[1]} px')

# Largest images in main_client exports
img_dir = r'C:\Users\hunte\Downloads\Open1320Legends-UI\exports\main_client\images'
results = []
for fn in os.listdir(img_dir):
    path = os.path.join(img_dir, fn)
    size = os.path.getsize(path)
    if fn.endswith('.png'):
        try:
            w, h = get_png_dims(path)
            results.append((size, fn, f'{w}x{h}'))
        except:
            results.append((size, fn, 'err'))
    else:
        results.append((size, fn, 'jpg'))

results.sort(reverse=True)
print('\nTop 20 largest images in main_client:')
for size, fn, dims in results[:20]:
    print(f'  {fn}: {dims}  ({size:,} bytes)')
