import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:camera/camera.dart';
import 'package:vibration/vibration.dart';

class DetectionProvider extends ChangeNotifier {
  late FlutterVision vision;
  CameraController? controller;
  List<Map<String, dynamic>> detections = [];

  bool isLoaded = false;
  bool isDetecting = false;
  bool _isProcessing = false;
  bool isCapturing = false;

  DetectionProvider() {
    vision = FlutterVision();
    _init();
  }

  Future<void> _init() async {
    // 1. Load Model strictly on CPU to avoid ANR
    await vision.loadYoloModel(
      modelPath: 'assets/models/best_float32.tflite',
      labels: 'assets/models/labels.txt',
      modelVersion: "yolov8",
      numThreads: 6,
      useGpu: true,
    );

    // 2. Setup Camera at Low Res
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      controller = CameraController(
        cameras[0],
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );
      await controller!.initialize();
      isLoaded = true;
      notifyListeners();
    }
  }

  void toggleDetection() {
    isDetecting ? stopDetection() : startDetection();
  }

  void startDetection() {
    if (controller == null || !isLoaded) return;
    isDetecting = true;
    notifyListeners();

    controller!.startImageStream((CameraImage image) async {
      if (!isDetecting || _isProcessing || isCapturing) return;
      _isProcessing = true;

      final result = await vision.yoloOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        iouThreshold: 0.4,
        confThreshold: 0.6,
        classThreshold: 0.5,
      );

      if (result.isNotEmpty) {
        detections = result;
        // Freeze frame if someone like "safrid" or "niloy" is detected with high confidence
        if (result.any((d) => (d['box'][4] ?? 0) > 0.85)) {
          _triggerFreeze();
        }
        notifyListeners();
      }

      _isProcessing = false;
    });
  }

  Future<void> _triggerFreeze() async {
    isCapturing = true;
    notifyListeners();
    Vibration.vibrate(duration: 200);
    await Future.delayed(const Duration(seconds: 2));
    isCapturing = false;
    notifyListeners();
  }

  void stopDetection() {
    isDetecting = false;
    controller?.stopImageStream();
    detections = [];
    notifyListeners();
  }

  @override
  void dispose() {
    controller?.dispose();
    vision.closeYoloModel();
    super.dispose();
  }
}
