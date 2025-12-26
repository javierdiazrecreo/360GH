import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'models/recording_config.dart';

class CameraScreen extends StatefulWidget {
  final RecordingConfig config;

  const CameraScreen({super.key, required this.config});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initFuture;

  bool _recording = false;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.config.camera,
      widget.config.resolution,
      enableAudio: widget.config.audio,
    );

    _initFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_recording) return;

    setState(() => _recording = true);

    // Delay antes de grabar
    if (widget.config.delaySeconds > 0) {
      await Future.delayed(
        Duration(seconds: widget.config.delaySeconds),
      );
    }

    await _controller.startVideoRecording();

    await Future.delayed(
      Duration(seconds: widget.config.durationSeconds),
    );

    final video = await _controller.stopVideoRecording();

    if (!mounted) return;

    Navigator.pop(context, video.path);
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
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingActionButton.extended(
                      backgroundColor:
                          _recording ? Colors.grey : Colors.red,
                      onPressed: _recording ? null : _startRecording,
                      icon: const Icon(Icons.videocam),
                      label: Text(
                        _recording ? "GRABANDO..." : "INICIAR 360",
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
                "ERROR CÁMARA:\n${snapshot.error}",
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
}
