import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
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
  
  bool _usarFlash = false;
  bool _usarGranAngular = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuración 360 Pro")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            TextField(controller: _ipController, decoration: const InputDecoration(labelText: "IP Shelly", prefixIcon: Icon(Icons.lan))),
            const SizedBox(height: 15),
            Row(children: [
              Expanded(child: TextField(controller: _timerController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Giro (seg)", prefixIcon: Icon(Icons.timer)))),
              const SizedBox(width: 15),
              Expanded(child: TextField(controller: _delayController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Delay (seg)", prefixIcon: Icon(Icons.hourglass_top)))),
            ]),
            const SizedBox(height: 15),
            SwitchListTile(
              title: const Text("Usar Lente Gran Angular (0.5x)"),
              subtitle: const Text("Ideal para videos 360"),
              value: _usarGranAngular, 
              onChanged: (val) => setState(() => _usarGranAngular = val),
            ),
            SwitchListTile(
              title: const Text("Activar Flash"),
              value: _usarFlash, 
              onChanged: (val) => setState(() => _usarFlash = val),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60), backgroundColor: Colors.redAccent),
              onPressed: () {
                // Buscamos la cámara adecuada
                CameraDescription selected = widget.cameras.first;
                if (_usarGranAngular) {
                  // Intentamos buscar una cámara que diga 'ultra wide' o simplemente la segunda trasera
                  selected = widget.cameras.firstWhere(
                    (c) => c.lensDirection == CameraLensDirection.back && c.name.toLowerCase().contains('ultra'),
                    orElse: () => widget.cameras.length > 1 ? widget.cameras[1] : widget.cameras.first
                  );
                }

                Navigator.push(context, MaterialPageRoute(builder: (context) => CameraScreen(
                  camera: selected,
                  segundos: int.tryParse(_timerController.text) ?? 10,
                  delay: int.tryParse(_delayController.text) ?? 3,
                  ipMotor: _ipController.text,
                  flash: _usarFlash,
                )));
              },
              child: const Text("IR A CÁMARA", style: TextStyle(color: Colors.white, fontSize: 18)),
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
  final bool flash;

  const CameraScreen({super.key, required this.camera, required this.segundos, required this.delay, required this.ipMotor, required this.flash});

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
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _controller.initialize().then((_) {
      if (widget.flash) _controller.setFlashMode(FlashMode.torch);
      if (mounted) setState(() {});
    });
  }

  Future<void> ejecutarCiclo() async {
    setState(() => procesando = true);
    
    // 1. Cuenta atrás (Delay)
    for (int i = widget.delay; i > 0; i--) {
      setState(() => countdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    setState(() => countdown = 0);

    // 2. Iniciar Grabación y Motor
    await _controller.startVideoRecording();
    try {
      http.get(Uri.parse("http://${widget.ipMotor}/relay/0?turn=on")).timeout(const Duration(milliseconds: 500));
    } catch (_) {}

    // 3. Tiempo de giro
    await Future.delayed(Duration(seconds: widget.segundos));

    // 4. Parar Motor y Grabación
    try {
      http.get(Uri.parse("http://${widget.ipMotor}/relay/0?turn=off")).timeout(const Duration(milliseconds: 500));
    } catch (_) {}
    
    XFile video = await _controller.stopVideoRecording();
    if (widget.flash) await _controller.setFlashMode(FlashMode.off);

    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => PreviewScreen(filePath: video.path),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller),
          if (countdown > 0) Center(child: Text("$countdown", style: const TextStyle(fontSize: 120, fontWeight: FontWeight.bold, color: Colors.white))),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: FloatingActionButton.extended(
                onPressed: procesando ? null : ejecutarCiclo,
                label: Text(procesando ? "GRABANDO..." : "EMPEZAR CICLO"),
                icon: const Icon(Icons.play_arrow),
              ),
            ),
          )
        ],
      ),
    );
  }
}