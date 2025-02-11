import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pim_project/ProviderClasses/camera_provider.dart';
import 'package:provider/provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraProvider _cameraProvider;
  double _currentZoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    _cameraProvider.initialize(); // Initialize camera in provider
  }

  @override
  void dispose() {
    _cameraProvider.reset(); // Reset camera on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Consumer<CameraProvider>(
            builder: (context, cameraProvider, child) {
              if (!cameraProvider.isInitialized) {
                return const Center(child: CircularProgressIndicator());
              }

              final aspectRatio = cameraProvider.cameraController.value.aspectRatio;

              return Stack(
                children: [
                  // Full-Screen Camera Preview with Aspect Ratio
                  Positioned.fill(
                    child: GestureDetector(
                      onScaleUpdate: (details) {
                        setState(() {
                          // Ensure zoom remains within bounds
                          _currentZoomLevel = details.scale.clamp(1.0, 5.0);
                        });
                        cameraProvider.setZoomLevel(_currentZoomLevel);
                      },
                      child: AspectRatio(
                        aspectRatio: 1.0, // This was your original aspect ratio, feel free to adjust
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
                  ),

                  // Overlay Frame for Scanning (Transparent)
                  Center(
                    child: Container(
                      width: orientation == Orientation.portrait ? 300 : 500,
                      height: orientation == Orientation.portrait ? 300 : 300,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.green.withOpacity(0.8),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  // Instructions (Transparent Background)
                  Positioned(
                    bottom: orientation == Orientation.portrait ? 120 : 20,
                    left: 20,
                    right: 20,
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
              await cameraProvider.takePicture(); // Trigger picture capture from provider
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.camera, color: Colors.white),
          );
        },
      ),
    );
  }
}
