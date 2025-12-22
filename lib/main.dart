import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'preview_screen.dart';
import 'tuya_service.dart';
import 'login_screen.dart';
import 'secrets.dart';

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
    CONFIGURACIÓN
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
  bool _conectado = false;
  String _motorName = "Sin motor seleccionado";

  void _irALogin() async {
    final String? code = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginTuyaScreen()),
    );

    if (code != null) {
      final success = await TuyaService.loginWithCode(code);
      if (success) {
        _mostrarSelectorMotores();
      } else {
        _showError("Error al validar credenciales con Tuya");
      }
    }
  }

  void _mostrarSelectorMotores() async {
    final dispositivos = await TuyaService.getDeviceList();
    
    if (!mounted) return;

    if (dispositivos.isEmpty) {
      _showError("No se encontraron dispositivos en tu cuenta.");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Selecciona tu Motor 360"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: dispositivos.length,
            itemBuilder: (context, index) {
              final dev = dispositivos[index];
              return ListTile(
                leading: Icon(Icons.settings_input_component, 
                  color: dev["online"] ? Colors.greenAccent : Colors.grey),
                title: Text(dev["name"]),
                subtitle: Text(dev["online"] ? "En línea" : "Desconectado"),
                onTap: () {
                  TuyaService.selectMotor(dev["id"]);
                  setState(() {
                    _conectado = true;
                    _motorName = dev["name"];
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("360Party – Business")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              color: _conectado ? Colors.black54 : Colors.red.withOpacity(0.15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(
                  _conectado ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: _conectado ? Colors.greenAccent : Colors.redAccent,
                  size: 30,
                ),
                title: Text(_conectado ? "Motor: $_motorName" : "Requiere Conexión"),
                subtitle: Text(_conectado ? "Listo para girar" : "Toca para vincular Smart Life"),
                onTap: _conectado ? _mostrarSelectorMotores : _irALogin,
                trailing: const Icon(Icons.swap_horiz, size: 20),
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
                minimumSize: const Size.fromHeight(58),
                backgroundColor: _conectado ? Colors.redAccent : Colors.grey[800],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: !_conectado ? null : () {
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
              child: Text(
                _conectado ? "ABRIR CÁMARA" : "CONECTA TUYA PRIMERO",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================
    CÁMARA
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
      _sensorSub = accelerometerEvents.listen((event) {
        if (grabando) return;
        final g = event.x.abs() + event.y.abs() + event.z.abs();
        if (g > 12.8) {
          _sensorSub?.cancel();
          iniciarProceso();
        }
      });
    }
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

    _show("Encendiendo motor…");
    try {
      await TuyaService.setMotor(true);
    } catch (_) {
      _show("⚠️ Motor no respondió");
    }

    await Future.delayed(const Duration(milliseconds: 500));
    await _controller.startVideoRecording();
    
    await Future.delayed(Duration(seconds: widget.duracion));

    final video = await _controller.stopVideoRecording();

    try {
      await TuyaService.setMotor(false);
    } catch (_) {
      _show("⚠️ Error al apagar motor");
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PreviewScreen(videoPath: video.path)),
    );
  }

  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller),
          if (countdown > 0)
            Center(
              child: Text("$countdown",
                style: const TextStyle(fontSize: 160, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                backgroundColor: grabando ? Colors.grey : Colors.red,
                onPressed: (grabando || widget.usarSensor) ? null : iniciarProceso,
                icon: const Icon(Icons.videocam),
                label: Text(grabando ? "GRABANDO..." : (widget.usarSensor ? "ESPERANDO GIRO..." : "INICIAR 360")),
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