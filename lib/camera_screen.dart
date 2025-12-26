import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'preview_screen.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final ResolutionPreset resolution;
  final int duration;
  final int delay;

  const CameraScreen({
    super.key,
    required this.camera,
    required this.resolution,
    required this.duration,
    required this.delay,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initFuture;
  bool recording = false;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      widget.resolution,
      enableAudio: true,
    );

    _initFuture = _controller.initialize();
  }

  Future<void> startRecording() async {
    await Future.delayed(Duration(seconds: widget.delay));

    await _controller.startVideoRecording();
    setState(() => recording = true);

    await Future.delayed(Duration(seconds: widget.duration));

    final file = await _controller.stopVideoRecording();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewScreen(videoPath: file.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: recording ? null : startRecording,
                      child: Text(
                          recording ? "Grabando..." : "Iniciar video 360"),
                    ),
                  ),
                )
              ],
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "ERROR:\n${snapshot.error}",
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
