// Script to generate pixel art app icons for AR Motion Smasher
// Run: dart generate_icons.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

void main() async {
  // Generate icons for each density
  await generateIcon(48, 'android/app/src/main/res/mipmap-mdpi/ic_launcher.png');
  await generateIcon(72, 'android/app/src/main/res/mipmap-hdpi/ic_launcher.png');
  await generateIcon(96, 'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png');
  await generateIcon(144, 'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png');
  await generateIcon(192, 'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png');
  
  print('✓ Pixel art icons generated successfully!');
}

Future<void> generateIcon(int size, String path) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Background - deep space
  final bgPaint = Paint()..color = const Color(0xFF0D0221);
  canvas.drawRect(Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), bgPaint);
  
  // Grid size for pixel art
  final pixelSize = size / 16;
  
  // Draw pixel art gauntlet/fist
  final goldPaint = Paint()..color = const Color(0xFFFFD700);
  final darkGoldPaint = Paint()..color = const Color(0xFFB8860B);
  final cyanPaint = Paint()..color = const Color(0xFF00CED1);
  final redPaint = Paint()..color = const Color(0xFFFF6B6B);
  
  // Draw fist shape (8x8 grid centered)
  final startX = 4 * pixelSize;
  final startY = 4 * pixelSize;
  
  // Gauntlet base (gold pixels)
  void drawPixel(int x, int y, Paint paint) {
    canvas.drawRect(
      Rect.fromLTWH(
        startX + x * pixelSize,
        startY + y * pixelSize,
        pixelSize,
        pixelSize,
      ),
      paint,
    );
  }
  
  // Draw pixel art fist
  // Row 0
  drawPixel(1, 0, darkGoldPaint);
  drawPixel(2, 0, goldPaint);
  drawPixel(3, 0, goldPaint);
  drawPixel(4, 0, darkGoldPaint);
  
  // Row 1
  drawPixel(0, 1, darkGoldPaint);
  drawPixel(1, 1, goldPaint);
  drawPixel(2, 1, goldPaint);
  drawPixel(3, 1, goldPaint);
  drawPixel(4, 1, goldPaint);
  drawPixel(5, 1, darkGoldPaint);
  
  // Row 2 (knuckles)
  drawPixel(0, 2, goldPaint);
  drawPixel(1, 2, goldPaint);
  drawPixel(2, 2, goldPaint);
  drawPixel(3, 2, goldPaint);
  drawPixel(4, 2, goldPaint);
  drawPixel(5, 2, goldPaint);
  drawPixel(6, 2, darkGoldPaint);
  
  // Row 3
  drawPixel(0, 3, goldPaint);
  drawPixel(1, 3, goldPaint);
  drawPixel(2, 3, cyanPaint); // Gem
  drawPixel(3, 3, goldPaint);
  drawPixel(4, 3, goldPaint);
  drawPixel(5, 3, goldPaint);
  drawPixel(6, 3, darkGoldPaint);
  
  // Row 4
  drawPixel(0, 4, goldPaint);
  drawPixel(1, 4, goldPaint);
  drawPixel(2, 4, goldPaint);
  drawPixel(3, 4, goldPaint);
  drawPixel(4, 4, goldPaint);
  drawPixel(5, 4, darkGoldPaint);
  
  // Row 5
  drawPixel(1, 5, darkGoldPaint);
  drawPixel(2, 5, goldPaint);
  drawPixel(3, 5, goldPaint);
  drawPixel(4, 5, darkGoldPaint);
  
  // Energy particles (floating around)
  drawPixel(6, 0, cyanPaint);
  drawPixel(7, 3, redPaint);
  drawPixel(0, 6, cyanPaint);
  drawPixel(7, 6, redPaint);
  
  // Picture to image
  final picture = recorder.endRecording();
  final img = await picture.toImage(size, size);
  final byteData = await img.toByteData(format: ImageByteFormat.png);
  
  if (byteData != null) {
    final file = File(path);
    await file.writeAsBytes(byteData.buffer.asUint8List());
    print('✓ Generated: $path (${size}x$size)');
  }
}
