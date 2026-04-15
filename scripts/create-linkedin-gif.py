#!/usr/bin/env python3
"""Build an animated GIF for LinkedIn from the BMIT event photo + app screenshots.

Usage:
    python3 scripts/create-linkedin-gif.py [path/to/event-photo.jpg]

Default event photo path: assets/screenshots/event-photo.jpg
Output: assets/linkedin-demo.gif
"""

import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

REPO_ROOT = Path(__file__).resolve().parent.parent
SCREENSHOTS_DIR = REPO_ROOT / "assets" / "screenshots"
OUTPUT_PATH = REPO_ROOT / "assets" / "linkedin-demo.gif"

TARGET_WIDTH = 1280
TARGET_HEIGHT = 900
FRAME_DURATION_MS = 3000  # 3 seconds per frame

CAPTIONS = [
    "Live demo at BMIT Perspectives 2026 🇲🇹",
    "Il-Pastizzeria ta' Mario — built with GitHub Copilot",
    "Pastizzi, Cisk, Kinnie — the full Maltese menu",
]

FRAME_SOURCES = [
    None,  # slot 0: event photo (set from CLI arg or default)
    SCREENSHOTS_DIR / "landing-page.png",
    SCREENSHOTS_DIR / "menu-items.png",
]


def load_and_resize(path: Path) -> Image.Image:
    """Load an image and resize/crop to TARGET dimensions."""
    img = Image.open(path).convert("RGB")
    # Resize preserving aspect ratio, then center-crop to exact target
    src_w, src_h = img.size
    scale = max(TARGET_WIDTH / src_w, TARGET_HEIGHT / src_h)
    new_w = int(src_w * scale)
    new_h = int(src_h * scale)
    img = img.resize((new_w, new_h), Image.LANCZOS)
    # Center crop
    left = (new_w - TARGET_WIDTH) // 2
    top = (new_h - TARGET_HEIGHT) // 2
    img = img.crop((left, top, left + TARGET_WIDTH, top + TARGET_HEIGHT))
    return img


def add_caption(img: Image.Image, text: str) -> Image.Image:
    """Add a semi-transparent caption bar at the bottom of the frame."""
    frame = img.copy()
    draw = ImageDraw.Draw(frame)

    # Semi-transparent overlay bar at the bottom
    bar_height = 70
    overlay = Image.new("RGBA", (TARGET_WIDTH, bar_height), (0, 0, 0, 180))
    frame_rgba = frame.convert("RGBA")
    frame_rgba.paste(overlay, (0, TARGET_HEIGHT - bar_height), overlay)
    frame = frame_rgba.convert("RGB")

    draw = ImageDraw.Draw(frame)

    # Try to use a decent font, fall back to default
    font_size = 28
    font = None
    for font_path in [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
        "/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf",
    ]:
        if Path(font_path).exists():
            font = ImageFont.truetype(font_path, font_size)
            break
    if font is None:
        font = ImageFont.load_default()

    # Center text in the bar
    bbox = draw.textbbox((0, 0), text, font=font)
    text_w = bbox[2] - bbox[0]
    text_x = (TARGET_WIDTH - text_w) // 2
    text_y = TARGET_HEIGHT - bar_height + (bar_height - font_size) // 2
    draw.text((text_x, text_y), text, fill="white", font=font)

    return frame


def main():
    # Resolve event photo path
    if len(sys.argv) > 1:
        event_photo = Path(sys.argv[1])
    else:
        event_photo = SCREENSHOTS_DIR / "event-photo.jpg"

    if not event_photo.exists():
        print(f"ERROR: Event photo not found at {event_photo}")
        print("Save the BMIT event photo there first, then re-run this script.")
        print(f"  e.g.: cp ~/Downloads/event-photo.jpg {event_photo}")
        sys.exit(1)

    FRAME_SOURCES[0] = event_photo

    # Verify all frames exist
    for i, src in enumerate(FRAME_SOURCES):
        if not src.exists():
            print(f"ERROR: Frame {i} not found: {src}")
            sys.exit(1)

    # Build frames
    frames = []
    for src, caption in zip(FRAME_SOURCES, CAPTIONS):
        img = load_and_resize(src)
        img = add_caption(img, caption)
        frames.append(img)

    # Save animated GIF
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    frames[0].save(
        OUTPUT_PATH,
        save_all=True,
        append_images=frames[1:],
        duration=FRAME_DURATION_MS,
        loop=0,  # infinite loop
        optimize=True,
    )

    size_kb = OUTPUT_PATH.stat().st_size / 1024
    print(f"GIF created: {OUTPUT_PATH} ({size_kb:.0f} KB)")
    print(f"  Frames: {len(frames)}, Duration: {FRAME_DURATION_MS}ms/frame")
    print(f"  Size: {TARGET_WIDTH}x{TARGET_HEIGHT}")


if __name__ == "__main__":
    main()
