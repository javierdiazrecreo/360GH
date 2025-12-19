enum CameraSide { back, front }

class AppSettings {
  CameraSide cameraSide;
  ResolutionPreset resolution;
  bool recordAudio;
  int videoDurationSeconds;
  int motorDelayMs;
  String motorUrl;

  AppSettings({
    this.cameraSide = CameraSide.back,
    this.resolution = ResolutionPreset.high,
    this.recordAudio = false,
    this.videoDurationSeconds = 10,
    this.motorDelayMs = 500,
    this.motorUrl = "http://192.168.1.50/rotate",
  });
}
