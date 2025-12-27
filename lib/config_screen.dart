import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'package:camera/camera.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  int delaySeconds = 3;
  int videoSeconds = 6;
  ResolutionPreset resolution = ResolutionPreset.high;

  Future<void> _startCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras found');
      }

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CameraScreen(
            camera: cameras.first,
            resolution: resolution,
            duration: videoSeconds,
            delay: delaySeconds,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cámara: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Delay (segundos)'),
            Slider(
              min: 0,
              max: 10,
              divisions: 10,
              value: delaySeconds.toDouble(),
              label: delaySeconds.toString(),
              onChanged: (v) => setState(() => delaySeconds = v.toInt()),
            ),

            const SizedBox(height: 16),

            const Text('Duración del video (segundos)'),
            Slider(
              min: 3,
              max: 15,
              divisions: 12,
              value: videoSeconds.toDouble(),
              label: videoSeconds.toString(),
              onChanged: (v) => setState(() => videoSeconds = v.toInt()),
            ),

            const SizedBox(height: 16),

            const Text('Resolución'),
            DropdownButton<ResolutionPreset>(
              value: resolution,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: ResolutionPreset.low,
                  child: Text('Baja'),
                ),
                DropdownMenuItem(
                  value: ResolutionPreset.medium,
                  child: Text('Media'),
                ),
                DropdownMenuItem(
                  value: ResolutionPreset.high,
                  child: Text('Alta'),
                ),
                DropdownMenuItem(
                  value: ResolutionPreset.veryHigh,
                  child: Text('Muy alta'),
                ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => resolution = v);
              },
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _startCamera,
              child: const Text('Guardar y continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
