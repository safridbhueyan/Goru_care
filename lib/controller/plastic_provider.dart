import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

class PlasticProvider extends ChangeNotifier {
  bool _isRecording = false;
  final Map<String, int> _counts = {}; // current / last frame counts
  List<YOLOResult> _lastResults = []; // for future extensions

  bool get isRecording => _isRecording;
  Map<String, int> get counts => Map.from(_counts);
  int get totalPlastics => _counts.values.fold(0, (sum, v) => sum + v);

  void toggleRecording() {
    _isRecording = !_isRecording;
    if (!_isRecording) {
      // When stopping, keep the last counts as summary
    }
    notifyListeners();
  }

  void updateResults(List<YOLOResult> results) {
    if (!_isRecording) return;

    _counts.clear();
    for (final result in results) {
      final name = result.className ?? 'Unknown';
      _counts[name] = (_counts[name] ?? 0) + 1;
    }
    _lastResults = results;
    notifyListeners();
  }

  void resetCounts() {
    _counts.clear();
    _lastResults.clear();
    notifyListeners();
  }
}
