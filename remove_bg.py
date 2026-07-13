from PIL import Image
import numpy as np

src = "images/img_58723d2058e4.jpg"
out = "images/logo_center.png"

im = Image.open(src).convert("RGBA")
a = np.array(im)
h, w = a.shape[:2]
r, g, b, al = a[:, :, 0], a[:, :, 1], a[:, :, 2], a[:, :, 3]

# white mask: all channels > 245
white = (r > 245) & (g > 245) & (b > 245)

# flood fill from border to only remove OUTER white (keep internal L/E white)
visited = np.zeros((h, w), dtype=bool)
stack = [(0, 0), (0, w - 1), (h - 1, 0), (h - 1, w - 1)]
while stack:
    y, x = stack.pop()
    if y < 0 or y >= h or x < 0 or x >= w:
        continue
    if visited[y, x] or not white[y, x]:
        continue
    visited[y, x] = True
    stack.extend([(y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)])

# also clear any fully-transparent leftover
a[visited, 3] = 0
Image.fromarray(a).save(out)

# report
keep = int((a[:, :, 3] > 0).sum())
print(f"kept pixels: {keep} ({keep/(h*w)*100:.1f}% of image)")
print("saved", out)
