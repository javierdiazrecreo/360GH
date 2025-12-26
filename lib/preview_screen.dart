import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:gal/gal.dart';

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
        setState(() {
          initialized = true;
        });
      });
  }

  Future<void> guardar() async {
    await Gal.putVideo(widget.videoPath, album: "360Party");
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Video guardado en 360Party")),
    );
  }

  void descartar() {
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
            child: Column(
              children: [
                // ▶️ VER VIDEO
                ElevatedButton.icon(
                  onPressed: () {
                    _controller.seekTo(Duration.zero);
                    _controller.play();
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Ver video"),
                ),

                const SizedBox(height: 12),

                // 💾 GUARDAR
                ElevatedButton.icon(
                  onPressed: guardar,
                  icon: const Icon(Icons.save),
                  label: const Text("Guardar"),
                ),

                const SizedBox(height: 12),

                // ❌ DESCARTAR
                OutlinedButton.icon(
                  onPressed: descartar,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Descartar"),
                ),
              ],
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
