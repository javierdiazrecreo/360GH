import 'package:camera/camera.dart';

class RecordingConfig {
  final CameraDescription camera;
  final int durationSeconds;
  final int delaySeconds;
  final ResolutionPreset resolution;
  final bool audio;

  RecordingConfig({
    required this.camera,
    required this.durationSeconds,
    required this.delaySeconds,
    required this.resolution,
    required this.audio,
  });
}
