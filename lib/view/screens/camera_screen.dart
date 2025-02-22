import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pim_project/view_model/prediction_view_model.dart';
import 'package:provider/provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  File? _pickedImage;
  bool _isFlashOn = false;
  double _currentZoom = 1.0;
  bool _isInitialized = false;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _initialScale = 1.0;
  double _startingZoom = 1.0;
  String _zoomStatus = ''; // Indicator for zoom status
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.medium,
    );

    try {
      await _controller!.initialize();
      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _currentZoom = _minZoom;
        });
      }
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  // Handle the start of a scale gesture
  void _handleScaleStart(ScaleStartDetails details) {
    _initialScale = _currentZoom;  // Save the initial zoom
    _startingZoom = _currentZoom;  // Save the starting zoom level for reference
  }

  // Handle the scaling of the pinch gesture
  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_controller == null || !_isInitialized) return;

    // Calculate the scale factor (how much the user has scaled)
    final double scaleFactor = details.scale;

    // Compute the new zoom level by multiplying the initial zoom by the scale factor
    double newZoom = _startingZoom * scaleFactor;

    // Apply zoom constraints to make sure the zoom doesn't go below the minimum or above the maximum
    newZoom = newZoom.clamp(_minZoom, _maxZoom);

    // Determine whether the user is zooming in or out
    String zoomStatus = newZoom > _currentZoom ? 'Zooming In' : 'Zooming Out';

    // Only update the zoom if it's different from the current zoom
    if (newZoom != _currentZoom) {
      setState(() {
        _currentZoom = newZoom;
        _zoomStatus = zoomStatus;  // Update the zoom status
      });

      // Update the zoom level on the camera
      _controller!.setZoomLevel(_currentZoom);
    }
  }

  // Zoom in by increasing the zoom level
  void _zoomIn() {
    final double newZoom = (_currentZoom + 0.5).clamp(_minZoom, _maxZoom);
    _updateZoom(newZoom);
  }

  // Zoom out by decreasing the zoom level
  void _zoomOut() {
    final double newZoom = (_currentZoom - 0.5).clamp(_minZoom, _maxZoom);
    _updateZoom(newZoom);
  }

  // Update the zoom level of the camera
  void _updateZoom(double newZoom) {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      _currentZoom = newZoom;
    });

    // Update the camera zoom
    _controller!.setZoomLevel(_currentZoom);
  }

  Future<void> _toggleFlash() async {
    if (!_isInitialized) return;
    setState(() => _isFlashOn = !_isFlashOn);
    await _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
  }

  Future<void> _takePhoto() async {
    if (!_isInitialized) return;
    try {
      final image = await _controller!.takePicture();
      _handleImageProcessing(File(image.path));
    } catch (e) {
      debugPrint("Photo error: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _handleImageProcessing(File(pickedFile.path));
    }
  }

  Future<void> _handleImageProcessing(File image) async {
    context.push(RouteNames.loading_screen);

    // Simulate image processing
    await Future.delayed(const Duration(seconds: 2));

    context.pop();
    final predictionViewModel = Provider.of<PredictionViewModel>(context, listen: false);
    final response = await predictionViewModel.predictImage(image);
    _showResultDialog(image , response.data!);
  }

  void _showResultDialog(File image,String response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Processing Result'),
        content: Column(
          children: [
            Image.file(image),
            Text('Prediction: ${response}'),
ElevatedButton(
  onPressed: () {
    context.push(RouteNames.chat_screen);
  },
  child: Text("Let's Talk with Hassan"),
)          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // Get screen size
    final screenSize = MediaQuery.of(context).size;

   return Scaffold(
  body: GestureDetector(
    onScaleStart: _handleScaleStart,
    onScaleUpdate: _handleScaleUpdate,
    child: Stack(
      children: [
        // AspectRatio widget to enforce 1:1 aspect ratio for the camera preview
        Positioned.fill(
          child: AspectRatio(
            aspectRatio: 1,
            child: OverflowBox(
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.previewSize != null
                      ? _controller!.value.previewSize!.height
                      : MediaQuery.of(context).size.width,
                  height: _controller!.value.previewSize != null
                      ? _controller!.value.previewSize!.width
                      : MediaQuery.of(context).size.width,
                  child: CameraPreview(_controller!),
                ),
              ),
            ),
          ),
        ),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 200 * _currentZoom,
            height: 200 * _currentZoom,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        // Gallery icon at the bottom-left
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton(
            onPressed: _pickFromGallery,
            backgroundColor: Colors.green,
            child: const Icon(Icons.photo_library),
          ),
        ),
        // Camera icon at the bottom-center
        Positioned(
          bottom: 16,
          left: MediaQuery.of(context).size.width / 2 - 28, // Center horizontally
          child: FloatingActionButton(
            onPressed: _takePhoto,
            backgroundColor: Colors.green,
            child: const Icon(Icons.camera),
          ),
        ),
        // Flash icon at the top-right
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _toggleFlash,
            backgroundColor: Colors.green,
            child: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
            ),
          ),
        ),
      ],
    ),
  ),
);


  }
}
