import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyCameraView extends StatefulWidget {
  const MyCameraView({super.key});

  @override
  State<MyCameraView> createState() => MyCameraViewState();
}

class MyCameraViewState extends State<MyCameraView> {
  final Map<String, dynamic> creationParams = <String, dynamic>{};
  MethodChannel? _channel;
  bool _isCalibrated = false;
  double _calibrationProgress = 0.0;
  String _statusText = "INITIALIZING WARDEN LINK...";
  Timer? _calibrationTimer;

  @override
  void initState() {
    super.initState();
    _startCalibration();
  }

  void _startCalibration() {
    const totalSteps = 100;
    const _ = Duration(milliseconds: 3000);
    const stepDuration = Duration(milliseconds: 30);

    _calibrationTimer = Timer.periodic(stepDuration, (timer) {
      setState(() {
        _calibrationProgress = timer.tick / totalSteps;
        if (_calibrationProgress >= 0.3) {
          _statusText = "SCANNING ENVIRONMENT...";
        }
        if (_calibrationProgress >= 0.6) {
          _statusText = "CALIBRATING GESTURE RADIUS...";
        }
        if (_calibrationProgress >= 0.9) _statusText = "WARDEN SYNC COMPLETE!";

        if (timer.tick >= totalSteps) {
          timer.cancel();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _isCalibrated = true;
              });
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _calibrationTimer?.cancel();
    super.dispose();
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('cameraView_$id');
  }

  Future<void> switchCamera() async {
    try {
      await _channel?.invokeMethod('switchCamera');
    } on PlatformException catch (e) {
      debugPrint("Failed to switch camera: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Camera Layer
        Platform.isAndroid
            ? AndroidView(
                viewType: 'cameraView',
                onPlatformViewCreated: _onPlatformViewCreated,
                layoutDirection: TextDirection.ltr,
                creationParams: creationParams,
                creationParamsCodec: const StandardMessageCodec(),
              )
            : const Placeholder(),

        // Calibration Overlay
        if (!_isCalibrated)
          Container(
            color: Colors.black.withValues(alpha: 0.6),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Scanning Circle
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: CircularProgressIndicator(
                          value: _calibrationProgress,
                          strokeWidth: 8,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.cyanAccent.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.settings_overscan,
                        color: Colors.cyanAccent,
                        size: 50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Progress Bar
                  Container(
                    width: 250,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _calibrationProgress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.cyanAccent,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _statusText,
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${(_calibrationProgress * 100).toInt()}%",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

        // HUD Layer (Only visible when calibrated)
        if (_isCalibrated)
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                border: Border.all(
                  color: Colors.cyanAccent.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.wifi_tethering,
                    color: Colors.cyanAccent,
                    size: 14,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "WARDEN LINK: ACTIVE",
                    style: TextStyle(color: Colors.cyanAccent, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),

        // Switch Camera Button
        if (_isCalibrated)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.blue.withValues(alpha: 0.7),
              onPressed: switchCamera,
              child: const Icon(Icons.flip_camera_android, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
