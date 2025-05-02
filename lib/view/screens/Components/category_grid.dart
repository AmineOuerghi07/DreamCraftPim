import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/ProviderClasses/market_provider.dart';
import 'package:provider/provider.dart';

class CategoryGrid extends StatelessWidget {
  final List<String> categories;
  CategoryGrid({super.key, required this.categories});


  @override
  Widget build(BuildContext context) {
    return Expanded( // Removed unnecessary Column
      child: Consumer<MarketProvider>(
        builder: (context, marketProvider, child) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columns
              childAspectRatio: 0.8, // Aspect ratio for better card size
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  
                  marketProvider.toggleFilter(); // Toggle filter
                  marketProvider.toggleCategoryFilter(categories[index]); // Toggle category filter
                 
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Stack(
                    children: [
                      // Background Image
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            "../assets/images/${categories[index]}.jpg", // Fixed asset path
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Category Name Overlay
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            categories[index], // Category name
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
