import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
   final FocusNode focusNode;
  final VoidCallback onFilterTap;
const SearchBar({ 
   required this.controller,
   required this.focusNode,
    required this.onFilterTap,super.key
     });

  @override
  Widget build(BuildContext context){
 return Row(
      children: [
        // Search bar
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: "Search...",
              hintStyle: TextStyle(color: Colors.black54),
              prefixIcon: Icon(Icons.search, color: Colors.black54),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFF6200EA) , width: 1.0),
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
            child: Icon(Icons.filter_list, color: Colors.white),
          ),
        ),
      ],
    );
  }
}