import 'dart:io';

import 'package:ar/my_camera_view.dart';
import 'package:ar/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Motion Smasher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.yellow,
          brightness: Brightness.dark,
        ),
      ),
      home: const MainGameContainer(),
    );
  }
}

class MainGameContainer extends StatefulWidget {
  const MainGameContainer({super.key});

  @override
  State<MainGameContainer> createState() => _MainGameContainerState();
}

class _MainGameContainerState extends State<MainGameContainer> {
  bool _gameStarted = false;
  bool _isPermissionGranted = Platform.isAndroid ? false : true;
  static const _cameraPermissionChannel = MethodChannel("camera_permission");

  Future<void> _requestPermissionAndStart() async {
    if (Platform.isAndroid) {
      try {
        final bool result = await _cameraPermissionChannel.invokeMethod(
          'getCameraPermission',
        );
        if (result) {
          setState(() {
            _isPermissionGranted = true;
            _gameStarted = true;
          });
        } else {
          debugPrint("Camera Permission is denied");
          _showPermissionDeniedDialog();
        }
      } on PlatformException catch (e) {
        debugPrint("Failed to get camera permission: '${e.message}'.");
      }
    } else {
      setState(() {
        _gameStarted = true;
      });
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "This game requires camera access to detect your hand motions. Please grant permission in your device settings and restart the app.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_gameStarted) {
      return LandingPage(onStart: _requestPermissionAndStart);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: _isPermissionGranted
          ? const SafeArea(child: MyCameraView())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Camera permission is required to play."),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _requestPermissionAndStart,
                    child: const Text("Grant Permission"),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => setState(() => _gameStarted = false),
                    child: const Text("Back to Menu"),
                  ),
                ],
              ),
            ),
    );
  }
}
