import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pim_project/ProviderClasses/camera_provider.dart';
import 'package:provider/provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraProvider? _cameraProvider;
  final TransformationController _transformationController = TransformationController();
  double _currentZoomLevel = 1.0; // Current zoom level
  double _baseScale = 1.0; // Base scale for pinch-to-zoom
  int _pointers = 0; // Number of active pointers

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    _cameraProvider?.initialize(); // Initialize camera in provider
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraProvider?.dispose(); // Dispose of the CameraProvider
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Pause the camera when the app is paused
      _cameraProvider?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera when the app is resumed
      _cameraProvider?.initialize();
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentZoomLevel;
    debugPrint("Scale start: base scale = $_baseScale");
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    double newZoomLevel = _baseScale * details.scale;
    newZoomLevel = newZoomLevel.clamp(_cameraProvider!.minZoom, _cameraProvider!.maxZoom);
    debugPrint("Scale update: details.scale = ${details.scale}, newZoomLevel = $newZoomLevel");
    _setZoomLevel(newZoomLevel);
  }

  void _setZoomLevel(double zoom) {
    if (!_cameraProvider!.isInitialized) {
      debugPrint("Camera not initialized");
      return;
    }
    debugPrint("Camera min zoom: ${_cameraProvider!.minZoom}, max zoom: ${_cameraProvider!.maxZoom}");

    final double clampedZoom = zoom.clamp(_cameraProvider!.minZoom, _cameraProvider!.maxZoom);
    debugPrint("Clamped zoom level: $clampedZoom");

    if (clampedZoom != _currentZoomLevel) {
      setState(() {
        _currentZoomLevel = clampedZoom;
      });
      _cameraProvider!.setZoomLevel(_currentZoomLevel); // Apply the zoom level
      debugPrint("Zoom updated: $_currentZoomLevel");
      _transformationController.value = Matrix4.identity()..scale(_currentZoomLevel);
    }
  }

  // Optional: tap-to-focus using LayoutBuilder constraints
  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    _cameraProvider!.cameraController.setFocusPoint(offset);
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraProvider == null || !_cameraProvider!.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Consumer<CameraProvider>(
            builder: (context, cameraProvider, child) {
              if (!cameraProvider.isInitialized) {
                return const Center(child: CircularProgressIndicator());
              }

              return Listener(
                onPointerDown: (_) => _pointers++,
                onPointerUp: (_) => _pointers--,
                child: Stack(
                  children: [
                    // Square (aspectRatio 1) camera preview with pinch-to-zoom and tap-to-focus
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onScaleStart: (details) {
                              debugPrint("Scale started");
                              _handleScaleStart(details);
                            },
                            onScaleUpdate: (details) {
                              debugPrint("Scale updated: ${details.scale}");
                              _handleScaleUpdate(details);
                            },
                            onTapDown: (details) {
                              debugPrint("Tap detected");
                              onViewFinderTap(details, constraints);
                            },
                            child: InteractiveViewer(
                              transformationController: _transformationController,
                              panEnabled: false, // Disable panning for this use case
                              minScale: _cameraProvider!.minZoom,
                              maxScale: _cameraProvider!.maxZoom,
                              onInteractionStart: (details) {
                                _baseScale = _currentZoomLevel;
                              },
                              onInteractionUpdate: (details) {
                                final newZoomLevel = _baseScale * details.scale;
                                _setZoomLevel(newZoomLevel);
                              },
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: ClipRect(
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: cameraProvider.cameraController.value.previewSize?.height ?? 0,
                                      height: cameraProvider.cameraController.value.previewSize?.width ?? 0,
                                      child: CameraPreview(cameraProvider.cameraController),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Overlay Frame for Scanning (Transparent)
                    Center(
                      child: Transform.scale(
                        scale: _currentZoomLevel,
                        child: IgnorePointer(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.green.withOpacity(0.5),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Instructions (Transparent Background)
                    Positioned(
                      bottom: orientation == Orientation.portrait ? 120 : 20,
                      left: 20,
                      right: 20,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Place the infected plant inside the frame for scanning.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Flash Toggle Button (Transparent Background)
                    Positioned(
                      top: 40,
                      right: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            cameraProvider.isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            cameraProvider.toggleFlash();
                          },
                        ),
                      ),
                    ),

                    // Gallery Button (Transparent Background)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            // Open gallery to view previously taken pictures
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Consumer<CameraProvider>(
        builder: (context, cameraProvider, child) {
          return FloatingActionButton(
            onPressed: () async {
              await cameraProvider.takePicture();
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.camera, color: Colors.white),
          );
        },
      ),
    );
  }
}