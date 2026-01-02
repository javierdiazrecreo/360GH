import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'preview_screen.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final ResolutionPreset resolution;
  final int duration;
  final int delay;
  final bool recordAudio;
  final bool useFlash;
  final double zoom;

  const CameraScreen({
    super.key,
    required this.camera,
    required this.resolution,
    required this.duration,
    required this.delay,
    required this.recordAudio,
    required this.useFlash,
    required this.zoom,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initFuture;

  bool recording = false;
  int countdown = 0;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      widget.resolution,
      enableAudio: widget.recordAudio,
    );

    _initFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _controller.initialize();

    if (widget.useFlash) {
      await _controller.setFlashMode(FlashMode.torch);
    } else {
      await _controller.setFlashMode(FlashMode.off);
    }

    await _controller.setZoomLevel(widget.zoom);
  }

  Future<void> startRecording() async {
    if (recording) return;

    for (int i = widget.delay; i > 0; i--) {
      setState(() => countdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() {
      countdown = 0;
      recording = true;
    });

    await _controller.startVideoRecording();

    await Future.delayed(Duration(seconds: widget.duration));

    final file = await _controller.stopVideoRecording();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewScreen(
          videoPath: file.path,
          camera: widget.camera,
          resolution: widget.resolution,
          duration: widget.duration,
          delay: widget.delay,
        ),
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

                if (countdown > 0)
                  Center(
                    child: Text(
                      '$countdown',
                      style: const TextStyle(
                        fontSize: 120,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: recording ? null : startRecording,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            recording ? Colors.grey : Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                      ),
                      child: Text(
                        recording ? 'Grabando...' : 'Iniciar video 360',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'ERROR CÁMARA:\n${snapshot.error}',
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
