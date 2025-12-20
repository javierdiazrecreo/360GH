import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'preview_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(Party360App(cameras: cameras));
}

class Party360App extends StatelessWidget {
  final List<CameraDescription> cameras;
  const Party360App({super.key, required this.cameras});

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

/* ---------------- CONFIGURACIÓN ---------------- */

class ConfigScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ConfigScreen({super.key, required this.cameras});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _ipController = TextEditingController(text: "192.168.1.100");
  final _timeController = TextEditingController(text: "10");
  final _delayController = TextEditingController(text: "3");

  ResolutionPreset _resolution = ResolutionPreset.high;
  int _cameraIndex = 0;
  bool _audio = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("360Party – Configuración")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(
            controller: _ipController,
            decoration: const InputDecoration(
              labelText: "IP Motor",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _timeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Duración video (seg)",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _delayController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Delay inicio (seg)",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 15),
          SwitchListTile(
            title: const Text("Grabar audio"),
            value: _audio,
            onChanged: (v) => setState(() => _audio = v),
          ),
          DropdownButtonFormField<int>(
            value: _cameraIndex,
            decoration: const InputDecoration(
              labelText: "Cámara",
              border: OutlineInputBorder(),
            ),
            items: List.generate(
              widget.cameras.length,
              (i) => DropdownMenuItem(
                value: i,
                child: Text(
                  widget.cameras[i].lensDirection == CameraLensDirection.back
                      ? "Trasera"
                      : "Frontal",
                ),
              ),
            ),
            onChanged: (v) => setState(() => _cameraIndex = v!),
          ),
          const SizedBox(height: 15),
          DropdownButtonFormField<ResolutionPreset>(
            value: _resolution,
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
            onChanged: (v) => setState(() => _resolution = v!),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CameraScreen(
                    cameras: widget.cameras,
                    cameraIndex: _cameraIndex,
                    ip: _ipController.text,
                    seconds: int.parse(_timeController.text),
                    delay: int.parse(_delayController.text),
                    resolution: _resolution,
                    audio: _audio,
                  ),
                ),
              );
            },
            child: const Text("INICIAR CÁMARA"),
          )
        ]),
      ),
    );
  }
}

/* ---------------- CÁMARA ---------------- */

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final int cameraIndex;
  final String ip;
  final int seconds;
  final int delay;
  final ResolutionPreset resolution;
  final bool audio;

  const CameraScreen({
    super.key,
    required this.cameras,
    required this.cameraIndex,
    required this.ip,
    required this.seconds,
    required this.delay,
    required this.resolution,
    required this.audio,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool recording = false;
  int countdown = 0;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras[widget.cameraIndex],
      widget.resolution,
      enableAudio: widget.audio,
    );
    _controller.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> startCycle() async {
    setState(() => recording = true);

    for (int i = widget.delay; i > 0; i--) {
      setState(() => countdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    await http.get(Uri.parse("http://${widget.ip}/relay/0?turn=on"));
    await _controller.startVideoRecording();

    await Future.delayed(Duration(seconds: widget.seconds));
    final file = await _controller.stopVideoRecording();

    await http.get(Uri.parse("http://${widget.ip}/relay/0?turn=off"));

    final now = DateFormat("yyyy-MM-dd_HH-mm-ss").format(DateTime.now());
    final dir = Directory("/storage/emulated/0/Movies/360Party");
    if (!dir.existsSync()) dir.createSync(recursive: true);

    final newPath = "${dir.path}/360Party_$now.mp4";
    await File(file.path).copy(newPath);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewScreen(videoPath: newPath, onDone: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CameraScreen(
                cameras: widget.cameras,
                cameraIndex: widget.cameraIndex,
                ip: widget.ip,
                seconds: widget.seconds,
                delay: widget.delay,
                resolution: widget.resolution,
                audio: widget.audio,
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(children: [
        CameraPreview(_controller),
        if (countdown > 0)
          Center(
            child: Text(
              "$countdown",
              style: const TextStyle(fontSize: 120),
            ),
          ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton.extended(
              onPressed: recording ? null : startCycle,
              label: Text(recording ? "GRABANDO..." : "INICIAR 360"),
              icon: const Icon(Icons.videocam),
            ),
          ),
        ),
        Positioned(
          top: 40,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ConfigScreen(cameras: widget.cameras),
                ),
              );
            },
          ),
        )
      ]),
    );
  }
}
