import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onFilterTap;
  final ValueChanged<String>? onChanged; // Already included, just needs to be used
  final AppLocalizations l10n;

  const SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onFilterTap,
    super.key,
    this.onChanged,
    required this.l10n,
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
            decoration: InputDecoration(
              hintText: l10n.search,
              hintStyle: TextStyle(color: Colors.black54),
              prefixIcon: Icon(Icons.search, color: Colors.black54),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFF6200EA), width: 1.0),
              ),
            ),
            onChanged: onChanged, // Connect the callback here
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
            child: Icon(Icons.filter_list, color: Colors.white),
          ),
        ),
      ],
    );
  }
}