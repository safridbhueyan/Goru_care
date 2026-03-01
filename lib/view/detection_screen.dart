import 'package:flutter/material.dart';
import 'package:goru_care/controller/plastic_provider.dart';
import 'package:provider/provider.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:permission_handler/permission_handler.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    await Permission.camera.request();
  }

  final List<String> _allLabels = [
    'HDPE Plastic',
    'Multi-layer Plastic',
    'PET Bottle',
    'Single-Use-Plastic',
    'Single-layer Plastic',
    'Squeeze-Tube',
    'UHT-Box',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plastic Detector'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PlasticProvider>().resetCounts(),
            tooltip: 'Reset counts',
          ),
        ],
      ),
      body: Consumer<PlasticProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Camera / Detection Area
              Expanded(
                flex: 3,
                child: provider.isRecording
                    ? YOLOView(
                        modelPath:
                            'plastic.tflite', // ← this exact string, no 'assets/', no 'models/'
                        task: YOLOTask.detect,
                        cameraResolution: '480', // keep low-res for better FPS
                        useGpu: true,
                        confidenceThreshold:
                            0.35, // lower a bit if weak detections (0.25–0.4 range)
                        iouThreshold: 0.45,
                        showOverlays: true,
                        lensFacing: LensFacing.back,
                        onResult: (List<YOLOResult> results) {
                          provider.updateResults(results);
                          // Debug print to see what's happening
                          if (results.isNotEmpty) {
                            debugPrint('DETECTIONS (${results.length}):');
                            for (var r in results) {
                              debugPrint(
                                '  → ${r.className} | conf: ${r.confidence?.toStringAsFixed(2)} | box: ${r.boundingBox}',
                              );
                            }
                          } else {
                            debugPrint('No detections this frame');
                          }
                        },
                      )
                    : Container(
                        color: Colors.black12,
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Recording OFF\nTap Start to begin live detection',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),

              // Live Counts / Summary Panel
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Detection Summary',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Total: ${provider.totalPlastics}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: provider.counts.isEmpty
                            ? const Center(
                                child: Text('No plastics detected yet'),
                              )
                            : ListView.builder(
                                itemCount: _allLabels.length,
                                itemBuilder: (context, index) {
                                  final label = _allLabels[index];
                                  final count = provider.counts[label] ?? 0;
                                  return ListTile(
                                    title: Text(
                                      label,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: count > 0
                                            ? Colors.green
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '$count',
                                        style: TextStyle(
                                          color: count > 0
                                              ? Colors.white
                                              : Colors.black54,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<PlasticProvider>(
        builder: (context, provider, _) => FloatingActionButton.extended(
          onPressed: provider.toggleRecording,
          label: Text(
            provider.isRecording ? 'STOP Recording' : 'START Recording',
          ),
          icon: Icon(provider.isRecording ? Icons.stop : Icons.play_arrow),
          backgroundColor: provider.isRecording ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}
