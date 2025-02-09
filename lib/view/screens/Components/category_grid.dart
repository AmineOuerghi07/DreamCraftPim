import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoryGrid extends StatelessWidget {
  CategoryGrid({super.key});
  final List<String> imageNames = [
    "assets/images/Group514.png",
    "assets/images/category2.png",
    "assets/images/Group514.png",
    "assets/images/Group514.png",
    "assets/images/Group514.png",
    "assets/images/Group514.png",
    "assets/images/Group514.png",
    "assets/images/Group514.png",
    "assets/images/Group514.png",
    "assets/images/Group514.png",
  ];
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Set to 2 columns
          childAspectRatio: 0.8, // Adjust the aspect ratio for bigger cards
        ),
        itemCount: 10, // Adjust the number of items based on your data
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              GoRouter.of(context).push('/market-details/6952315ald2');
              print("Region ${index + 1} tapped!");
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(0), // Add padding inside the card
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Add padding above the image
                    Expanded(
                      child: Image(
                      image: AssetImage(imageNames[index]),
                      fit: BoxFit.cover, // Make the image fill the whole card
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
