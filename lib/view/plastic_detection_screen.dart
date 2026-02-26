import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

class PlasticDetectorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: YOLOView(
        modelPath: 'assets/best_float32.tflite', // Path to your tflite file
        task: YOLOTask.detect,
        onResult: (results) {
          // This prints the detected plastic types to your console
          for (final result in results) {
            print(
              'Detected ${result.className} (${(result.confidence * 100).toStringAsFixed(1)}%)',
            );
          }
        },
      ),
    );
  }
}
