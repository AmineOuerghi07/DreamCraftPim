import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/ProviderClasses/bottom_navigation_bar_provider_class.dart';
import 'package:pim_project/ProviderClasses/camera_provider.dart';
import 'package:pim_project/model/repositories/prediction_repository.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/view_model/prediction_view_model.dart';
import 'package:provider/provider.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

  Future<void> _openCamera(BuildContext context) async {
       context.push(RouteNames.camera);

  }
// Future<void> _openCamera() async {
//   try {
//     final cameraService = context.read<CameraProvider>();
//     print("Initializing Camera...");

//     // Attempt to initialize the camera
//     await cameraService.initialize();

//     // Check if the camera is initialized
//     if (cameraService.isInitialized) {
//       print("Camera Initialized: ${cameraService.isInitialized}");
//       print("Navigating to Camera Screen...");
//     } else {
//       // Throw an exception if the camera is not initialized
//       throw Exception('Camera initialization failed: Camera is not initialized.');
//     }
//   } catch (e) {
//     // Handle the error and display a user-friendly message
//     print("Error opening camera: $e");

//     // Show a SnackBar with the error message
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           e.toString().replaceAll('Exception: ', ''), // Remove "Exception: " from the message
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.red, // Red background for error messages
//         duration: Duration(seconds: 3), // Display for 3 seconds
//       ),
//     );
//   }
// }
  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavigationProvider>(
      builder: (context, provider, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Bottom Navigation Bar
            BottomNavigationBar(
              currentIndex: provider.selectedIndex,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(icon: Icon(Icons.store), label: "Market"),
                BottomNavigationBarItem(icon: Icon(null), label: ""), // Empty item for the middle space
                BottomNavigationBarItem(icon: Icon(Icons.map), label: "Lands"),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
              ],
              selectedItemColor: Colors.green,
              unselectedItemColor: Colors.grey,
              onTap: (index) {
                provider.setIndex(index);

                switch (index) {
                  case 0:
                    context.go(RouteNames.home);
                    break;
                  case 1:
                    context.go(RouteNames.market);
                    break;
                  case 2:
                    // Do nothing for the middle item (camera icon)
                    break;
                  case 3:
                    context.go(RouteNames.land);
                    break;
                  case 4:
                    context.go(RouteNames.profile);
                    break;
                }
              },
            ),

            // Floating Camera Icon
            Positioned(
              left: MediaQuery.of(context).size.width / 2 -14, // Center the icon horizontally
              bottom: 30, // Adjust the elevation
              child: GestureDetector(
                onTap: () async{
                  // Handle camera icon tap
                   await _openCamera(context);;
                },
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green, // Background color of the circle
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}