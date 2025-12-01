// Stub implementation for Camera package on web
Future<List<CameraDescription>> availableCameras() async => [];

class CameraController {
  CameraController(
    this.description,
    this.resolutionPreset, {
    this.enableAudio = false,
  });

  final CameraDescription description;
  final ResolutionPreset resolutionPreset;
  final bool enableAudio;

  Future<void> initialize() async {}
  Future<XFile> takePicture() async => XFile('');
  void dispose() {}

  CameraValue get value => CameraValue(
    isInitialized: false,
    previewSize: null,
  );
}

class CameraDescription {
  CameraDescription({
    required this.name,
    required this.lensDirection,
    required this.sensorOrientation,
  });

  final String name;
  final CameraLensDirection lensDirection;
  final int sensorOrientation;
}

enum CameraLensDirection {
  front,
  back,
  external,
}

enum ResolutionPreset {
  low,
  medium,
  high,
  veryHigh,
  ultraHigh,
  max,
}

class CameraValue {
  CameraValue({
    required this.isInitialized,
    required this.previewSize,
  });

  final bool isInitialized;
  final dynamic previewSize;
}

class XFile {
  XFile(this.path);
  final String path;
}