"""Write a minimal test SWF to prove the game reads from cache/misc/."""
import struct
import sys
import shutil

target = r"C:\Users\hunte\Downloads\Open1320Legends\cache\misc\newuserform.swf"
backup = target + ".bak"

# Backup
shutil.copy2(target, backup)
print(f"Backed up to {backup}")

# Minimal FWS: version 8, 427x300 stage, dark background, 1 empty frame
rect = bytes([0x78, 0x00, 0x04, 0x15, 0x00, 0x00, 0x17, 0x70, 0x00])
frame_info = struct.pack('<HH', 30 * 256, 1)
bg_tag = struct.pack('<H', (9 << 6) | 3) + bytes([0x1E, 0x1E, 0x23])
show = struct.pack('<H', (1 << 6) | 0)
end = struct.pack('<H', (0 << 6) | 0)
body = rect + frame_info + bg_tag + show + end
total = 8 + len(body)
swf = b'FWS' + struct.pack('B', 8) + struct.pack('<I', total) + body

with open(target, 'wb') as f:
    f.write(swf)
print(f"Wrote test SWF: {len(swf)} bytes to {target}")
print("Restart the game - if you see an EMPTY form (no fields), it proves the game reads this file.")
print(f"To restore: copy {backup} back to {target}")
