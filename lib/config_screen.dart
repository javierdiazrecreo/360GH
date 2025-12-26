import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';
import 'models/recording_config.dart';

class ConfigScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ConfigScreen({super.key, required this.cameras});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  int _duration = 10;
  int _delay = 3;
  bool _audio = true;
  ResolutionPreset _resolution = ResolutionPreset.high;
  int _cameraIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('360Party')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: _cameraIndex,
              decoration: const InputDecoration(labelText: 'Cámara'),
              items: List.generate(widget.cameras.length, (i) {
                return DropdownMenuItem(
                  value: i,
                  child: Text('Cámara ${i + 1}'),
                );
              }),
              onChanged: (v) => setState(() => _cameraIndex = v!),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<ResolutionPreset>(
              value: _resolution,
              decoration: const InputDecoration(labelText: 'Resolución'),
              items: const [
                DropdownMenuItem(value: ResolutionPreset.medium, child: Text('720p')),
                DropdownMenuItem(value: ResolutionPreset.high, child: Text('1080p')),
                DropdownMenuItem(value: ResolutionPreset.ultraHigh, child: Text('4K')),
              ],
              onChanged: (v) => setState(() => _resolution = v!),
            ),

            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text('Grabar audio'),
              value: _audio,
              onChanged: (v) => setState(() => _audio = v),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Duración (s)'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _duration = int.tryParse(v) ?? _duration,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Delay (s)'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _delay = int.tryParse(v) ?? _delay,
                  ),
                ),
              ],
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                final config = RecordingConfig(
                  camera: widget.cameras[_cameraIndex],
                  durationSeconds: _duration,
                  delaySeconds: _delay,
                  resolution: _resolution,
                  audio: _audio,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CameraScreen(config: config),
                  ),
                );
              },
              child: const Text('Abrir cámara'),
            ),
          ],
        ),
      ),
    );
  }
}
