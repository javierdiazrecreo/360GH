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

  ResolutionPreset resolution = ResolutionPreset.high;
  int duration = 10;
  int delay = 3;

  @override
  void initState() {
    super.initState();

    usableCameras = widget.cameras.where(
      (c) =>
          c.lensDirection == CameraLensDirection.back ||
          c.lensDirection == CameraLensDirection.front,
    ).toList();

    selectedCamera = usableCameras.first;
  }

  String cameraLabel(CameraDescription cam) {
    return cam.lensDirection == CameraLensDirection.back
        ? "Trasera"
        : "Frontal";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuración")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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

            const SizedBox(height: 12),

            DropdownButtonFormField<ResolutionPreset>(
              value: resolution,
              items: const [
                DropdownMenuItem(
                    value: ResolutionPreset.low, child: Text("Baja")),
                DropdownMenuItem(
                    value: ResolutionPreset.medium, child: Text("Media")),
                DropdownMenuItem(
                    value: ResolutionPreset.high, child: Text("Alta")),
              ],
              onChanged: (r) => setState(() => resolution = r!),
              decoration: const InputDecoration(labelText: "Resolución"),
            ),

            const SizedBox(height: 12),

            TextFormField(
              initialValue: "10",
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Duración (segundos)"),
              onChanged: (v) => duration = int.tryParse(v) ?? 10,
            ),

            const SizedBox(height: 12),

            TextFormField(
              initialValue: "3",
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Delay (segundos)"),
              onChanged: (v) => delay = int.tryParse(v) ?? 3,
            ),

            const Spacer(),

            ElevatedButton(
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
              child: const Text("Abrir cámara"),
            )
          ],
        ),
      ),
    );
  }
}
