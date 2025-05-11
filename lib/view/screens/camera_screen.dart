import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pim_project/view/screens/components/app_progress_indicator.dart';
import 'package:pim_project/view_model/prediction_view_model.dart';
import 'package:provider/provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _controller;
  bool _isFlashOn = false;
  double _currentZoom = 1.0;
  bool _isInitialized = false;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _initialScale = 1.0;
  double _startingZoom = 1.0;
  String _zoomStatus = '';
  AnimationController? _scanAnimationController;
  final Color _scannerColor = Colors.white;
  bool _isCameraFrozen = false;
  File? _capturedImageFile;
  final ImagePicker _picker = ImagePicker();

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
    _scanAnimationController?.dispose();
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
      debugPrint("Camera initialization error: $e");
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _initialScale = _currentZoom;
    _startingZoom = _currentZoom;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_controller == null || !_isInitialized) return;

    final double scaleFactor = details.scale;
    double newZoom = _startingZoom * scaleFactor;
    newZoom = newZoom.clamp(_minZoom, _maxZoom);
    String zoomStatus = newZoom > _currentZoom ? 'Zooming In' : 'Zooming Out';

    if (newZoom != _currentZoom) {
      setState(() {
        _currentZoom = newZoom;
        _zoomStatus = zoomStatus;
      });
      _controller!.setZoomLevel(_currentZoom);
    }
  }

  Future<void> _toggleFlash() async {
    if (!_isInitialized) return;
    setState(() => _isFlashOn = !_isFlashOn);
    await _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
  }

  Future<void> _takePhoto() async {
    if (!_isInitialized || _isCameraFrozen) return;

    try {
      final image = await _controller!.takePicture();
      final capturedFile = File(image.path);

      setState(() {
        _isCameraFrozen = true;
        _capturedImageFile = capturedFile;
        _scanAnimationController!.forward(from: 0);
      });

      await Future.delayed(_scanAnimationController!.duration!); // 3 seconds for scanning
      await _handleImageProcessing(capturedFile);
    } catch (e) {
      debugPrint("Photo capture error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing photo: $e')),
      );
      setState(() {
        _isCameraFrozen = false;
        _capturedImageFile = null;
        _scanAnimationController!.stop();
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _handleImageProcessing(File(pickedFile.path));
    }
  }

  Future<void> _handleImageProcessing(File image) async {
    print("Starting image processing...");
    context.push(RouteNames.processingScreen);

    try {
      final predictionViewModel = Provider.of<PredictionViewModel>(context, listen: false);
      final response = await predictionViewModel.predictImage(image);

      print("Prediction response: $response");

      // Ensure loading screen stays for 5 seconds
      await Future.delayed(Duration(seconds: 5));

      if (!mounted) return;

      context.pop(); // Pop back to CameraScreen

      setState(() {
        _isCameraFrozen = false;
        _capturedImageFile = null;
        _scanAnimationController!.stop();
      });

      if (response.status == Status.COMPLETED) {
        print("Prediction succeeded: ${response.data}");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showResultDialog(image, response.data!);
        });
      } else {
        print("Prediction failed: ${response.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Prediction failed: ${response.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        await Future.delayed(Duration(seconds: 5)); // Ensure 5 seconds on error
        context.pop();
        debugPrint("Image processing error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing image: $e')),
        );
        setState(() {
          _isCameraFrozen = false;
          _capturedImageFile = null;
          _scanAnimationController!.stop();
        });
      }
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.file(image, fit: BoxFit.cover),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Processing Result', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('Prediction: $response', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward_ios, size: 20),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close bottom sheet
                          context.push(RouteNames.chatScreen, extra: {
                            'image': image,
                            'prediction': response,
                          });
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
      return const Center(child:  AppProgressIndicator(
  loadingText: 'Growing data...',
  primaryColor: const Color(0xFF4CAF50), // Green
  secondaryColor: const Color(0xFF8BC34A), // Light Green
  size: 75, // Controls the overall size
),);
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            child: Stack(
              children: [
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
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: ScannerBorderPainter(
                              color: _scannerColor,
                              cornerLength: 20 * _currentZoom,
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
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: FloatingActionButton(
                    heroTag: 'gallery',
                    onPressed: _pickFromGallery,
                    backgroundColor: AppConstants.primaryColor,
                    child: const Icon(Icons.photo_library),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: MediaQuery.of(context).size.width / 2 - 28,
                  child: FloatingActionButton(
                    heroTag: 'camera',
                    onPressed: _takePhoto,
                    backgroundColor: AppConstants.primaryColor,
                    child: const Icon(Icons.camera),
                  ),
                ),
                Positioned(
                  top: 30,
                  right: 30,
                  child: FloatingActionButton(
                    heroTag: 'flash',
                    onPressed: _toggleFlash,
                    backgroundColor: AppConstants.primaryColor,
                    child: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ScannerBorderPainter extends CustomPainter {
  final Color color;
  final double cornerLength;

  ScannerBorderPainter({required this.color, this.cornerLength = 20.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double cornerLength = 15;

    canvas.drawLine(Offset(0, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, cornerLength), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}