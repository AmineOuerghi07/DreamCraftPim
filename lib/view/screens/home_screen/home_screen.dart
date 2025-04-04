import 'package:flutter/material.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/view/screens/home_screen/components/field_management_grid.dart';
import 'package:pim_project/view/screens/home_screen/components/weather_card.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/view/screens/components/header.dart';
import 'package:pim_project/view/screens/components/search_bar.dart' as custom;
import 'package:pim_project/view_model/home_view_model.dart';
import 'package:pim_project/model/domain/land.dart';

class HomeScreen extends StatelessWidget {

  final String userId;

  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final FocusNode searchFocusNode = FocusNode();

    // Fetch rented lands and connected regions when screen loads
    Future.delayed(Duration.zero, () {
      Provider.of<HomeViewModel>(context, listen: false).fetchRentedLands(userId);
      Provider.of<HomeViewModel>(context, listen: false).fetchConnectedRegions(userId);
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header

              Header(
                profileImage: 'assets/images/profile.png',
                greetingText: 'Hi!',
                username: 'Mohamed',
              ),
              const SizedBox(height: 16),

              // Search Bar
      
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: WeatherCard(),
              ),
              const SizedBox(height: 20),
              
              // Field Management Grid Component
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: FieldManagementGrid(
                  onFeatureSelected: (feature) {
                    // Handle feature selection
                    print('Selected feature: $feature');
                    
                    // Add navigation logic based on selected feature
                    switch (feature) {
                      case 'regions':
                        // Navigate to regions page
                        break;
                      case 'lands':
                        // Navigate to lands page
                        break;
                      // Add other cases as needed
                    }
                  },
                ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }
              // Help Card
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //   child: Container(
              //     padding: const EdgeInsets.all(16),
              //     decoration: BoxDecoration(
              //       color: Colors.green.withOpacity(0.1),
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     child: Row(
              //       children: [
              //         Expanded(
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               const Text(
              //                 "Need Our Help?",
              //                 style: TextStyle(
              //                   fontSize: 16,
              //                   fontWeight: FontWeight.bold,
              //                 ),
              //               ),
              //               const SizedBox(height: 8),
              //               const Text("Feel free to contact our support for any troubles"),
              //               const SizedBox(height: 8),
              //               ElevatedButton(
              //                 onPressed: () {
              //                   print("Call Now button tapped!");
              //                 },
              //                 style: ElevatedButton.styleFrom(
              //                   backgroundColor: Colors.green,
              //                   shape: RoundedRectangleBorder(
              //                     borderRadius: BorderRadius.circular(4),
              //                   ),
              //                 ),
              //                 child: const Text(
              //                   "Call Now",
              //                   style: TextStyle(
              //                     fontSize: 12,
              //                     color: Colors.white,
              //                   ),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //         const SizedBox(width: 16),

              //         Image.asset("assets/images/help.png", fit: BoxFit.cover),
              //       ],
              //     ),
              //   ),
              // ),
         
