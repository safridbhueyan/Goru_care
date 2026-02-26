import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PlasticVisionApp(cameras: cameras),
    ),
  );
}

class PlasticVisionApp extends StatefulWidget {
  final List<CameraDescription> cameras;
  const PlasticVisionApp({super.key, required this.cameras});

  @override
  State<PlasticVisionApp> createState() => _PlasticVisionAppState();
}

class _PlasticVisionAppState extends State<PlasticVisionApp> {
  late CameraController controller;
  late FlutterVision vision;
  List<Map<String, dynamic>> yoloResults = [];
  Map<String, int> plasticCounts = {};
  bool isLoaded = false;
  bool isDetecting = false;

  // Shortform Label Map for the UI
  final Map<String, String> shortLabels = {
    'HDPE Plastic': 'HDPE',
    'Multi-layer Plastic': 'MLP',
    'PET Bottle': 'PET',
    'Single-Use-Plastic': 'SUP',
    'Single-layer Plastic': 'SLP',
    'Squeeze-Tube': 'TUBE',
    'UHT-Box': 'UHT',
  };

  @override
  void initState() {
    super.initState();
    vision = FlutterVision();
    initCamera();
  }

  Future<void> initCamera() async {
    controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.veryHigh,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await controller.initialize();
    await vision.loadYoloModel(
      labels: 'assets/labels.txt',
      modelPath: 'assets/best_float32.tflite',
      modelVersion: "yolov8",
      numThreads: 4,
      useGpu: true,
    );
    setState(() => isLoaded = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final Size screen = MediaQuery.of(context).size;

    // Coordination Scaling (Adjusted for 90-degree rotation)
    double factorX = screen.width / 480;
    double factorY = screen.height / 720;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(controller)),

          // SHORTFORM BOUNDING BOXES
          ...yoloResults.map((res) {
            double left = res["box"][0] * factorX;
            double top = res["box"][1] * factorY;
            double width = (res["box"][2] - res["box"][0]) * factorX;
            double height = (res["box"][3] - res["box"][1]) * factorY;

            // Get short name or fallback to original
            String displayName = shortLabels[res["tag"]] ?? res["tag"];

            return Positioned(
              left: left.clamp(0, screen.width),
              top: top.clamp(0, screen.height),
              width: width,
              height: height,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -22,
                      left: -2,
                      child: Container(
                        color: Colors.greenAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Text(
                          "$displayName ${(res["box"][4] * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // LIVE TALLY (Top Left)
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "LIVE TALLY",
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  ...plasticCounts.entries.map((e) {
                    String shortName = shortLabels[e.key] ?? e.key;
                    return Text(
                      "$shortName: ${e.value}",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    );
                  }),
                ],
              ),
            ),
          ),

          // CONTROL BUTTONS
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.large(
                backgroundColor: isDetecting ? Colors.red : Colors.greenAccent,
                onPressed: isDetecting ? stopDetection : startDetection,
                child: Icon(
                  isDetecting ? Icons.stop : Icons.play_arrow,
                  size: 40,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> startDetection() async {
    setState(() => isDetecting = true);
    await controller.startImageStream((image) async {
      if (!isDetecting) return;
      final result = await vision.yoloOnFrame(
        bytesList: image.planes.map((p) => p.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        iouThreshold: 0.4,
        confThreshold: 0.25,
        classThreshold: 0.25,
      );
      if (result.isNotEmpty) _processResults(result);
    });
  }

  void stopDetection() async {
    setState(() => isDetecting = false);
    await controller.stopImageStream();
    setState(() => yoloResults = []);
  }

  void _processResults(List<Map<String, dynamic>> results) {
    Map<String, int> counts = {};
    for (var res in results) {
      counts[res["tag"]] = (counts[res["tag"]] ?? 0) + 1;
    }
    setState(() {
      yoloResults = results;
      plasticCounts = counts;
    });
  }
}
