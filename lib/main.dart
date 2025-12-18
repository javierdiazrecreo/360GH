import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MaterialApp(home: Control360(cameras: cameras)));
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

  // Ajusta estas IPs a la de tu motor Shelly/Tuya/Arduino
  final String urlEncender = "http://192.168.1.100/relay/0?turn=on";
  final String urlApagar = "http://192.168.1.100/relay/0?turn=off";

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    _controller.initialize().then((_) => setState(() {}));
  }

  Future<void> ejecutarCiclo() async {
    try {
      setState(() => procesando = true);
      
      // 1. Iniciar grabación
      await _controller.startVideoRecording();
      // 2. Activar motor
      await http.get(Uri.parse(urlEncender)).timeout(const Duration(seconds: 2));
      
      // 3. Esperar el giro (ejemplo 10 seg)
      await Future.delayed(const Duration(seconds: 10));
      
      // 4. Detener motor
      await http.get(Uri.parse(urlApagar)).timeout(const Duration(seconds: 2));
      // 5. Finalizar grabación
      XFile video = await _controller.stopVideoRecording();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Video guardado: ${video.path}"))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Verifique conexión Wi-Fi del motor"))
      );
    } finally {
      setState(() => procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: FloatingActionButton.extended(
                onPressed: procesando ? null : ejecutarCiclo,
                label: Text(procesando ? "PROCESANDO..." : "GIRAR Y GRABAR 360"),
                icon: const Icon(Icons.camera_outlined),
                backgroundColor: procesando ? Colors.grey : Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}