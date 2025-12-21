import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'preview_screen.dart';
import 'tuya_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.redAccent,
        useMaterial3: true,
      ),
      home: ConfigScreen(cameras: cameras),
    );
  }
}

/* =========================
   CONFIGURACIÓN INICIAL
========================= */

class ConfigScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ConfigScreen({super.key, required this.cameras});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _duracionCtrl = TextEditingController(text: "10");
  final _delayCtrl = TextEditingController(text: "3");

  ResolutionPreset _resolucion = ResolutionPreset.high;
  int _cameraIndex = 0;
  bool _audio = true;
  bool _usarSensor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("360Party – Configuración")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              color: Colors.black54,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Motor Tuya vinculado ✔",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _duracionCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Duración (seg)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _delayCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Delay (seg)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("Grabar audio"),
              value: _audio,
              onChanged: (v) => setState(() => _audio = v),
            ),
            SwitchListTile(
              title: const Text("Iniciar con movimiento"),
              subtitle: const Text("Detección por acelerómetro"),
              value: _usarSensor,
              onChanged: (v) => setState(() => _usarSensor = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _cameraIndex,
              decoration: const InputDecoration(
                labelText: "Cámara",
                border: OutlineInputBorder(),
              ),
              items: List.generate(widget.cameras.length, (i) {
                final cam = widget.cameras[i];
                return DropdownMenuItem(
                  value: i,
                  child: Text(
                    cam.lensDirection == CameraLensDirection.back
                        ? "Trasera"
                        : "Frontal",
                  ),
                );
              }),
              onChanged: (v) => setState(() => _cameraIndex = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ResolutionPreset>(
              value: _resolucion,
              decoration: const InputDecoration(
                labelText: "Resolución",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                    value: ResolutionPreset.medium, child: Text("720p")),
                DropdownMenuItem(
                    value: ResolutionPreset.high, child: Text("1080p")),
                DropdownMenuItem(
                    value: ResolutionPreset.ultraHigh, child: Text("4K")),
              ],
              onChanged: (v) => setState(() => _resolucion = v!),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CameraScreen(
                      camera: widget.cameras[_cameraIndex],
                      duracion: int.parse(_duracionCtrl.text),
                      delay: int.parse(_delayCtrl.text),
                      resolucion: _resolucion,
                      audio: _audio,
                      usarSensor: _usarSensor,
                    ),
                  ),
                );
              },
              child: const Text("ABRIR CÁMARA"),
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================
   PANTALLA DE CÁMARA
========================= */

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final int duracion;
  final int delay;
  final ResolutionPreset resolucion;
  final bool audio;
  final bool usarSensor;

  const CameraScreen({
    super.key,
    required this.camera,
    required this.duracion,
    required this.delay,
    required this.resolucion,
    required this.audio,
    required this.usarSensor,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool grabando = false;
  int countdown = 0;
  StreamSubscription? _sensorSub;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      widget.resolucion,
      enableAudio: widget.audio,
    );

    _controller.initialize().then((_) {
      if (mounted) setState(() {});
    });

    if (widget.usarSensor) {
      _escucharSensor();
    }
  }

  void _escucharSensor() {
    _sensorSub = accelerometerEvents.listen((event) {
      if (grabando) return;
      final g = event.x.abs() + event.y.abs() + event.z.abs();
      if (g > 12.8) {
        _sensorSub?.cancel();
        iniciarProceso();
      }
    });
  }

  Future<void> iniciarProceso() async {
    if (grabando) return;
    setState(() => grabando = true);

    if (!widget.usarSensor) {
      for (int i = widget.delay; i > 0; i--) {
        setState(() => countdown = i);
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    setState(() => countdown = 0);

    // 🔥 MOTOR ON
    await TuyaService.setMotor(true);
    await Future.delayed(const Duration(milliseconds: 500));

    await _controller.startVideoRecording();
    await Future.delayed(Duration(seconds: widget.duracion));
    final video = await _controller.stopVideoRecording();

    // 🔥 MOTOR OFF
    await TuyaService.setMotor(false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewScreen(videoPath: video.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller),
          if (widget.usarSensor && !grabando)
            const Center(
              child: Card(
                color: Colors.black54,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "ESPERANDO GIRO DEL MOTOR...",
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          if (countdown > 0)
            Center(
              child: Text(
                "$countdown",
                style: const TextStyle(
                  fontSize: 160,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                backgroundColor: grabando ? Colors.grey : Colors.red,
                onPressed:
                    (grabando || widget.usarSensor) ? null : iniciarProceso,
                icon: const Icon(Icons.videocam),
                label: Text(
                  grabando
                      ? "GRABANDO..."
                      : widget.usarSensor
                          ? "MODO SENSOR"
                          : "INICIAR 360",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sensorSub?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
