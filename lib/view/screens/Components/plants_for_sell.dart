import 'package:flutter/material.dart';

class PlantsForSell extends StatelessWidget {
  const PlantsForSell({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300, // Fixed height for horizontal scrolling
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Makes it scrollable horizontally
        padding: const EdgeInsets.all(16),
        itemCount: 6, // Example: 6 cards
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(right: 16),
          child: PlantCard(),
        ),
      ),
    );
  }
}

class PlantCard extends StatelessWidget {
  const PlantCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 200, // Set a fixed width for each card
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price and favorite icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.favorite_border, color: Colors.grey),
                const Text(
                  "16DT / 1 lbs",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Plant image
            Expanded(
              child: Center(
                child: Image.asset(
                  "../assets/images/pngwing.png", // Correct path for the asset
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Plant name
            const Center(
              child: Text(
                "White Radish",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 4),
            // Address
            const Center(
              child: Text(
                "BB, Avenue 16, Sfax",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            // Buy Now text
            Center(
              child: GestureDetector(
                onTap: () {
                  // Add buy logic here
                  print("Buy Now tapped");
                },
                child: const Text(
                  "Buy Now",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.green, // Make the text look clickable
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
