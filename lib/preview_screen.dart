import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PreviewScreen extends StatefulWidget {
  final String videoPath;
  final VoidCallback onDone;

  const PreviewScreen({
    super.key,
    required this.videoPath,
    required this.onDone,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late VideoPlayerController _player;

  @override
  void initState() {
    super.initState();
    _player = VideoPlayerController.file(
      File(widget.videoPath),
    )..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preview")),
      body: Column(
        children: [
          Expanded(
            child: _player.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _player.value.aspectRatio,
                    child: VideoPlayer(_player),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Ver video"),
                  onPressed: () {
                    setState(() {
                      _player.seekTo(Duration.zero);
                      _player.play();
                    });
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera),
                  label: const Text("Nueva grabación"),
                  onPressed: widget.onDone,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
