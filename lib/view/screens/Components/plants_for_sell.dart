import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/model/product.dart';

class PlantsForSell extends StatelessWidget {
  final List<Product> products;
  final List<String> categories;

  const PlantsForSell({super.key, required this.products, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250, // Fixed height for horizontal scrolling
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Makes it scrollable horizontally
        padding: const EdgeInsets.all(8),
        itemCount: products.length, // Use actual products count
        itemBuilder: (context, index) {
          final product = products[index]; // Get the product for this index
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PlantCard(product: product), // Pass the product to PlantCard
          );
        },
      ),
    );
  }
}

class PlantCard extends StatelessWidget {
  final Product product; // Accept product as a parameter

  const PlantCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the product details screen
        GoRouter.of(context).push('/product-details/${product.id}'); // Pass product ID
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.favorite_border, color: Colors.grey),
                  Text(
                    "${product.price} DT", // Display dynamic price
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Plant image
              Expanded(
                child: Center(
                  child: Image.asset(
                    product.image ?? "assets/images/pngwing.png", // Use product image URL or placeholder

                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Plant name
              Center(
                child: Text(
                  product.name, // Display dynamic name
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 4),
              // Plant description or address (if available)
              Center(
                child: Text(
                  product.description ?? "No description", // Show description or default text
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
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
