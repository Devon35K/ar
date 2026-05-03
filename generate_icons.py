#!/usr/bin/env python3
"""
Generate pixel art app icons for AR Motion Smasher
Run: python generate_icons.py
"""

from PIL import Image
import os

def create_pixel_icon(size):
    """Create a pixel art gauntlet icon"""
    img = Image.new('RGBA', (size, size), (13, 2, 33, 255))  # Deep space background
    pixels = img.load()
    
    # Scale factor (16x16 grid)
    scale = size / 16
    
    def draw_pixel(x, y, color):
        """Draw a single pixel at grid position"""
        px = int((4 + x) * scale)
        py = int((4 + y) * scale)
        ps = int(scale + 1)  # +1 to avoid gaps
        
        for dx in range(ps):
            for dy in range(ps):
                if px + dx < size and py + dy < size:
                    pixels[px + dx, py + dy] = color
    
    # Colors
    GOLD = (255, 215, 0, 255)         # Gold gauntlet
    DARK_GOLD = (184, 134, 11, 255)   # Dark gold shadow
    CYAN = (0, 206, 209, 255)         # Cyan gem
    RED = (255, 107, 107, 255)        # Red energy
    WHITE = (255, 255, 255, 255)      # White sparkle
    
    # Pixel art gauntlet (8x8 fist shape)
    # Row 0 - top knuckles
    draw_pixel(2, 0, DARK_GOLD)
    draw_pixel(3, 0, GOLD)
    draw_pixel(4, 0, GOLD)
    draw_pixel(5, 0, DARK_GOLD)
    
    # Row 1
    draw_pixel(1, 1, DARK_GOLD)
    draw_pixel(2, 1, GOLD)
    draw_pixel(3, 1, GOLD)
    draw_pixel(4, 1, GOLD)
    draw_pixel(5, 1, GOLD)
    draw_pixel(6, 1, DARK_GOLD)
    
    # Row 2 - knuckles
    draw_pixel(0, 2, GOLD)
    draw_pixel(1, 2, GOLD)
    draw_pixel(2, 2, GOLD)
    draw_pixel(3, 2, GOLD)
    draw_pixel(4, 2, GOLD)
    draw_pixel(5, 2, GOLD)
    draw_pixel(6, 2, GOLD)
    draw_pixel(7, 2, DARK_GOLD)
    
    # Row 3 - gem center
    draw_pixel(0, 3, GOLD)
    draw_pixel(1, 3, GOLD)
    draw_pixel(2, 3, GOLD)
    draw_pixel(3, 3, CYAN)  # Cyan gem in center
    draw_pixel(4, 3, GOLD)
    draw_pixel(5, 3, GOLD)
    draw_pixel(6, 3, GOLD)
    draw_pixel(7, 3, DARK_GOLD)
    
    # Row 4
    draw_pixel(0, 4, GOLD)
    draw_pixel(1, 4, GOLD)
    draw_pixel(2, 4, GOLD)
    draw_pixel(3, 4, GOLD)
    draw_pixel(4, 4, GOLD)
    draw_pixel(5, 4, GOLD)
    draw_pixel(6, 4, DARK_GOLD)
    
    # Row 5 - wrist
    draw_pixel(2, 5, DARK_GOLD)
    draw_pixel(3, 5, GOLD)
    draw_pixel(4, 5, GOLD)
    draw_pixel(5, 5, DARK_GOLD)
    
    # Row 6 - wrist band
    draw_pixel(2, 6, DARK_GOLD)
    draw_pixel(3, 6, DARK_GOLD)
    draw_pixel(4, 6, DARK_GOLD)
    draw_pixel(5, 6, DARK_GOLD)
    
    # Energy particles
    draw_pixel(6, -1, CYAN)
    draw_pixel(7, 1, RED)
    draw_pixel(-1, 3, CYAN)
    draw_pixel(8, 4, RED)
    draw_pixel(0, 7, WHITE)
    draw_pixel(7, 7, WHITE)
    
    return img

def main():
    # Define icon sizes for Android
    icon_sizes = {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
    }
    
    base_path = 'android/app/src/main/res'
    
    for density, size in icon_sizes.items():
        path = f'{base_path}/mipmap-{density}/ic_launcher.png'
        
        # Create directory if needed
        os.makedirs(os.path.dirname(path), exist_ok=True)
        
        # Generate and save icon
        icon = create_pixel_icon(size)
        icon.save(path, 'PNG')
        print(f'✓ Generated: {path} ({size}x{size})')
    
    print('\n✓ All pixel art app icons generated successfully!')
    print('  Run: flutter clean && flutter run')

if __name__ == '__main__':
    main()
