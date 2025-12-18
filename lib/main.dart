import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'preview_screen.dart'; // Importante para conectar con el nuevo archivo

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
    home: Control360(cameras: cameras),
  ));
}

class Control360 extends StatefulWidget {
  final List<CameraDescription> cameras;
  const Control360({super.key, required this.cameras});

  @override
  State<Control360> createState() => _Control360State();
}

class _Control360State extends State<Control360> {
  late CameraController _controller;
  bool procesando = false;
  int indiceLente = 0;
  
  // Controlador para el tiempo de giro definido por el usuario
  final TextEditingController _timerController = TextEditingController(text: "10");

  // URLs de control del motor (ajustar según tu red local)
  final String urlEncender = "http://192.168.1.100/relay/0?turn=on";
  final String urlApagar = "http://192.168.1.100/relay/0?turn=off";

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
      debugPrint("Error al inicializar cámara: $e");
    }
  }

  // Permite saltar entre los lentes disponibles (1x, 0.5x, Frontal, etc.)
  Future<void> cambiarLente() async {
    setState(() => procesando = true);
    indiceLente = (indiceLente + 1) % widget.cameras.length;
    await _controller.dispose();
    await _inicializarCamara(widget.cameras[indiceLente]);
    setState(() => procesando = false);
  }

  Future<void> ejecutarCiclo() async {
    try {
      setState(() => procesando = true);
      int segundos = int.tryParse(_timerController.text) ?? 10;

      // 1. Iniciar grabación de video
      await _controller.startVideoRecording();
      
      // 2. Encender motor (con manejo de error por si falla el Wi-Fi)
      try {
        await http.get(Uri.parse(urlEncender)).timeout(const Duration(seconds: 2));
      } catch (e) {
        debugPrint("Motor no detectado al iniciar");
      }
      
      // 3. Esperar el tiempo de giro configurado
      await Future.delayed(Duration(seconds: segundos));
      
      // 4. Detener motor
      try {
        await http.get(Uri.parse(urlApagar)).timeout(const Duration(seconds: 2));
      } catch (e) {
        debugPrint("Motor no detectado al detener");
      }

      // 5. Finalizar grabación y capturar el archivo
      XFile video = await _controller.stopVideoRecording();
      
      // 6. NAVEGACIÓN: Ir a la pantalla de Vista Previa
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewScreen(filePath: video.path),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error durante el ciclo de grabación")),
      );
    } finally {
      setState(() => procesando = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timerController.dispose();
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
          // Vista completa de la cámara
          SizedBox.expand(child: CameraPreview(_controller)),
          
          // CAPA SUPERIOR: Panel de configuración
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ajuste de segundos
                Container(
                  width: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _timerController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      labelText: "Segundos",
                      labelStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                // Botón cambiar lente (0.5x, 1x)
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.flip_camera_android, color: Colors.black),
                    onPressed: procesando ? null : cambiarLente,
                  ),
                ),
              ],
            ),
          ),

          // CAPA INFERIOR: Botón de acción
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: FloatingActionButton.extended(
                onPressed: procesando ? null : ejecutarCiclo,
                label: Text(procesando ? "GRABANDO..." : "GRABAR 360"),
                icon: Icon(procesando ? Icons.stop_circle : Icons.videocam),
                backgroundColor: procesando ? Colors.grey : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}