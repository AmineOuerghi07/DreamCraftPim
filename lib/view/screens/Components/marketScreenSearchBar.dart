import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/ProviderClasses/market_provider.dart';

class Marketscreensearchbar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap; // ✅ Add this

  const Marketscreensearchbar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onFilterTap, // ✅ Ensure it's required
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: "Search...",
              hintStyle: const TextStyle(color: Colors.black54),
              prefixIcon: const Icon(Icons.search, color: Colors.black54),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                    color: Color(0xFF6200EA), width: 1.0),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onFilterTap, // ✅ Use the callback here
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              marketProvider.changefilterIcon
                  ? Icons.filter_list_off
                  : Icons.filter_list,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
