import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'preview_screen.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool recording = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: true,
    );
    _controller.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> record() async {
    setState(() => recording = true);

    await _controller.startVideoRecording();
    await Future.delayed(const Duration(seconds: 8));
    final video = await _controller.stopVideoRecording();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewScreen(videoPath: video.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: recording ? Colors.grey : Colors.red,
                onPressed: recording ? null : record,
                child: const Icon(Icons.videocam),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
