import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../controller/detectorProvider.dart'; // Adjust path if needed

class DetectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Listen to changes in the provider
    final provider = Provider.of<DetectionProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview (Full Screen)
          if (provider.isLoaded && provider.controller != null)
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
          if (!provider.isCapturing && provider.isDetecting)
            _buildDetectionOverlay(provider, context),

          // 3. Freeze Frame Overlay (Visual Feedback)
          if (provider.isCapturing)
            Container(
              color: Colors.white.withOpacity(0.3),
              child: const Center(
                child: Text(
                  "PERSON DETECTED!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                  ),
                ),
              ),
            ),

          // 4. Start/Stop Button
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                onPressed: () => provider.toggleDetection(),
                label: Text(provider.isDetecting ? "STOP" : "START"),
                icon: Icon(
                  provider.isDetecting ? Icons.stop : Icons.play_arrow,
                ),
                backgroundColor: provider.isDetecting
                    ? Colors.red
                    : Colors.green,
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

    // Scaling logic: Camera frames are usually landscape, so we swap H/W
    final double factorX =
        size.width / (provider.controller!.value.previewSize?.height ?? 1);
    final double factorY =
        size.height / (provider.controller!.value.previewSize?.width ?? 1);

    return Stack(
      children: provider.detections.map((d) {
        final box = d['box']; // [x1, y1, x2, y2, confidence]
        return Positioned(
          left: box[0] * factorX,
          top: box[1] * factorY,
          width: (box[2] - box[0]) * factorX,
          height: (box[3] - box[1]) * factorY,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                color: Colors.greenAccent,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  "${d['tag']} ${(box[4] * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
