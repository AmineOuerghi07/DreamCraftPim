import 'package:flutter/material.dart';

class RegionInformationSection extends StatelessWidget {
  final String description;

  const RegionInformationSection({
    Key? key,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFEEEEEE),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Colors.green,
                ),
                SizedBox(width: 8), // Add spacing between icon and text
                Text(
                  'Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          // Description text with proper padding and styling
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}