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
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    // Cargamos el video recién grabado desde el archivo temporal
    _videoController = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(true);
        _videoController.play();
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Revisar Captura 360", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: _videoController.value.isInitialized
                ? Center(
                    child: AspectRatio(
                      aspectRatio: _videoController.value.aspectRatio,
                      child: VideoPlayer(_videoController),
                    ),
                  )
                : const Center(child: CircularProgressIndicator(color: Colors.red)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // BOTÓN DESCARTAR (Vuelve atrás para repetir)
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  label: const Text("DESCARTAR", style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                ),
                // BOTÓN GUARDAR (Lo manda a la Galería de fotos)
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await Gal.putVideo(widget.filePath);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("✅ ¡Video guardado en Galería!")),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      debugPrint("Error al guardar: $e");
                    }
                  },
                  icon: const Icon(Icons.save_alt, color: Colors.white),
                  label: const Text("GUARDAR", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}