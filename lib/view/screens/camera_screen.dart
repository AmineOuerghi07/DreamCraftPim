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

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver , TickerProviderStateMixin  {
  CameraController? _controller;
 // File? _pickedImage;
  bool _isFlashOn = false;
  double _currentZoom = 1.0;
  bool _isInitialized = false;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _initialScale = 1.0;
  double _startingZoom = 1.0;
  String _zoomStatus = ''; // Indicator for zoom status
  //final TransformationController _transformationController = TransformationController();
  AnimationController? _scanAnimationController;
  final Color _scannerColor = Colors.white;
  bool _isCameraFrozen = false;
  File? _capturedImageFile;
  @override
  void initState() {
    super.initState();
     _scanAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  );
  _scanAnimationController!.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      _scanAnimationController!.reverse();
    } else if (status == AnimationStatus.dismissed) {
      _scanAnimationController!.forward();
    }
  });
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
  // void _zoomIn() {
  //   final double newZoom = (_currentZoom + 0.5).clamp(_minZoom, _maxZoom);
  //   _updateZoom(newZoom);
  // }

  // // Zoom out by decreasing the zoom level
  // void _zoomOut() {
  //   final double newZoom = (_currentZoom - 0.5).clamp(_minZoom, _maxZoom);
  //   _updateZoom(newZoom);
  // }

  // Update the zoom level of the camera
  // void _updateZoom(double newZoom) {
  //   if (_controller == null || !_isInitialized) return;

  //   setState(() {
  //     _currentZoom = newZoom;
  //   });

  //   // Update the camera zoom
  //   _controller!.setZoomLevel(_currentZoom);
  // }

  Future<void> _toggleFlash() async {
    if (!_isInitialized) return;
    setState(() => _isFlashOn = !_isFlashOn);
    await _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
  }

 // Update the _takePhoto method
Future<void> _takePhoto() async {
  if (!_isInitialized || _isCameraFrozen) return;
  
  try {
    // Capture image first
    final image = await _controller!.takePicture();
    final capturedFile = File(image.path);

    // Freeze UI and start animation
    setState(() {
      _isCameraFrozen = true;
      _capturedImageFile = capturedFile;
      _scanAnimationController!.repeat(reverse: true);
    });

    // Wait for full animation cycle (down + up)
    await Future.delayed(_scanAnimationController!.duration! * 2);

  } catch (e) {
    debugPrint("Photo error: $e");
  } finally {
    if (mounted) {
      setState(() => _scanAnimationController!.stop());
      // Process image after animation
      if (_capturedImageFile != null) {
        _handleImageProcessing(_capturedImageFile!);
      }
    }
  }
}

// Update the _handleImageProcessing method
Future<void> _handleImageProcessing(File image) async {
  // Show loading immediately
  context.push(RouteNames.loading_screen);

  try {
    final predictionViewModel = Provider.of<PredictionViewModel>(
      context, 
      listen: false
    );
    
    // Get actual prediction without artificial delay
    final response = await predictionViewModel.predictImage(image);

    if (mounted) {
      // Immediately show result when ready
      context.pop(); // Remove loading
      setState(() {
        _isCameraFrozen = false;
        _capturedImageFile = null;
      });
      
      // Show bottom sheet in the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResultDialog(image, response.data!);
      });
    }
  } catch (e) {
    if (mounted) {
      context.pop(); // Remove loading on error
      // Show error message
    }
  }
}
  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _handleImageProcessing(File(pickedFile.path));
    }
  }


void _showResultDialog(File image, String response) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.file(image, fit: BoxFit.cover),
              ),
              SizedBox(width: 16),
              
              // Text and Icon Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Text Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Processing Result', 
                                   style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('Prediction: $response',
                                   style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        
                        // Icon
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios, 
                               size: 20),
                          onPressed: () {
                            // Add your arrow action here
                          },
                        ),
                      ],
                    ),
                    
                    // Elevated Button
                    ElevatedButton(
                      onPressed: () {
                        context.push(RouteNames.chat_screen);
                      },
                      child: Text("Let's Talk with Hassan"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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

   return Scaffold(
  body:
   LayoutBuilder(
     builder: (context, constraints) {

     return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      child: Stack(
        children: [
          // AspectRatio widget to enforce 1:1 aspect ratio for the camera preview
          Positioned.fill(
  child: _isCameraFrozen && _capturedImageFile != null
      ? Image.file(_capturedImageFile!, fit: BoxFit.cover)
      : AspectRatio(
          aspectRatio: 1,
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize?.height ?? MediaQuery.of(context).size.width,
                height: _controller!.value.previewSize?.width ?? MediaQuery.of(context).size.width,
                child: CameraPreview(_controller!),
              ),
            ),
          ),
        ),
),
        Center(
     child: SizedBox(
      width: 130 * _currentZoom,
      height: 130 * _currentZoom,
     //  decoration: BoxDecoration(
     // border: Border.all(color: Colors.red),), // Debug border
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerBorderPainter(
                color: _scannerColor,
                cornerLength: 20 * _currentZoom, // Scale with zoom
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _scanAnimationController!,
            builder: (context, child) {
                  final animationValue = CurvedAnimation(
      parent: _scanAnimationController!,
      curve: Curves.easeInOut,
    ).value;
              return Positioned(
                top: animationValue * 130 * _currentZoom,
                child: Container(
                  width: 130 * _currentZoom,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _scannerColor.withOpacity(0),
                        _scannerColor,
                        _scannerColor.withOpacity(0),
                      ],
                      stops: [0.25, 0.5, 0.75],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
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
         );
  }),
);


  }
}
class ScannerBorderPainter extends CustomPainter {
  final Color color;
  final double cornerLength;

  ScannerBorderPainter({
    required this.color,
    this.cornerLength = 20.0,
  });

 @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      
      ..style = PaintingStyle.stroke;
      

    // Drawing four corners
    double cornerLength = 15;

    // Top-left corner
    canvas.drawLine(Offset(0, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, cornerLength), paint);

    // Top-right corner
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom-left corner
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // Bottom-right corner
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}