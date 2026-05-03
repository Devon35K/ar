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
  bool _isCalibrated = true;

  @override
  void dispose() {
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


      ],
    );
  }
}
