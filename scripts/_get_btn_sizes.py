import struct, os

def get_png_dims(path):
    with open(path, 'rb') as f:
        f.read(8); f.read(4); f.read(4)
        w, h = struct.unpack('>II', f.read(8))
        return w, h

img_dir = r'C:\Users\hunte\Downloads\Open1320Legends-UI\exports\main_client\images'
for cid in ['1945', '1948', '1953']:
    for ext in ['.png', '.jpg']:
        path = os.path.join(img_dir, cid + ext)
        if os.path.exists(path):
            if ext == '.png':
                w, h = get_png_dims(path)
                print(f'char {cid}: {w}x{h}  ({os.path.getsize(path):,} bytes)')
            else:
                print(f'char {cid}: jpg  ({os.path.getsize(path):,} bytes)')
            break
