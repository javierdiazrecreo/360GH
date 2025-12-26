import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';

class ConfigScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ConfigScreen({super.key, required this.cameras});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  late List<CameraDescription> usableCameras;
  late CameraDescription selectedCamera;

  ResolutionPreset resolution = ResolutionPreset.high; // 1080p por defecto
  int duration = 10;
  int delay = 3;

  @override
  void initState() {
    super.initState();

    // Solo frontal y trasera
    usableCameras = widget.cameras
        .where((c) =>
            c.lensDirection == CameraLensDirection.back ||
            c.lensDirection == CameraLensDirection.front)
        .toList();

    selectedCamera = usableCameras.first;
  }

  String cameraLabel(CameraDescription cam) {
    return cam.lensDirection == CameraLensDirection.back
        ? "Trasera"
        : "Frontal";
  }

  String resolutionLabel(ResolutionPreset r) {
    switch (r) {
      case ResolutionPreset.medium:
        return "720p";
      case ResolutionPreset.high:
        return "1080p";
      case ResolutionPreset.veryHigh:
        return "4K";
      default:
        return "1080p";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuración")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== CÁMARA =====
            DropdownButtonFormField<CameraDescription>(
              value: selectedCamera,
              items: usableCameras.map((cam) {
                return DropdownMenuItem(
                  value: cam,
                  child: Text(cameraLabel(cam)),
                );
              }).toList(),
              onChanged: (cam) => setState(() => selectedCamera = cam!),
              decoration: const InputDecoration(labelText: "Cámara"),
            ),

            const SizedBox(height: 16),

            // ===== RESOLUCIÓN =====
            DropdownButtonFormField<ResolutionPreset>(
              value: resolution,
              items: const [
                DropdownMenuItem(
                  value: ResolutionPreset.medium,
                  child: Text("720p"),
                ),
                DropdownMenuItem(
                  value: ResolutionPreset.high,
                  child: Text("1080p"),
                ),
                DropdownMenuItem(
                  value: ResolutionPreset.veryHigh,
                  child: Text("4K"),
                ),
              ],
              onChanged: (r) => setState(() => resolution = r!),
              decoration: const InputDecoration(labelText: "Resolución"),
            ),

            const SizedBox(height: 16),

            // ===== DURACIÓN =====
            TextFormField(
              initialValue: "10",
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Duración (segundos)"),
              onChanged: (v) {
                final parsed = int.tryParse(v);
                duration = parsed != null && parsed > 0 ? parsed : 10;
              },
            ),

            const SizedBox(height: 16),

            // ===== DELAY =====
            TextFormField(
              initialValue: "3",
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Delay (segundos)"),
              onChanged: (v) {
                final parsed = int.tryParse(v);
                delay = parsed != null && parsed >= 0 ? parsed : 3;
              },
            ),

            const Spacer(),

            // ===== ABRIR CÁMARA =====
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CameraScreen(
                      camera: selectedCamera,
                      resolution: resolution,
                      duration: duration,
                      delay: delay,
                    ),
                  ),
                );
              },
              child: const Text(
                "Abrir cámara",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
