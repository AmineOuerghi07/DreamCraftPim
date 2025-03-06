import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onFilterTap;
  final ValueChanged<String> onChanged; // ✅ Correction ici

  const SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onFilterTap,
    required this.onChanged, // ✅ Ajouté ici
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search bar
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged, // ✅ Correction ici
            decoration: InputDecoration(
              hintText: "Search...",
              hintStyle: const TextStyle(color: Colors.black54),
              prefixIcon: const Icon(Icons.search, color: Colors.black54),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF6200EA), width: 1.0),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Filter button
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
