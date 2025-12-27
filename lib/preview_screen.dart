import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';
import 'services/upload_service.dart';

class PreviewScreen extends StatefulWidget {
  final String videoPath;
  final CameraDescription camera;
  final ResolutionPreset resolution;
  final int duration;
  final int delay;

  const PreviewScreen({
    super.key,
    required this.videoPath,
    required this.camera,
    required this.resolution,
    required this.duration,
    required this.delay,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool uploading = false;
  String status = '';

  Future<void> upload() async {
    setState(() {
      uploading = true;
      status = 'Subiendo video…';
    });

    // sessionId simple y robusto (sin packages)
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      final url = await UploadService.uploadVideo(
        localPath: widget.videoPath,
        sessionId: sessionId,
      );

      setState(() {
        status = 'Upload completo ✅';
      });

      debugPrint('SESSION ID: $sessionId');
      debugPrint('DOWNLOAD URL: $url');

      // 🔜 aquí luego dispararemos cloud / QR
    } catch (e) {
      setState(() {
        status = 'Error al subir ❌';
      });
      debugPrint('UPLOAD ERROR: $e');
    } finally {
      setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.videocam, color: Colors.white, size: 80),
                  SizedBox(height: 12),
                  Text(
                    'Video grabado',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),

          if (status.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                status,
                style: const TextStyle(color: Colors.white),
              ),
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                onPressed: uploading
                    ? null
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CameraScreen(
                              camera: widget.camera,
                              resolution: widget.resolution,
                              duration: widget.duration,
                              delay: widget.delay,
                            ),
                          ),
                        );
                      },
                child: const Text('Descartar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: uploading ? null : upload,
                child: Text(uploading ? 'Subiendo…' : 'Guardar'),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
