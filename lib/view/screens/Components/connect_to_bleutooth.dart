import 'package:flutter/material.dart';

class ConnectToBleutooth extends StatelessWidget {
  const ConnectToBleutooth({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Image(image: AssetImage("../assets/images/graph_3.png")),
        const SizedBox(height: 12),
        const Text(
          "Want to connect Your Device with Your System ? ",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          " Make sure to enable the Permission of  ",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          " Bluetooth",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {},
          child: Text("Connect Your Device",
              style: const TextStyle(fontSize: 18, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 23, 106, 26),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      ],
    );
  }
}
