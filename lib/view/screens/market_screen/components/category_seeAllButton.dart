
import 'package:flutter/material.dart';

class CategorySeeallbutton extends StatelessWidget {
  final VoidCallback navigateSeeAll;
  final List<String> categories;
  // ignore: prefer_typing_uninitialized_variables
  final index;
  const CategorySeeallbutton({super.key, required this.navigateSeeAll, required this.categories, required this.index}); 

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          categories[index],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: navigateSeeAll,
          child: const Text(
            "See all",
            style: TextStyle(
              color: Color.fromARGB(255, 3, 78, 5),
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
