import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../controller/detectorProvider.dart'; // Ensure this path is correct

class DetectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DetectionProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview (Full Screen)
          if (provider.isInitialized && provider.controller != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: provider.controller!.value.previewSize?.height ?? 1,
                  height: provider.controller!.value.previewSize?.width ?? 1,
                  child: CameraPreview(provider.controller!),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // 2. Detection Overlay
          if (provider.isInitialized && provider.recognitions.isNotEmpty)
            _buildDetectionOverlay(provider, context),

          // 3. Freeze Frame / Detection Indicator
          if (provider.recognitions.any((r) => r.score > 0.85))
            Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red.withOpacity(0.6),
                  child: const Text(
                    "PERSON DETECTED!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // 4. Action Button (Start/Stop)
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                onPressed: () => provider.startDetection(), // Or toggle logic
                label: const Text("SCANNING"),
                icon: const Icon(Icons.center_focus_strong),
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionOverlay(
    DetectionProvider provider,
    BuildContext context,
  ) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: provider.recognitions.map<Widget>((recognition) {
        return Positioned(
          top: size.height * 0.1, // Show at 10% from top
          left: size.width * 0.1,
          right: size.width * 0.1,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  "MATCH: ${recognition.label.toUpperCase()}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Confidence: ${(recognition.score * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
