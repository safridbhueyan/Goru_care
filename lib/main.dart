import 'package:flutter/material.dart';
import 'package:goru_care/controller/plastic_provider.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:goru_care/view/detection_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(
    ChangeNotifierProvider(
      create: (_) => PlasticProvider(), // ← this is what was missing
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DetectionScreen(), // pass cameras if needed
    );
  }
}
