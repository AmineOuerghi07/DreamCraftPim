import 'package:flutter/material.dart';

class RegionInfo extends StatelessWidget {
  final String regionCount;
  final String cultivationType;
  final String location;
  final VoidCallback onAddRegion;
  final String buttonText;
  final bool showRegionCount; // New parameter to toggle region count or button
  final VoidCallback? onAddSensors; // Optional callback for "Add Sensors"

  const RegionInfo({
    super.key,
    required this.regionCount,
    required this.cultivationType,
    required this.location,
    required this.onAddRegion,
    this.buttonText = "Add Region",
    this.showRegionCount = true, // Default to showing region count
    this.onAddSensors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Region Count or Add Sensors, Cultivation Type, and Location
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Conditionally show region count or "Add Sensors" button
            showRegionCount
                ? Container(
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
                  )
                : GestureDetector(
                    onTap: onAddSensors,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "Add Sensors",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 8),
            Text(
              cultivationType,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_pin, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
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
        // Right Column: Add Button and Image
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: onAddRegion,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
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