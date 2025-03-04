import 'package:flutter/material.dart';

class RegionInfo extends StatelessWidget {
  final String regionCount;
  final String cultivationType;
  final String location;
  final VoidCallback onAddRegion;

  const RegionInfo( {
    super.key,
    required this.regionCount,
    required this.cultivationType,
    required this.location,
    required this.onAddRegion,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
      children: [
        // Left Column: Region Count, Cultivation Type, and Location
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Region Count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color.fromARGB(50, 68, 206, 155),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "$regionCount Regions",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8), // Spacing between region count and cultivation type
            // Cultivation Type
            Text(
              cultivationType,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4), // Spacing between cultivation type and location
            // Location
            Row(
              children: [
                const Icon(Icons.location_pin, size: 16, color: Colors.grey),
                const SizedBox(width: 4), // Spacing between icon and text
                Text(
                  location,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Right Column: Add Region Button and Image
        Column(
          crossAxisAlignment: CrossAxisAlignment.end, // Align items to the right
          children: [
            // Add Region Button
            GestureDetector(
              onTap: onAddRegion,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1), // Light green background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "Add Region",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8), // Spacing between button and image
            // Image
            const Image(
              image: AssetImage("assets/images/google_maps_location_picker.png"),
              width: 100,
              height: 100,
            ),
          ],
        ),
      ],
    );
  }
}