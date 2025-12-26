import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PreviewScreen extends StatefulWidget {
  final String videoPath;
  const PreviewScreen({super.key, required this.videoPath});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late VideoPlayerController _controller;
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() => initialized = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _verVideo() {
    _controller.seekTo(Duration.zero);
    _controller.play();
  }

  void _guardar() {
    // Placeholder – acá irá el upload a Firebase Storage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Guardar: próximamente (upload cloud)")),
    );
  }

  void _descartar() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vista previa")),
      body: Column(
        children: [
          Expanded(
            child: initialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _descartar,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text("Descartar"),
                ),
                ElevatedButton(
                  onPressed: _verVideo,
                  child: const Text("Ver video"),
                ),
                ElevatedButton(
                  onPressed: _guardar,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Guardar"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
