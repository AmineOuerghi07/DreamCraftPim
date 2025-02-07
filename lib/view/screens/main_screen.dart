import 'package:flutter/material.dart';
import 'package:pim_project/view/screens/Components/bottomNavigationBar.dart';


class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child, // ✅ Displays the selected screen
      bottomNavigationBar: const BottomNavigationBarWidget(), // ✅ Always visible
    );
  }
}
