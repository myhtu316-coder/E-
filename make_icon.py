import os, math
from PIL import Image, ImageDraw, ImageFont

OUT = '/Users/hpc/github_deploy'
W = 512
img = Image.new('RGBA', (W, W), (5, 11, 20, 255))
d = ImageDraw.Draw(img)

# 背景垂直漸層
for y in range(W):
    t = y / W
    r = int(5 + (10 - 5) * t)
    g = int(11 + (26 - 11) * t)
    b = int(20 + (46 - 20) * t)
    d.line([(0, y), (W, y)], fill=(r, g, b, 255))

# 中央水珠層次圓
cx, cy = W // 2, W // 2 - 50
r = W // 3
d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(0, 243, 255, 55))
d.ellipse([cx - r + 22, cy - r + 22, cx + r - 22, cy + r - 22], fill=(0, 243, 255, 110))
d.ellipse([cx - r + 70, cy - r + 70, cx + r - 70, cy + r - 70], fill=(179, 136, 255, 90))

# 底部波浪
for k, off in enumerate([W - 150, W - 110]):
    pts = []
    for x in range(0, W + 1, 4):
        yy = off + 12 * abs(math.sin((x / W) * math.pi * 2 + k))
        pts.append((x, yy))
    d.line(pts, fill=(255, 255, 255, 80), width=4)

# 文字
try:
    font = ImageFont.truetype('/System/Library/Fonts/PingFang.ttc', 70)
except Exception:
    font = ImageFont.load_default()
label = '海水小幫手'
bbox = d.textbbox((0, 0), label, font=font)
tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
tx, ty = (W - tw) / 2 - bbox[0], (W - 70) - bbox[1]
d.text((tx, ty), label, font=font, fill=(255, 255, 255, 255))

img.save(os.path.join(OUT, 'icon-512.png'))
img.resize((192, 192)).save(os.path.join(OUT, 'icon-192.png'))
img.resize((180, 180)).save(os.path.join(OUT, 'icon-180.png'))
for n in ['icon-512.png', 'icon-192.png', 'icon-180.png']:
    print(n, os.path.getsize(os.path.join(OUT, n)), 'bytes')
