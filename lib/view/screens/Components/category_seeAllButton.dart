import 'package:flutter/material.dart';

class CategorySeeallbutton extends StatelessWidget {
  final VoidCallback navigateSeeAll;
  const CategorySeeallbutton({super.key, required this.navigateSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Plants",
          style: TextStyle(
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
