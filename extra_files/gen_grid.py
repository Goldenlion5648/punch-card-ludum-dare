
from PIL import Image, ImageDraw

# Grid configuration
cols = 4
rows = 8
cell_size = 100
line_width = 3
margin = 0

# Image dimensions
width = cols * cell_size + 2 * margin
height = rows * cell_size + 2 * margin

# Create a white image
image = Image.new("RGB", (width, height), "white")
draw = ImageDraw.Draw(image)

# Draw vertical lines
for col in range(cols + 1):
    x = margin + col * cell_size
    draw.line(
        [(x, margin), (x, margin + rows * cell_size)],
        fill="black",
        width=line_width,
    )

# Draw horizontal lines
for row in range(rows + 1):
    y = margin + row * cell_size
    draw.line(
        [(margin, y), (margin + cols * cell_size, y)],
        fill="black",
        width=line_width,
    )

# Save the image
image.save("grid.png")
print(f"Saved grid.png ({width}x{height} pixels)")
