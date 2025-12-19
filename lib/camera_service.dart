import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'settings.dart';

class CameraService {
  CameraController? controller;

  Future<void> initCamera(AppSettings settings) async {
    final cameras = await availableCameras();

    final selectedCamera = cameras.firstWhere(
      (c) =>
          c.lensDirection ==
          (settings.cameraSide == CameraSide.back
              ? CameraLensDirection.back
              : CameraLensDirection.front),
    );

    controller = CameraController(
      selectedCamera,
      settings.resolution,
      enableAudio: settings.recordAudio,
    );

    await controller!.initialize();
  }

  Future<File> recordVideo(int seconds) async {
    final dir = await getExternalStorageDirectory();
    final filePath =
        "${dir!.path}/360_${DateTime.now().toIso8601String()}.mp4";

    await controller!.startVideoRecording();
    await Future.delayed(Duration(seconds: seconds));
    final file = await controller!.stopVideoRecording();

    return File(file.path);
  }

  void dispose() {
    controller?.dispose();
  }
}
