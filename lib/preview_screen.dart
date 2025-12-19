import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:gal/gal.dart';

class PreviewScreen extends StatefulWidget {
  final String filePath;
  const PreviewScreen({super.key, required this.filePath});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late VideoPlayerController _controller;
  bool _mostrarBotonPlay = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Resultado")),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_controller.value.isInitialized) AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller)),
                if (_mostrarBotonPlay)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20)),
                        onPressed: () {
                          setState(() => _mostrarBotonPlay = false);
                          _controller.play();
                        },
                        icon: const Icon(Icons.play_circle_fill, size: 40),
                        label: const Text("MOSTRAR VIDEO", style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.replay), label: const Text("REPETIR")),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Gal.putVideo(widget.filePath);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Video guardado en la galería!")));
                  }, 
                  icon: const Icon(Icons.save), 
                  label: const Text("GUARDAR"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}