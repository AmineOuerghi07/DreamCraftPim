import 'package:flutter/material.dart';

class RegionDetailInfocard extends StatelessWidget {
  final String title;
  final String value;
  final String imageName;

  const RegionDetailInfocard({
    super.key,
    required this.title,
    required this.value,
    required this.imageName,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            width: 150,
            child: Row(
              children: [
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image(
                      image: AssetImage("../assets/images/$imageName"),
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
