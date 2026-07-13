from PIL import Image, ImageFilter
import numpy as np

src = "images/img_58723d2058e4.jpg"
out = "images/logo_center.png"

im = Image.open(src).convert("RGBA")
a = np.array(im)
r, g, b = a[:, :, 0], a[:, :, 1], a[:, :, 2]

# 挖空所有接近白色像素（外圍白 + L/E 內部白），保留棕色主體
white = (r > 238) & (g > 238) & (b > 238)
alpha = np.where(white, 0, 255).astype(np.uint8)

# 只對 alpha 做柔化，RGB 保持原色 → 棕色主體銳利、邊緣半透明自然過渡
alpha_img = Image.fromarray(alpha, "L").filter(ImageFilter.GaussianBlur(0.8))
a[:, :, 3] = np.array(alpha_img)
Image.fromarray(a).save(out)

keep = int((a[:, :, 3] > 0).sum())
print(f"kept pixels: {keep} ({keep/(a.shape[0]*a.shape[1])*100:.1f}%)")
print("saved", out)
