import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraProvider with ChangeNotifier {
  late CameraController _cameraController;
  bool _isInitialized = false;
  bool _isFlashOn = false;
  double _zoomLevel = 0.0; // Default zoom level
  double _minZoom = 0.0;
  double _maxZoom = 1.0;

  // Getters to access private fields
  CameraController get cameraController => _cameraController;
  bool get isInitialized => _isInitialized;
  bool get isFlashOn => _isFlashOn;
  double get zoomLevel => _zoomLevel;
  double get minZoom => _minZoom;
  double get maxZoom => _maxZoom;

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

      // Cache the min and max zoom levels from the camera controller
      _minZoom = await _cameraController.getMinZoomLevel();
      _maxZoom = await _cameraController.getMaxZoomLevel();
      // Start with the minimum zoom (usually 1.0)
      _zoomLevel = _minZoom;

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

  Future<void> setZoomLevel(double zoomLevel) async {
    if (!_isInitialized) return;

    try {
      // Use cached min and max zoom values
      _zoomLevel = zoomLevel.clamp(_minZoom, _maxZoom);
      await _cameraController.setZoomLevel(_zoomLevel);
      notifyListeners();
    } catch (e) {
      print("Failed to set zoom level: $e");
    }
  }

  void reset() {
    if (_isInitialized) {
      _cameraController.dispose();
      _isInitialized = false;
      _isFlashOn = false;
      _zoomLevel = 1.0; // Reset zoom level
      notifyListeners();
    }
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }
}
