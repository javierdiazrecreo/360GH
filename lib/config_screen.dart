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
  List<CameraDescription> usableCameras = [];
  int selectedCameraIndex = 0;

  ResolutionPreset resolution = ResolutionPreset.high;
  int duration = 10;
  int delay = 3;

  @override
  void initState() {
    super.initState();

    usableCameras = widget.cameras
        .where((c) =>
            c.lensDirection == CameraLensDirection.back ||
            c.lensDirection == CameraLensDirection.front)
        .toList();

    if (usableCameras.isEmpty) {
      usableCameras = widget.cameras;
    }
  }

  String cameraLabel(CameraDescription cam) {
    switch (cam.lensDirection) {
      case CameraLensDirection.back:
        return "Trasera";
      case CameraLensDirection.front:
        return "Frontal";
      default:
        return "Otra";
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔴 GUARDA CRÍTICA
    if (usableCameras.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            "No se detectaron cámaras",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Configuración")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ===== CÁMARA =====
            DropdownButtonFormField<int>(
              value: selectedCameraIndex,
              items: List.generate(
                usableCameras.length,
                (index) => DropdownMenuItem(
                  value: index,
                  child: Text(cameraLabel(usableCameras[index])),
                ),
              ),
              onChanged: (index) {
                if (index != null) {
                  setState(() => selectedCameraIndex = index);
                }
              },
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
              onChanged: (r) {
                if (r != null) {
                  setState(() => resolution = r);
                }
              },
              decoration: const InputDecoration(labelText: "Resolución"),
            ),

            const SizedBox(height: 16),

            // ===== DURACIÓN =====
            TextFormField(
              initialValue: duration.toString(),
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Duración (segundos)"),
              onChanged: (v) {
                final parsed = int.tryParse(v);
                duration = parsed != null && parsed > 0 ? parsed : duration;
              },
            ),

            const SizedBox(height: 16),

            // ===== DELAY =====
            TextFormField(
              initialValue: delay.toString(),
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Delay (segundos)"),
              onChanged: (v) {
                final parsed = int.tryParse(v);
                delay = parsed != null && parsed >= 0 ? parsed : delay;
              },
            ),

            const SizedBox(height: 32),

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
                      camera: usableCameras[selectedCameraIndex],
                      resolution: resolution,
                      duration: duration,
                      delay: delay,
                    ),
                  ),
                );
              },
              child: const Text(
