import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';

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
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Listo")),
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
                        onPressed: () { setState(() => _mostrarBotonPlay = false); _controller.play(); },
                        icon: const Icon(Icons.play_arrow, size: 40),
                        label: const Text("REPRODUCIR", style: TextStyle(fontSize: 20)),
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
                TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), label: const Text("DESCARTAR")),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  onPressed: () async {
                    // Nombre automático: Video_20240520_1530.mp4
                    String nombreFinal = "Video_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.mp4";
                    await Gal.putVideo(widget.filePath, album: "App360");
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Guardado como: $nombreFinal")));
                  }, 
                  icon: const Icon(Icons.check), 
                  label: const Text("GUARDAR EN GALERÍA"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}