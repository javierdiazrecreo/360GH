import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart'; // Necesitas agregar: flutter pub add crypto
import 'preview_screen.dart';

// --- CONFIGURACIÓN DE TUYA (PRO) ---
const String TUYA_ACCESS_ID = "53sspeuskqxsxfcda4x8";
// >>> COPIA TU CLIENT SECRET AQUÍ ABAJO <<<
const String TUYA_ACCESS_SECRET = "b99e9c80b78045f5ab200a5d4114ac25"; 
const String TUYA_DEVICE_ID = "eb6851ea60756b1e79clcs"; // Tu motor actual
const String TUYA_BASE_URL = "https://openapi.tuyaus.com";

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

class ConfigScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ConfigScreen({super.key, required this.cameras});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _timerController = TextEditingController(text: "10");
  final _delayController = TextEditingController(text: "3");

  ResolutionPreset _resolucion = ResolutionPreset.high;
  int _cameraIndex = 0;
  bool _audio = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("360Party – Configuración Pro")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Motor Tuya vinculado: eb68...lcs", 
                  style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _timerController,
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
                    controller: _delayController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Delay",
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
                  child: Text(cam.lensDirection == CameraLensDirection.back ? "Trasera" : "Frontal"),
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
                DropdownMenuItem(value: ResolutionPreset.medium, child: Text("720p")),
                DropdownMenuItem(value: ResolutionPreset.high, child: Text("1080p")),
                DropdownMenuItem(value: ResolutionPreset.ultraHigh, child: Text("4K")),
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
                      segundos: int.parse(_timerController.text),
                      delay: int.parse(_delayController.text),
                      resolucion: _resolucion,
                      audio: _audio,
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

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final int segundos;
  final int delay;
  final ResolutionPreset resolucion;
  final bool audio;

  const CameraScreen({
    super.key,
    required this.camera,
    required this.segundos,
    required this.delay,
    required this.resolucion,
    required this.audio,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool grabando = false;
  int countdown = 0;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, widget.resolucion, enableAudio: widget.audio);
    _controller.initialize().then((_) { if (mounted) setState(() {}); });
  }

  // --- LÓGICA DE CONTROL DE MOTOR TUYA ---
Future<void> enviarComandoTuya(bool encender) async {
  try {
    final String t = DateTime.now().millisecondsSinceEpoch.toString();
    const String method = "POST";
    const String urlPath = "/v1.0/devices/$TUYA_DEVICE_ID/commands";
    
    // El cuerpo debe ser exacto
    final body = jsonEncode({
      "commands": [
        {"code": "switch_1", "value": encender}
      ]
    });

    // --- CÁLCULO DE FIRMA OFICIAL TUYA ---
    final contentHash = sha256.convert(utf8.encode(body)).toString();
    // Importante: El orden de los strings en el cálculo de la firma es vital
    final stringToSign = "$method\n$contentHash\n\n$urlPath";
    final signStr = TUYA_ACCESS_ID + t + stringToSign;
    
    final key = utf8.encode(TUYA_ACCESS_SECRET);
    final hmac = Hmac(sha256, key);
    final sign = hmac.convert(utf8.encode(signStr)).toString().toUpperCase();

    final response = await http.post(
      Uri.parse(TUYA_BASE_URL + urlPath),
      headers: {
        'client_id': TUYA_ACCESS_ID,
        'sign': sign,
        't': t,
        'sign_method': 'HMAC-SHA256',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    // ESTO ES CLAVE: Mira la consola de VS Code cuando presiones el botón
    print("Respuesta de Tuya: ${response.body}");
    
  } catch (e) {
    print("Error de conexión: $e");
  }
}

  Future<void> iniciarProceso() async {
    if (grabando) return;
    setState(() => grabando = true);

    for (int i = widget.delay; i > 0; i--) {
      setState(() => countdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() => countdown = 0);
    
    // 1. Encender Motor vía Nube
    await enviarComandoTuya(true);
    await Future.delayed(const Duration(milliseconds: 500));

    // 2. Iniciar Grabación
    await _controller.startVideoRecording();
    await Future.delayed(Duration(seconds: widget.segundos));
    
    // 3. Detener Grabación
    final video = await _controller.stopVideoRecording();

    // 4. Apagar Motor vía Nube
    await enviarComandoTuya(false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PreviewScreen(videoPath: video.path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller),
          if (countdown > 0)
            Center(child: Text("$countdown", style: const TextStyle(fontSize: 160, color: Colors.white, fontWeight: FontWeight.bold))),
          Positioned(
            bottom: 40, left: 0, right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                backgroundColor: grabando ? Colors.grey : Colors.red,
                onPressed: grabando ? null : iniciarProceso,
                label: Text(grabando ? "GRABANDO..." : "INICIAR 360"),
                icon: const Icon(Icons.videocam),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}