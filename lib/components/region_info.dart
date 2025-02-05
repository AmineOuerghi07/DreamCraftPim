import 'package:flutter/material.dart';

class RegionInfo extends StatelessWidget {
  final String regionCount;
  final String cultivationType;
  final String location;
  final VoidCallback onAddRegion;

  const RegionInfo({
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
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text(
              cultivationType,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_pin, size: 16, color: Colors.grey),
                Text(
                  location,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onAddRegion,
              child: const Text(
                "Add Region",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Image(
              image: AssetImage(
                  "../assets/images/google_maps_location_picker.png"),
              width: 100,
              height: 100,
            ),
          ],
        ),
      ],
    );
  }
}
