import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/view/screens/loading_screen.dart';
import 'package:pim_project/view_model/prediction_view_model.dart';
import 'package:image_picker/image_picker.dart';

class CameraProvider with ChangeNotifier {
  late CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isFlashOn = false;
  double _zoomLevel = 0.0; // Default zoom level
  double _minZoom = 0.0;
  double _maxZoom = 1.0;
   PredictionViewModel _predictionViewModel;
  File? _capturedImage; // Store captured image
  bool _disposed = false;
  bool _isFirstInitialization = true;
  CameraProvider({required PredictionViewModel predictionViewModel})
      : _predictionViewModel = predictionViewModel;

  // Getters
CameraController get cameraController {
  if (_cameraController == null || !_cameraController!.value.isInitialized) {
    throw Exception("CameraController is not initialized");
  }
  return _cameraController!;
}
  bool get isInitialized => _isInitialized;
  bool get isFlashOn => _isFlashOn;
  double get zoomLevel => _zoomLevel;
  double get minZoom => _minZoom;
  double get maxZoom => _maxZoom;
  File? get capturedImage => _capturedImage;
   PredictionViewModel get predictionViewModel => _predictionViewModel;

  // In CameraProvider class
  Future<void> initialize() async {
    if (_isInitialized || _disposed) return;

    try {
      if (!_isFirstInitialization && _cameraController != null) {
        await _cameraController!.dispose();
      }

      final cameras = await availableCameras();
      _cameraController = CameraController(
        cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back),
        ResolutionPreset.medium,
      )..addListener(() {
          if (!_cameraController!.value.isInitialized) return;
          notifyListeners();
        });

      await _cameraController!.initialize();

      _minZoom = await _cameraController!.getMinZoomLevel();
      _maxZoom = await _cameraController!.getMaxZoomLevel();
      _zoomLevel = _minZoom;
      _isFirstInitialization = false;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Camera init error: $e");
      _isInitialized = false;
      notifyListeners();
    }
  }




Future<void> pauseCamera() async {
  if (!_isInitialized || _disposed) return;
  try {
    await _cameraController?.pausePreview();
    debugPrint("Camera preview paused.");
  } catch (e) {
    debugPrint("Failed to pause camera: $e");
  }
}

Future<void> resumeCamera() async {
  if (!_isInitialized || _disposed) return;
  try {
    await _cameraController?.resumePreview();
    debugPrint("Camera preview resumed.");
  } catch (e) {
    debugPrint("Failed to resume camera: $e");
  }
}


Future<void> pickImageFromGallery(BuildContext context) async {
  if (_disposed) return;

  try {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _capturedImage = File(pickedFile.path);

      // Navigate to Loading Screen
      context.push(RouteNames.loadingScreen);

      if (_capturedImage != null) {
        final response = await _predictionViewModel.predictImage(_capturedImage!);

        // Navigate back
        context.pop();

        // Show response
        _showResponseBottomSheet(context, response.message!);

        // Force reloading the screen
        Future.delayed(Duration(milliseconds: 300), () {
          if (context.mounted) {
            context.pop(); // Remove the CameraScreen
            context.push(RouteNames.camera); // Reopen the CameraScreen
          }
        });
      }

      notifyListeners();
    }
  } catch (e) {
    debugPrint("Error picking image: $e");
  }
}



void _showResponseBottomSheet(BuildContext context, String response) {
  if (Navigator.of(context).mounted) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Text(
            response,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        );
      },
    );
  }
}

  Future<void> toggleFlash() async {
    if (!_isInitialized || _disposed) return;
    try {
      _isFlashOn = !_isFlashOn;
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to toggle flash: $e");
    }
  }

  Future<void> takePicture() async {
    if (!_isInitialized || _disposed) return;
    try {
      final image = await _cameraController!.takePicture();
      if (_disposed) {
        debugPrint("CameraProvider is disposed. Aborting picture save.");
        return;
      }
      debugPrint("Picture saved: ${image.path}");
      _capturedImage = File(image.path);
      notifyListeners();

      final response = await _predictionViewModel.predictImage(_capturedImage!);
      debugPrint("Prediction Response: $response");
    } catch (e) {
      debugPrint("Failed to take picture: $e");
    }
  }

  Future<void> setZoomLevel(double zoomLevel) async {
    if (!_isInitialized || _disposed) return;
    try {
      _zoomLevel = zoomLevel.clamp(_minZoom, _maxZoom);
      await _cameraController!.setZoomLevel(_zoomLevel);
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to set zoom level: $e");
    }
  }

  void reset() {
    _cameraController!.dispose();
    _isInitialized = false;
    _isFlashOn = false;
    _zoomLevel = _minZoom;
    _capturedImage = null;
    notifyListeners();
  }

 @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _cameraController?.dispose();
    _cameraController = null;
    super.dispose();
  }
}
