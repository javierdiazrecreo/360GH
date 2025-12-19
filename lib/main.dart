import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraController? _controller;

  /// ==== CONFIGURACIÓN ====
  CameraLensDirection cameraSide = CameraLensDirection.back;
  ResolutionPreset resolution = ResolutionPreset.high;
  bool recordAudio = false;
  int videoDurationSeconds = 10;
  int motorDelayMs = 500;
  String motorUrl = "http://192.168.1.50/rotate";

  bool isRecording = false;

  /// ==== INICIALIZAR CÁMARA ====
  Future<void> _initCamera() async {
    final selectedCamera = cameras.firstWhere(
      (c) => c.lensDirection == cameraSide,
    );

    _controller = CameraController(
      selectedCamera,
      resolution,
      enableAudio: recordAudio,
    );

    await _controller!.initialize();
  }

  /// ==== GRABACIÓN 360 ====
  Future<void> start360Capture() async {
    if (isRecording) return;

    setState(() => isRecording = true);

    try {
      await _initCamera();

      // Arranca el motor
      await http.get(Uri.parse(motorUrl));

      // Delay motor → grabación
      await Future.delayed(Duration(milliseconds: motorDelayMs));

      // Ruta + nombre automático
      final dir = await getExternalStorageDirectory();
      final filePath =
          "${dir!.path}/360_${DateTime.now().toIso8601String()}.mp4";

      await _controller!.startVideoRecording();
      await Future.delayed(Duration(seconds: videoDurationSeconds));
      final file = await _controller!.stopVideoRecording();

      // Guarda el archivo
      await File(file.path).copy(filePath);
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      await _controller?.dispose();
      _controller = null;
      setState(() => isRecording = false);
    }
  }

  /// ==== UI ====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App 360°")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Cámara frontal / trasera
            DropdownButton<CameraLensDirection>(
              value: cameraSide,
              items: const [
                DropdownMenuItem(
                  value: CameraLensDirection.back,
                  child: Text("Cámara trasera"),
                ),
                DropdownMenuItem(
                  value: CameraLensDirection.front,
                  child: Text("Cámara frontal"),
                ),
              ],
              onChanged: (v) => setState(() => cameraSide = v!),
            ),

            // Resolución
            DropdownButton<ResolutionPreset>(
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
                  child: Text("4K (si disponible)"),
                ),
              ],
              onChanged: (v) => setState(() => resolution = v!),
            ),

            // Audio
            SwitchListTile(
              title: const Text("Grabar audio"),
              value: recordAudio,
              onChanged: (v) => setState(() => recordAudio = v),
            ),

            const SizedBox(height: 20),

            // Botón principal
            ElevatedButton(
              onPressed: isRecording ? null : start360Capture,
              child: Text(isRecording ? "Grabando..." : "Iniciar 360°"),
            ),
          ],
        ),
      ),
    );
  }
}
