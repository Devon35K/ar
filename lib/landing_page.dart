import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatefulWidget {
  final VoidCallback onStart;

  const LandingPage({super.key, required this.onStart});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _buttonController;

  @override
  void initState() {
    super.initState();
    // Star twinkle animation
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Title pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Story box float animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // Button press animation
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _starController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0221), // Deep space blue
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF1B0B3B), Color(0xFF0D0221)],
            radius: 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Animated Pixel Stars background
            ...List.generate(80, (index) {
              final size = (index % 3 == 0) ? 3.0 : 2.0;
              final baseOpacity = 0.3 + (index % 5) * 0.12;
              final twinkleOffset = index * 0.5;
              return AnimatedBuilder(
                animation: _starController,
                builder: (context, child) {
                  final twinkle = (0.5 + 0.5 * sin((_starController.value * 2 * 3.14159) + twinkleOffset));
                  return Positioned(
                    left: ((index * 137.5) % MediaQuery.of(context).size.width).floorToDouble(),
                    top: ((index * 243.7) % MediaQuery.of(context).size.height).floorToDouble(),
                    child: Container(
                      width: size,
                      height: size,
                      color: Colors.white.withOpacity(baseOpacity * twinkle),
                    ),
                  );
                },
              );
            }),

            // CRT Scanline overlay
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.transparent],
                      stops: [0.0, 1.0],
                    ),
                  ),
                  child: CustomPaint(
                    painter: ScanlinePainter(),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),

            // Vignette overlay
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Pulsing Pixel Art Title
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final glowIntensity = 0.3 + (_pulseController.value * 0.7);
                      return Column(
                        children: [
                          Text(
                            "AR MOTION",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.pressStart2p(
                              textStyle: TextStyle(
                                color: const Color(0xFFFFD700),
                                fontSize: 24,
                                shadows: [
                                  const Shadow(
                                    color: Color(0xFF8B0000),
                                    offset: Offset(4, 4),
                                    blurRadius: 0,
                                  ),
                                  Shadow(
                                    color: const Color(0xFFFFD700).withOpacity(glowIntensity),
                                    offset: const Offset(0, 0),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "SMASHER",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.pressStart2p(
                              textStyle: TextStyle(
                                color: const Color(0xFFFFD700),
                                fontSize: 24,
                                shadows: [
                                  const Shadow(
                                    color: Color(0xFF8B0000),
                                    offset: Offset(4, 4),
                                    blurRadius: 0,
                                  ),
                                  Shadow(
                                    color: const Color(0xFFFFD700).withOpacity(glowIntensity),
                                    offset: const Offset(0, 0),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF00CED1), width: 2),
                      color: const Color(0xFF00CED1).withOpacity(0.1),
                    ),
                    child: Text(
                      "THE LAST WARDEN",
                      style: GoogleFonts.pressStart2p(
                        textStyle: const TextStyle(
                          color: Color(0xFF00CED1),
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Floating Pixel Art Story Box
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      final floatY = _floatController.value * 6 - 3; // -3 to +3 pixels
                      return Transform.translate(
                        offset: Offset(0, floatY),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A0A2E),
                              border: Border.all(
                                color: const Color(0xFF4A4A4A),
                                width: 4,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(4, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Pixel corner decorations
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(width: 8, height: 8, color: const Color(0xFF00CED1)),
                                    Container(width: 8, height: 8, color: const Color(0xFF00CED1)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "EARTH'S ORBIT HAS BEEN BREACHED",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.pressStart2p(
                                    textStyle: const TextStyle(
                                      color: Color(0xFFFF6B6B),
                                      fontSize: 8,
                                      height: 1.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "You are the Last Warden. Channel ancient elemental spells through your hands to shatter the asteroid belt and rebuild the Codex.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.pressStart2p(
                                    textStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 8,
                                      height: 1.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(width: 8, height: 8, color: const Color(0xFF00CED1)),
                                    Container(width: 8, height: 8, color: const Color(0xFF00CED1)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 60),

                  // Animated Pixel Art Play Button
                  GestureDetector(
                    onTapDown: (_) => _buttonController.forward(),
                    onTapUp: (_) {
                      _buttonController.reverse();
                      widget.onStart();
                    },
                    onTapCancel: () => _buttonController.reverse(),
                    child: AnimatedBuilder(
                      animation: _buttonController,
                      builder: (context, child) {
                        final pressOffset = _buttonController.value * 4;
                        return Transform.translate(
                          offset: Offset(pressOffset, pressOffset),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700),
                              border: const Border(
                                top: BorderSide(color: Color(0xFFFFED4A), width: 4),
                                left: BorderSide(color: Color(0xFFFFED4A), width: 4),
                                right: BorderSide(color: Color(0xFFB8860B), width: 4),
                                bottom: BorderSide(color: Color(0xFFB8860B), width: 4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(6 - pressOffset, 6 - pressOffset),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Text(
                              "PLAY",
                              style: GoogleFonts.pressStart2p(
                                textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  shadows: [
                                    Shadow(
                                      color: Color(0x80FFFFFF),
                                      offset: Offset(1, 1),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Pixel Footer
                  Column(
                    children: [
                      Container(
                        width: 200,
                        height: 2,
                        color: Colors.white24,
                        margin: const EdgeInsets.only(bottom: 12),
                      ),
                     
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CRT Scanline effect painter for retro pixel art aesthetic
class ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..strokeWidth = 1;

    // Draw horizontal scanlines
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
