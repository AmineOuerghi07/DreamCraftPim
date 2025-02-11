import 'package:flutter/material.dart';
import 'package:pim_project/ProviderClasses/camera_provider.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraProvider _cameraProvider;

  @override
  void initState() {
    super.initState();
    _cameraProvider = Provider.of<CameraProvider>(context, listen: false);
  }

  @override
  void dispose() {
    // Reset the camera directly through the stored reference
    _cameraProvider.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CameraProvider>(
        builder: (context, cameraProvider, child) {
          if (!cameraProvider.isInitialized) {
            cameraProvider.initialize();
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              CameraPreview(cameraProvider.cameraController),
              Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green.withOpacity(0.8),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Positioned(
                bottom: 120,
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

