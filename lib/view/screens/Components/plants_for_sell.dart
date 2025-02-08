import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlantsForSell extends StatelessWidget {
  const PlantsForSell({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250, // Fixed height for horizontal scrolling
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Makes it scrollable horizontally
        padding: const EdgeInsets.all(8),
        itemCount: 6, // Example: 6 cards
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(right: 8),
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
    return GestureDetector(
      onTap: () {
        // Navigate to the product details screen
        GoRouter.of(context).push('/product-details/1');
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          width: 200, // Set a fixed width for each card
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price and favorite icon
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.favorite_border, color: Colors.grey),
                  Text(
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
      ),
    );
  }
}
