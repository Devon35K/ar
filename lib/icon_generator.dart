// Run this to generate pixel art app icons
// flutter run -t lib/icon_generator.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' show pi;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Generate icons for each density
  await generateIcon(48, 'android/app/src/main/res/mipmap-mdpi/ic_launcher.png');
  await generateIcon(72, 'android/app/src/main/res/mipmap-hdpi/ic_launcher.png');
  await generateIcon(96, 'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png');
  await generateIcon(144, 'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png');
  await generateIcon(192, 'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png');
  
  print('✓ All pixel art icons generated successfully!');
  exit(0);
}

Future<void> generateIcon(int size, String path) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Background - deep space with gradient
  final bgPaint = Paint()..color = const Color(0xFF0D0221);
  canvas.drawRect(Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), bgPaint);
  
  // Grid size for pixel art (16x16 grid)
  final pixelSize = size / 16;
  
  // Paint colors
  final goldPaint = Paint()..color = const Color(0xFFFFD700);
  final darkGoldPaint = Paint()..color = const Color(0xFFB8860B);
  final cyanPaint = Paint()..color = const Color(0xFF00CED1);
  final redPaint = Paint()..color = const Color(0xFFFF6B6B);
  final whitePaint = Paint()..color = Colors.white;
  
  // Draw pixel art gauntlet/fist centered
  void drawPixel(int x, int y, Paint paint) {
    final px = 4 + x;
    final py = 4 + y;
    canvas.drawRect(
      Rect.fromLTWH(
        px * pixelSize,
        py * pixelSize,
        pixelSize + 0.5, // +0.5 to avoid gaps
        pixelSize + 0.5,
      ),
      paint,
    );
  }
  
  // Draw pixel art gauntlet (8x8 fist shape)
  // Row 0 - top knuckles
  drawPixel(2, 0, darkGoldPaint);
  drawPixel(3, 0, goldPaint);
  drawPixel(4, 0, goldPaint);
  drawPixel(5, 0, darkGoldPaint);
  
  // Row 1
  drawPixel(1, 1, darkGoldPaint);
  drawPixel(2, 1, goldPaint);
  drawPixel(3, 1, goldPaint);
  drawPixel(4, 1, goldPaint);
  drawPixel(5, 1, goldPaint);
  drawPixel(6, 1, darkGoldPaint);
  
  // Row 2 - knuckles
  drawPixel(0, 2, goldPaint);
  drawPixel(1, 2, goldPaint);
  drawPixel(2, 2, goldPaint);
  drawPixel(3, 2, goldPaint);
  drawPixel(4, 2, goldPaint);
  drawPixel(5, 2, goldPaint);
  drawPixel(6, 2, goldPaint);
  drawPixel(7, 2, darkGoldPaint);
  
  // Row 3 - gem center
  drawPixel(0, 3, goldPaint);
  drawPixel(1, 3, goldPaint);
  drawPixel(2, 3, goldPaint);
  drawPixel(3, 3, cyanPaint); // Cyan gem
  drawPixel(4, 3, goldPaint);
  drawPixel(5, 3, goldPaint);
  drawPixel(6, 3, goldPaint);
  drawPixel(7, 3, darkGoldPaint);
  
  // Row 4
  drawPixel(0, 4, goldPaint);
  drawPixel(1, 4, goldPaint);
  drawPixel(2, 4, goldPaint);
  drawPixel(3, 4, goldPaint);
  drawPixel(4, 4, goldPaint);
  drawPixel(5, 4, goldPaint);
  drawPixel(6, 4, darkGoldPaint);
  
  // Row 5 - wrist
  drawPixel(2, 5, darkGoldPaint);
  drawPixel(3, 5, goldPaint);
  drawPixel(4, 5, goldPaint);
  drawPixel(5, 5, darkGoldPaint);
  
  // Row 6 - wrist band
  drawPixel(2, 6, darkGoldPaint);
  drawPixel(3, 6, darkGoldPaint);
  drawPixel(4, 6, darkGoldPaint);
  drawPixel(5, 6, darkGoldPaint);
  
  // Energy particles around the fist
  drawPixel(6, -1, cyanPaint);
  drawPixel(7, 1, redPaint);
  drawPixel(-1, 3, cyanPaint);
  drawPixel(8, 4, redPaint);
  drawPixel(0, 7, whitePaint);
  drawPixel(7, 7, whitePaint);
  
  // Convert to image
  final picture = recorder.endRecording();
  final img = await picture.toImage(size, size);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  
  if (byteData != null) {
    final file = File(path);
    await file.writeAsBytes(byteData.buffer.asUint8List());
    print('✓ Generated: $path (${size}x$size)');
  }
}
