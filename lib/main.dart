import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'preview_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.dark, colorSchemeSeed: Colors.redAccent),
    home: ConfigScreen(cameras: cameras),
  ));
}

class ConfigScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ConfigScreen({super.key, required this.cameras});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _timerController = TextEditingController(text: "10");
  final _ipController = TextEditingController(text: "192.168.1.100");
  final _delayController = TextEditingController(text: "3");
  
  ResolutionPreset _resolucion = ResolutionPreset.high;
  int _selectedCameraIndex = 0; // 0 suele ser trasera, 1 frontal

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuración 360 Pro")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            TextField(controller: _ipController, decoration: const InputDecoration(labelText: "IP Shelly Motor", prefixIcon: Icon(Icons.lan))),
            const SizedBox(height: 15),
            Row(children: [
              Expanded(child: TextField(controller: _timerController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Duración Video (s)", prefixIcon: Icon(Icons.timer)))),
              const SizedBox(width: 15),
              Expanded(child: TextField(controller: _delayController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Delay Inicio (s)", prefixIcon: Icon(Icons.hourglass_top)))),
            ]),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              value: _selectedCameraIndex,
              decoration: const InputDecoration(labelText: "Seleccionar Cámara", prefixIcon: Icon(Icons.camera_front)),
              items: List.generate(widget.cameras.length, (i) => DropdownMenuItem(value: i, child: Text("Cámara ${i == 0 ? 'Trasera' : 'Frontal/Secundaria'}"))),
              onChanged: (val) => setState(() => _selectedCameraIndex = val!),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<ResolutionPreset>(
              value: _resolucion,
              decoration: const InputDecoration(labelText: "Calidad de Video", prefixIcon: Icon(Icons.hd)),
              items: const [
                DropdownMenuItem(value: ResolutionPreset.medium, child: Text("720p (Normal)")),
                DropdownMenuItem(value: ResolutionPreset.high, child: Text("1080p (Alta)")),
                DropdownMenuItem(value: ResolutionPreset.ultraHigh, child: Text("4K (Ultra)")),
              ],
              onChanged: (val) => setState(() => _resolucion = val!),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60), backgroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CameraScreen(
                  camera: widget.cameras[_selectedCameraIndex],
                  segundos: int.tryParse(_timerController.text) ?? 10,
                  delay: int.tryParse(_delayController.text) ?? 3,
                  ipMotor: _ipController.text,
                  resolucion: _resolucion,
                )));
              },
              child: const Text("INICIAR SISTEMA", style: TextStyle(color: Colors.white, fontSize: 18)),
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
  final String ipMotor;
  final ResolutionPreset resolucion;

  const CameraScreen({super.key, required this.camera, required this.segundos, required this.delay, required this.ipMotor, required this.resolucion});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool procesando = false;
  int countdown = 0;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, widget.resolucion, enableAudio: true);
    _controller.initialize().then((_) { if (mounted) setState(() {}); });
  }

  Future<void> ejecutarCiclo() async {
    setState(() => procesando = true);
    
    // 1. Cuenta atrás
    for (int i = widget.delay; i > 0; i--) {
      setState(() => countdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    setState(() => countdown = 0);

    // 2. Encender Motor e iniciar grabación
    try {
      http.get(Uri.parse("http://${widget.ipMotor}/relay/0?turn=on")).timeout(const Duration(milliseconds: 500));
    } catch (_) {}
    
    await Future.delayed(const Duration(milliseconds: 500)); // Delay técnico motor
    await _controller.startVideoRecording();

    // 3. Duración del video
    await Future.delayed(Duration(seconds: widget.segundos));

    // 4. Parar todo
    XFile video = await _controller.stopVideoRecording();
    try {
      http.get(Uri.parse("http://${widget.ipMotor}/relay/0?turn=off")).timeout(const Duration(milliseconds: 500));
    } catch (_) {}

    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => PreviewScreen(filePath: video.path),
      ));
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller),
          if (countdown > 0) Center(child: Text("$countdown", style: const TextStyle(fontSize: 150, fontWeight: FontWeight.bold, color: Colors.white))),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: FloatingActionButton.extended(
                backgroundColor: procesando ? Colors.grey : Colors.red,
                onPressed: procesando ? null : ejecutarCiclo,
                label: Text(procesando ? "GRABANDO..." : "INICIAR 360"),
                icon: const Icon(Icons.videocam),
              ),
            ),
          )
        ],
      ),
    );
  }
}