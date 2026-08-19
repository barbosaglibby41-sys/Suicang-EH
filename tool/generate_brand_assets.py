#!/usr/bin/env python3
"""Generate Suicang EH iOS/Android app icons from the brand artwork."""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'assets/branding/suicang_eh_icon_1024.png'
ANDROID = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}
IOS = {
    'AppIcon-20@2x.png': 40,
    'AppIcon-20@3x.png': 60,
    'AppIcon-29@2x.png': 58,
    'AppIcon-29@3x.png': 87,
    'AppIcon-40@2x.png': 80,
    'AppIcon-40@3x.png': 120,
    'AppIcon-60@2x.png': 120,
    'AppIcon-60@3x.png': 180,
    'AppIcon-76@2x.png': 152,
    'AppIcon-83.5@2x.png': 167,
    'AppIcon-1024.png': 1024,
}

def main():
    source = Image.open(SOURCE).convert('RGB')
    for folder, size in ANDROID.items():
        output = ROOT / 'android/app/src/main/res' / folder / 'ic_launcher.png'
        output.parent.mkdir(parents=True, exist_ok=True)
        source.resize((size, size), Image.Resampling.LANCZOS).save(output, optimize=True)
    iconset = ROOT / 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    iconset.mkdir(parents=True, exist_ok=True)
    for name, size in IOS.items():
        source.resize((size, size), Image.Resampling.LANCZOS).save(iconset / name, optimize=True)

if __name__ == '__main__':
    main()
