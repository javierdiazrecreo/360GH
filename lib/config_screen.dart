import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  int delaySeconds = 3;
  int videoSeconds = 6;

  ResolutionPreset resolution = ResolutionPreset.high;
  CameraDescription? selectedCamera;

  bool recordAudio = true;
  bool useFlash = false;

  double zoom = 1.0; // 0.5x queda fuera en esta versión

  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    _loadCameras();
  }

  Future<void> _loadCameras() async {
    final cams = await availableCameras();
    setState(() {
      cameras = cams;
      selectedCamera = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );
    });
  }

  void _startCamera() {
    if (selectedCamera == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CameraScreen(
          camera: selectedCamera!,
          resolution: resolution,
          duration: videoSeconds,
          delay: delaySeconds,
          recordAudio: recordAudio,
          useFlash: useFlash,
          zoom: zoom,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _numberField(
              label: 'Delay (segundos)',
              initialValue: delaySeconds,
              onChanged: (v) => delaySeconds = v,
            ),

            const SizedBox(height: 16),

            _numberField(
              label: 'Duración del video (segundos)',
              initialValue: videoSeconds,
              onChanged: (v) => videoSeconds = v,
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<CameraDescription>(
              value: selectedCamera,
              decoration: const InputDecoration(labelText: 'Cámara'),
              items: cameras.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(
                    c.lensDirection == CameraLensDirection.front
                        ? 'Frontal'
                        : 'Trasera',
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedCamera = v),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<ResolutionPreset>(
              value: resolution,
              decoration: const InputDecoration(labelText: 'Calidad de video'),
              items: const [
                DropdownMenuItem(
                  value: ResolutionPreset.medium,
                  child: Text('720p'),
                ),
                DropdownMenuItem(
                  value: ResolutionPreset.high,
                  child: Text('1080p'),
                ),
                DropdownMenuItem(
                  value: ResolutionPreset.max,
                  child: Text('4K'),
                ),
              ],
              onChanged: (v) => setState(() => resolution = v!),
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Grabar audio'),
              value: recordAudio,
              onChanged: (v) => setState(() => recordAudio = v),
            ),

            SwitchListTile(
              title: const Text('Usar flash'),
              value: useFlash,
              onChanged: (v) => setState(() => useFlash = v),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<double>(
              value: zoom,
              decoration: const InputDecoration(labelText: 'Zoom'),
              items: const [
                DropdownMenuItem(value: 1.0, child: Text('1x')),
                DropdownMenuItem(value: 2.0, child: Text('2x')),
              ],
              onChanged: (v) => setState(() => zoom = v!),
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

  Widget _numberField({
    required String label,
    required int initialValue,
    required Function(int) onChanged,
  }) {
    final controller =
        TextEditingController(text: initialValue.toString());

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onChanged: (v) {
        final n = int.tryParse(v);
        if (n != null) onChanged(n);
      },
    );
  }
}
