import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'preview_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.redAccent,
      brightness: Brightness.dark,
    ),
    home: ConfigScreen(cameras: cameras),
  ));
}

// --- PANTALLA INICIAL DE CONFIGURACIÓN ---
class ConfigScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ConfigScreen({super.key, required this.cameras});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final TextEditingController _timerController = TextEditingController(text: "10");
  final TextEditingController _ipController = TextEditingController(text: "192.168.1.100");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuración 360E")),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.settings_suggest, size: 80, color: Colors.redAccent),
            const SizedBox(height: 30),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: "IP del Motor (Shelly)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lan),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _timerController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Tiempo de giro (segundos)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraScreen(
                      cameras: widget.cameras,
                      segundos: int.tryParse(_timerController.text) ?? 10,
                      ipMotor: _ipController.text,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text("ABRIR CÁMARA", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PANTALLA DE CÁMARA Y GRABACIÓN ---
class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final int segundos;
  final String ipMotor;

  const CameraScreen({
    super.key,
    required this.cameras,
    required this.segundos,
    required this.ipMotor,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool procesando = false;
  int indiceLente = 0;

  @override
  void initState() {
    super.initState();
    _inicializarCamara(widget.cameras[indiceLente]);
  }

  Future<void> _inicializarCamara(CameraDescription cameraDescription) async {
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: true,
    );
    try {
      await _controller.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error cámara: $e");
    }
  }

  Future<void> ejecutarCiclo() async {
    try {
      setState(() => procesando = true);

      // 1. Iniciar grabación
      await _controller.startVideoRecording();

      // 2. Motor ON (Silencioso)
      try {
        final url = "http://${widget.ipMotor}/relay/0?turn=on";
        http.get(Uri.parse(url)).timeout(const Duration(milliseconds: 500));
      } catch (_) {}

      // 3. Esperar tiempo definido
      await Future.delayed(Duration(seconds: widget.segundos));

      // 4. Motor OFF (Silencioso)
      try {
        final url = "http://${widget.ipMotor}/relay/0?turn=off";
        http.get(Uri.parse(url)).timeout(const Duration(milliseconds: 500));
      } catch (_) {}

      // 5. Parar grabación e ir a Preview
      XFile video = await _controller.stopVideoRecording();
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewScreen(filePath: video.path),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error en ciclo: $e");
    } finally {
      setState(() => procesando = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(child: CameraPreview(_controller)),
          // Botón para volver a ajustes
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Botón para cambiar lente
          Positioned(
            top: 50,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.cached, color: Colors.white),
                onPressed: () async {
                  indiceLente = (indiceLente + 1) % widget.cameras.length;
                  await _controller.dispose();
                  _inicializarCamara(widget.cameras[indiceLente]);
                },
              ),
            ),
          ),
          // Botón principal
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: FloatingActionButton.extended(
                backgroundColor: procesando ? Colors.grey : Colors.red,
                onPressed: procesando ? null : ejecutarCiclo,
                label: Text(procesando ? "PROCESANDO..." : "GRABAR ${widget.segundos}s"),
                icon: const Icon(Icons.videocam),
              ),
            ),
          ),
        ],
      ),
    );
  }
}