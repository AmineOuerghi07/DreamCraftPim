import 'package:flutter/material.dart';

class SmartRegionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool switchValue;
  final ValueChanged<bool> onSwitchChanged;

  const SmartRegionCard({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.switchValue,
    required this.onSwitchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF204D4F), // Dark green color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 46,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(
                            50, 222, 219, 219), // Semi-transparent light gray
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 30,
                        color: iconColor,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8, // Adjust the scale value to make it smaller
                      child: Switch(
                        value: switchValue,
                        onChanged: onSwitchChanged,
                        activeColor: Colors.white,
                        activeTrackColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
