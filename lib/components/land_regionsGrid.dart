import 'package:flutter/material.dart';

class LandRegionsgrid extends StatelessWidget {
  const LandRegionsgrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return SizedBox(
          height: 150,
          width: 50,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Image(
                    image: AssetImage("../assets/images/plant.png"),
                    width: 100,
                    height: 100,
                  ),
                  Text(
                    "Region ${index + 1}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sensors, size: 16, color: Colors.green),
                      SizedBox(width: 4),
                      Text("5 Sensors"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.grass, size: 16, color: Colors.green),
                      SizedBox(width: 4),
                      Text("250 Plants"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.water_drop, size: 16, color: Colors.green),
                      SizedBox(width: 4),
                      Text("60% Irrigation"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
