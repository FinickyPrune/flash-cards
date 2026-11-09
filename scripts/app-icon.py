#!/usr/bin/env python3
"""Renders the app icon's three 1024x1024 PNGs (default, dark, tinted) into the asset catalog.

The shapes are variant 1 of the icon canvas, https://claude.ai/artifact/Qze1gzuWmB4LedTr5kWyQy
(Icon.dc.html, "card"): coordinates are the canvas's 1024-point SVG coordinates. Change them
there and here together, then run `python3 scripts/app-icon.py`. Needs Pillow.
"""

from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter

SIZE = 1024
# Drawn this many times larger, then scaled down, for smooth edges.
SCALE = 4
OUT = Path(__file__).resolve().parent.parent / "App/Resources/Assets.xcassets/AppIcon.appiconset"

MODES = {
    "AppIcon.png": {
        "gradient": ("#45C4E6", "#6C7CF0"),
        "card": (255, 255, 255, 255),
        "card_back": (255, 255, 255, 115),
        "shadow": (20, 30, 90, 46),
        "bar": (211, 218, 232, 255),
        "pill": (79, 70, 229, 255),
        "word": (255, 255, 255, 255),
    },
    "AppIcon-Dark.png": {
        "gradient": ("#0E2A3A", "#1A1B4B"),
        "card": (38, 44, 74, 255),
        "card_back": (255, 255, 255, 31),
        "shadow": (0, 0, 0, 89),
        "bar": (74, 83, 120, 255),
        "pill": (165, 163, 255, 255),
        "word": (26, 27, 75, 255),
    },
    # Grayscale: iOS tints it with the user's colour.
    "AppIcon-Tinted.png": {
        "gradient": ("#2C2C2E", "#141416"),
        # Opaque, so the card behind doesn't show through it.
        "card": (80, 80, 82, 255),
        "card_back": (255, 255, 255, 26),
        "shadow": None,
        "bar": (255, 255, 255, 115),
        "pill": (255, 255, 255, 255),
        "word": (44, 44, 46, 255),
    },
}


def scaled(*values):
    return [value * SCALE for value in values]


def rect(draw, x, y, width, height, radius, fill):
    draw.rounded_rectangle(scaled(x, y, x + width, y + height), radius=radius * SCALE, fill=fill)


def gradient(start, end):
    """Top-left to bottom-right, as CSS `linear-gradient(135deg, …)` on a square."""
    size = SIZE * SCALE
    # 0 on the left to 127 on the right, and the same from top to bottom: they add up to 0 in the
    # top-left corner and 254 in the bottom-right one.
    horizontal = Image.linear_gradient("L").rotate(90).resize((size, size)).point(lambda value: value // 2)
    vertical = horizontal.transpose(Image.Transpose.ROTATE_270)
    mask = ImageChops.add(horizontal, vertical)
    return Image.composite(Image.new("RGB", (size, size), end), Image.new("RGB", (size, size), start), mask)


def layer():
    return Image.new("RGBA", (SIZE * SCALE, SIZE * SCALE), (0, 0, 0, 0))


def render(colors):
    image = gradient(*colors["gradient"]).convert("RGBA")

    back = layer()
    rect(ImageDraw.Draw(back), 232, 262, 560, 400, 64, colors["card_back"])
    # SVG rotate(-9) turns counter-clockwise; PIL's positive angle does too.
    image.alpha_composite(back.rotate(9, center=scaled(512, 462), resample=Image.Resampling.BICUBIC))

    if colors["shadow"]:
        shadow = layer()
        rect(ImageDraw.Draw(shadow), 212, 372, 600, 420, 68, colors["shadow"])
        image.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(24 * SCALE)))

    front = layer()
    draw = ImageDraw.Draw(front)
    rect(draw, 212, 352, 600, 420, 68, colors["card"])
    image.alpha_composite(front)

    # The subtitle: a word, the highlighted word, the second line.
    marks = layer()
    draw = ImageDraw.Draw(marks)
    rect(draw, 282, 496, 150, 48, 24, colors["bar"])
    rect(draw, 456, 476, 286, 88, 30, colors["pill"])
    rect(draw, 488, 502, 222, 36, 18, colors["word"])
    rect(draw, 282, 600, 380, 48, 24, colors["bar"])
    image.alpha_composite(marks)

    # App icons must be opaque.
    return image.convert("RGB").resize((SIZE, SIZE), Image.Resampling.LANCZOS)


if __name__ == "__main__":
    for name, colors in MODES.items():
        render(colors).save(OUT / name)
        print(OUT / name)
