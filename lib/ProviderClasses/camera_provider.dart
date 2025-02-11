import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraProvider with ChangeNotifier {
  late CameraController _cameraController;
  bool _isInitialized = false;
  bool _isFlashOn = false;

  CameraController get cameraController => _cameraController;
  bool get isInitialized => _isInitialized;
  bool get isFlashOn => _isFlashOn;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception("No cameras available");
      }

      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
      );
      await _cameraController.initialize();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print("Failed to initialize camera: $e");
    }
  }

  Future<void> toggleFlash() async {
    if (!_isInitialized) return;

    try {
      _isFlashOn = !_isFlashOn;
      await _cameraController.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      notifyListeners();
    } catch (e) {
      print("Failed to toggle flash: $e");
    }
  }

  Future<void> takePicture() async {
    if (!_isInitialized) return;

    try {
      final image = await _cameraController.takePicture();
      print("Picture saved: ${image.path}");
    } catch (e) {
      print("Failed to take picture: $e");
    }
  }

  void reset() {
    if (_isInitialized) {
      _cameraController.dispose(); // Dispose the controller
      _isInitialized = false;
      _isFlashOn = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    reset(); // Ensure reset is called when provider is disposed
    super.dispose();
  }
}
