import 'package:flutter/material.dart';

class Header extends StatelessWidget {
   final String profileImage;
  final String greetingText;
  final String username;
const Header({ required this.profileImage,
    required this.greetingText,
    required this.username, super.key });

  @override
  Widget build(BuildContext context){
        return Container(
      color: Colors.white, // Header background color
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(profileImage), // network image after 
              ),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: greetingText,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                    TextSpan(
                      text: username, // database
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Icon(Icons.notifications, color: Colors.green),
        ],
      ),
    );
  }

}