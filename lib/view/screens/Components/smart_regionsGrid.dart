import 'package:flutter/material.dart';
import 'package:pim_project/view/screens/Components/SmartRegionCard.dart';

class SmartRegionsGrid extends StatefulWidget {
  const SmartRegionsGrid({super.key});

  @override
  State<SmartRegionsGrid> createState() => _SmartRegionsGridState();
}

class _SmartRegionsGridState extends State<SmartRegionsGrid> {
  // Define the card data
  final List<Map<String, dynamic>> cardsData = [
    {
      "icon": Icons.lightbulb,
      "iconColor": Colors.yellow,
      "title": "Lighting",
      "subtitle": "12 watt",
    },
    {
      "icon": Icons.thermostat,
      "iconColor": Colors.red,
      "title": "Temperature",
      "subtitle": "40°C",
    },
    {
      "icon": Icons.water_drop,
      "iconColor": Colors.blue,
      "title": "Irragation",
      "subtitle": "200m",
    },
    {
      "icon": Icons.landscape_rounded,
      "iconColor": const Color.fromARGB(255, 172, 109, 15),
      "title": "Soil",
      "subtitle": "Growth",
    },
  ];

  // Track switch states for each card
  late List<bool> switches;

  @override
  void initState() {
    super.initState();
    switches = List.generate(
        cardsData.length, (index) => true); // Initialize switch states
  }

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: calculateCrossAxisCount(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.99, // Adjust card size
          ),
          itemCount: cardsData.length,
          itemBuilder: (context, index) {
            final card = cardsData[index];
            return SmartRegionCard(
              icon: card["icon"],
              iconColor: card["iconColor"],
              title: card["title"],
              subtitle: card["subtitle"],
              switchValue: switches[index],
              onSwitchChanged: (newValue) {
                setState(() {
                  switches[index] = newValue;
                });
              },
            );
          },
        ),
      ),
    );
  }
}
