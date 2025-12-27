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
        .where(
          (c) =>
              c.lensDirection == CameraLensDirection.back ||
              c.lensDirection == CameraLensDirection.front,
        )
        .toList();

    if (usableCameras.isEmpty) {
      usableCameras = widget.cameras;
    }
  }

  String cameraLabel(CameraDescription cam) {
    switch (cam.lensDirection) {
      case CameraLensDirection.back:
        return 'Trasera';
      case CameraLensDirection.front:
        return 'Frontal';
      default:
        return 'Otra';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (usableCameras.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No se detectaron cámaras'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ===== CÁMARA =====
            DropdownButtonFormField<int>(
              value: selectedCameraIndex,
              decoration: const InputDecoration(labelText: 'Cámara'),
              items: List.generate(
                usableCameras.length,
                (index) => DropdownMenuItem<int>(
                  value: index,
                  child: Text(cameraLabel(usableCameras[index])),
                ),
              ),
              onChanged: (index) {
                if (index != null) {
                  setState(() => selectedCameraIndex = index);
                }
              },
            ),

            const SizedBox(height: 16),

            // ===== RESOLUCIÓN =====
            DropdownButtonFormField<ResolutionPreset>(
              value: resolution,
              decoration: const InputDecoration(labelText: 'Resolución'),
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
                  value: ResolutionPreset.veryHigh,
                  child: Text('4K'),
                ),
              ],
              onChanged: (r) {
                if (r != null) {
                  setState(() => resolution = r);
                }
              },
            ),

            const SizedBox(height: 16),

            // ===== DURACIÓN =====
            TextFormField(
              initialValue: duration.toString(),
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Duración (segundos)'),
              onChanged: (v) {
                final parsed = int.tryParse(v);
                if (parsed != null && parsed > 0) {
                  duration = parsed;
                }
              },
            ),

            const SizedBox(height: 16),

            // ===== DELAY =====
            TextFormField(
              initialValue: delay.toString(),
              keyboardType: TextInputType.number,
              deco
