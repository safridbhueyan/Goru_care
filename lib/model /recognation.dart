import 'package:flutter/material.dart';

class Recognition {
  final int id;
  final String label;
  final double score;
  final Rect location;

  Recognition({
    required this.id,
    required this.label,
    required this.score,
    required this.location,
  });
}
