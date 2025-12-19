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
      appBar: AppBar(title: const Text("Vista Previa")),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_controller.value.isInitialized) 
                  Center(child: AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))),
                if (_mostrarBotonPlay)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
                        onPressed: () { setState(() => _mostrarBotonPlay = false); _controller.play(); },
                        icon: const Icon(Icons.play_circle_fill, size: 50),
                        label: const Text("MOSTRAR VIDEO", style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(25),
            color: Colors.black26,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context), 
                  icon: const Icon(Icons.close), 
                  label: const Text("DESCARTAR")
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
                  onPressed: () async {
                    try {
                      // Nombre automático para el log
                      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
                      
                      // Guardamos en la galería
                      await Gal.putVideo(widget.filePath);
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Guardado en Galería: 360_Video_$timestamp.mp4"))
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Error al guardar video"))
                        );
                      }
                    }
                  }, 
                  icon: const Icon(Icons.save_alt), 
                  label: const Text("GUARDAR", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}