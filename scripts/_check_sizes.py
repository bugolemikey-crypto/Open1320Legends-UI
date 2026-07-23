import struct, os

def get_png_dims(path):
    with open(path, 'rb') as f:
        f.read(8)  # PNG sig
        f.read(4)  # IHDR length
        f.read(4)  # 'IHDR'
        w, h = struct.unpack('>II', f.read(8))
        return w, h

img_dir = r'C:\Users\hunte\Downloads\Open1320Legends-UI\exports\login_form\images'
for fn in sorted(os.listdir(img_dir)):
    path = os.path.join(img_dir, fn)
    if fn.endswith('.png'):
        try:
            w, h = get_png_dims(path)
            size = os.path.getsize(path)
            print(f'{fn}: {w}x{h}  ({size} bytes)')
        except Exception as e:
            print(f'{fn}: error - {e}')
    else:
        size = os.path.getsize(path)
        print(f'{fn}: (jpg)  ({size} bytes)')
