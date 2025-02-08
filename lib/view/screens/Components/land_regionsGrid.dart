import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandRegionsGrid extends StatelessWidget {
  const LandRegionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;

    // Dynamically determine the number of grid columns based on screen width
    int calculateCrossAxisCount() {
      if (screenWidth >= 1200) {
        return 4; // 4 columns for large screens
      } else if (screenWidth >= 800) {
        return 3; // 3 columns for medium screens
      } else {
        return 2; // 2 columns for small screens
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: GridView.builder(
          shrinkWrap: true, // Makes GridView take only as much space as needed
          physics: const NeverScrollableScrollPhysics(), // Prevents GridView from scrolling (since it's inside a scrollable parent)
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: calculateCrossAxisCount(),
            childAspectRatio: 0.8, // Adjust the aspect ratio to make cards bigger
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                 GoRouter.of(context).push('/region-details/6952315ald2');
                print("Region ${index + 1} tapped!");
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(0), // Add padding inside the card
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 12), // Add padding above the image
                        child: Image(
                          image: AssetImage("assets/images/plant.png"),
                        ),
                      ),
                      const SizedBox(height: 8), // Space between the image and title
                      Text(
                        "Region ${index + 1}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8), // Space between the title and info rows
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Center the rows
                        children: [
                          // Column for icons
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center, // Align icons centrally
                            children:  [
                              Icon(Icons.sensors, size: 20, color: Colors.green),
                              SizedBox(height: 12),
                              Icon(Icons.grass, size: 20, color: Colors.green),
                              SizedBox(height: 12),
                              Icon(Icons.water_drop, size: 20, color: Colors.green),
                            ],
                          ),
                          SizedBox(width: 16), // Space between columns
                          // Column for text
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                            children:  [
                              Text(
                                "5 Sensors",
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "250 Plants",
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "60% Irrigation",
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}