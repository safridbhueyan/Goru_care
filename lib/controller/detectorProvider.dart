import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:goru_care/model%20/recognation.dart';
import 'package:tflite_v2/tflite_v2.dart';

class DetectionProvider extends ChangeNotifier {
  CameraController? controller;
  List<Recognition> recognitions = [];
  bool isInitialized = false;
  bool isDetecting = false;
  bool _isProcessing = false;

  final List<String> labels = ["kishu", "niloy", "mitul", "hafsa", "sam"];

  DetectionProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      // 1. Load Model simply
      await Tflite.loadModel(
        model: "assets/models/model.tflite",
        labels: "assets/models/labels.txt",
        numThreads: 4,
        isAsset: true,
      );

      // 2. Setup Camera
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        controller = CameraController(
          cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await controller!.initialize();
        isInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Init Error: $e");
    }
  }

  void startDetection() {
    if (controller == null || !isInitialized) return;
    isDetecting = true;
    notifyListeners();

    controller!.startImageStream((CameraImage image) async {
      if (!isDetecting || _isProcessing) return;
      _isProcessing = true;

      try {
        // TFLite_v2 handles YUV to RGB and Rotation internally!
        var predictions = await Tflite.runModelOnFrame(
          bytesList: image.planes.map((plane) => plane.bytes).toList(),
          imageHeight: image.height,
          imageWidth: image.width,
          imageMean: 127.5, // Standard normalization
          imageStd: 127.5,
          rotation: 90, // Automatic rotation for Portrait
          numResults: 1, // Just give us the top match
          threshold: 0.4, // Confidence threshold
        );

        if (predictions != null && predictions.isNotEmpty) {
          _processV2Results(predictions);
        } else {
          recognitions = [];
        }
        notifyListeners();
      } catch (e) {
        debugPrint("Inference error: $e");
      } finally {
        _isProcessing = false;
      }
    });
  }

  void _processV2Results(List<dynamic> predictions) {
    List<Recognition> results = [];
    for (var res in predictions) {
      results.add(
        Recognition(
          id: res["index"],
          label: res["label"],
          score: res["confidence"],
          location: const Rect.fromLTWH(0.1, 0.1, 0.8, 0.1),
        ),
      );
    }
    recognitions = results;
  }

  void stopDetection() {
    isDetecting = false;
    controller?.stopImageStream();
    recognitions = [];
    notifyListeners();
  }

  @override
  void dispose() {
    Tflite.close();
    controller?.dispose();
    super.dispose();
  }
}
