import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SelfieCameraScreen extends StatefulWidget {
  const SelfieCameraScreen({Key? key}) : super(key: key);

  @override
  State<SelfieCameraScreen> createState() => _SelfieCameraScreenState();
}

class _SelfieCameraScreenState extends State<SelfieCameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    // Minta izin kamera
    var status = await Permission.camera.request();
    if (!mounted) return;
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin kamera diperlukan untuk selfie')),
      );
      return;
    }

    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller!.initialize();

    if (mounted) setState(() {});
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final image = await _controller!.takePicture();
    final directory = await getTemporaryDirectory();
    final filePath = path.join(directory.path, '${DateTime.now()}.jpg');

    // simpan file ke path baru
    final File savedImage = await File(image.path).copy(filePath);

    if (!mounted) return;
    Navigator.pop(context, savedImage);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          final bool cameraReady =
              snapshot.connectionState == ConnectionState.done &&
                  _controller != null;

          return Column(
            children: [
              const Spacer(flex: 1),

              // Area kamera (3/4 layar)
              Expanded(
                flex: 6,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: ClipRRect(
                      child: cameraReady
                          ? CameraPreview(_controller!)
                          : Container(
                              color: Colors.black,
                              child: const Center(
                                child: Text(
                                  "Menyiapkan kamera...",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              // Bagian bawah (seperti UI kamera HP)
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "PHOTO",
                      style: TextStyle(
                        color: Colors.amber.shade400,
                        fontSize: 16,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: cameraReady ? _takePicture : null,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 5,
                          ),
                          color: cameraReady ? Colors.white : Colors.white24,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.3),
                              blurRadius: 10,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
