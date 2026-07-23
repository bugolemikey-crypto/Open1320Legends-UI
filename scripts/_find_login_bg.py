"""Find the login background by looking at what sprite contains the login frame."""
import struct, os

def get_png_dims(path):
    with open(path, 'rb') as f:
        f.read(8); f.read(4); f.read(4)
        w, h = struct.unpack('>II', f.read(8))
        return w, h

# The login frame is inside sprite chid:676 (DefineSprite).
# But the real login background is probably the parent timeline.
# Let's look at all images with dimensions >= 400px in either direction
img_dir = r'C:\Users\hunte\Downloads\Open1320Legends-UI\exports\main_client\images'
results = []
for fn in os.listdir(img_dir):
    path = os.path.join(img_dir, fn)
    size = os.path.getsize(path)
    if fn.endswith('.png'):
        try:
            w, h = get_png_dims(path)
            if w >= 400 or h >= 400:
                results.append((w*h, fn, f'{w}x{h}', size))
        except:
            pass
    elif fn.endswith('.jpg'):
        results.append((999999, fn, 'jpg', size))

results.sort(reverse=True)
print("Large images (>= 400px in any dimension):")
for area, fn, dims, size in results[:40]:
    print(f'  {fn}: {dims}  ({size:,} bytes)')
