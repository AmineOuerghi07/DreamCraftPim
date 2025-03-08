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
    super.key,
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

    // Define highlight styles
    BoxDecoration cardDecoration;
    Color subtitleColor;
    switch (highlightLevel) {
      case HighlightLevel.normal:
        cardDecoration = BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(12),
        );
        subtitleColor = Colors.white70;
        break;
      case HighlightLevel.medium:
        cardDecoration = BoxDecoration(
          gradient: LinearGradient(
            colors: [
              baseColor,
              Colors.yellow.withOpacity(0.3), // Subtle yellow tint
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.yellow, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        );
        subtitleColor = Colors.yellow[200]!; // Lighter yellow for readability
        break;
      case HighlightLevel.danger:
        cardDecoration = BoxDecoration(
          gradient: LinearGradient(
            colors: [
              baseColor,
              Colors.red.withOpacity(0.4), // Subtle red tint
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 2,
            ),
          ],
        );
        subtitleColor = Colors.red[300]!; // Lighter red for readability
        break;
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
                        fontSize: 14,
                        color: subtitleColor,
                        fontWeight: highlightLevel == HighlightLevel.danger
                            ? FontWeight.bold
                            : FontWeight.normal,
                        shadows: highlightLevel != HighlightLevel.normal
                            ? [
                                Shadow(
                                  color: subtitleColor.withOpacity(0.6),
                                  blurRadius: 2,
                                  offset: const Offset(1, 1),
                                ),
                              ]
                            : null,
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