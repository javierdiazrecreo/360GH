import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'services/code_service.dart';
import 'services/upload_service.dart';

class ProcessingScreen extends StatefulWidget {
  final String videoPath;
  const ProcessingScreen({super.key, required this.videoPath});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  late final String code;
  bool uploaded = false;

  @override
  void initState() {
    super.initState();
    code = CodeService.generate();
    _upload();
  }

  Future<void> _upload() async {
    await UploadService.upload(
      path: widget.videoPath,
      code: code,
    );
    setState(() => uploaded = true);
  }

  void openWhatsapp() {
    final msg = Uri.encodeComponent("Hola, mi código es $code");
    launchUrl(Uri.parse("https://wa.me/?text=$msg"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tu video")),
      body: Center(
        child: uploaded
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("CÓDIGO: $code",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  QrImageView(
                    data:
                        "https://gallery-generator-440763478814.us-central1.run.app",
                    size: 220,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: openWhatsapp,
                    icon: const Icon(Icons.chat),
                    label: const Text("Enviar por WhatsApp"),
                  )
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
