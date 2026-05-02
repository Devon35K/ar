import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  final VoidCallback onStart;

  const LandingPage({super.key, required this.onStart});

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
            // Stars background (Simple decoration)
            ...List.generate(50, (index) {
              return Positioned(
                left: (index * 137.5) % MediaQuery.of(context).size.width,
                top: (index * 243.7) % MediaQuery.of(context).size.height,
                child: Container(
                  width: 2,
                  height: 2,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white70,
                        blurRadius: 2,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            }),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  const Text(
                    "AR MOTION\nSMASHER",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFD700), // Gold
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                          color: Colors.red,
                          offset: Offset(3, 3),
                          blurRadius: 0,
                        ),
                        Shadow(
                          color: Colors.blue,
                          offset: Offset(-2, -2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "THE LAST WARDEN",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 8,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Story Teaser
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Earth's orbit has been breached. You are the Last Warden. Channel ancient elemental spells through your hands to shatter the asteroid belt and rebuild the Codex.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Play Button
                  GestureDetector(
                    onTap: onStart,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.yellow[700],
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellow[900]!,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        "PLAY",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Footer
                  const Text(
                    "University of Southeastern Philippines\nICE 323 Professional Elective 3",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 10),
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
