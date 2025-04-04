import 'package:flutter/material.dart';
import 'package:pim_project/model/domain/highlight_level.dart';

class SmartRegionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool switchValue;
  final ValueChanged<bool> onSwitchChanged;
  final HighlightLevel highlightLevel;

  const SmartRegionCard({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.switchValue,
    required this.onSwitchChanged,
    required this.highlightLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Base background color based on switchValue
    Color baseColor = switchValue ? const Color(0xFF204D4F) : Colors.grey;

    // Define highlight styles without border colors
    BoxDecoration cardDecoration;
    switch (highlightLevel) {
      case HighlightLevel.normal:
        cardDecoration = BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(12),
        );
        break;
      case HighlightLevel.medium:
        cardDecoration = BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(12),
        );
        break;
      case HighlightLevel.danger:
        cardDecoration = BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(12),
        );
        break;
    }

    // Determine subtitle color based on highlightLevel and title
    Color getSubtitleColor() {
      switch (highlightLevel) {
        case HighlightLevel.medium:
          return const Color(0xFFEAA31F); // Warning color
        case HighlightLevel.danger:
          return const Color(0xFFCF2F2F); // Danger color
        case HighlightLevel.normal:
          if (title == "Irrigation") {
            return const Color(0xFF4968FF); // Water safe color
          } else if (title == "Soil") {
            return const Color(0xFFB95C00); // Growth color
          } else {
            return const Color(0xFFB9A900); // Default safe color
          }
      }
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: cardDecoration,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
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
                          color: Color.fromARGB(50, 222, 219, 219),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 30,
                          color: iconColor,
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
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
                const SizedBox(height: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 16, 
                        color: getSubtitleColor(), // Dynamic color based on logic
                        fontWeight: FontWeight.bold, // Always bold
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}