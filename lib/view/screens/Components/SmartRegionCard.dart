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
    Color baseColor = switchValue ? const Color(0xFF204D4F) : const Color(0xFF505050);

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
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: cardDecoration,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            height: 140, // Fixed height to prevent overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row with value and icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Value Container (left side)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: getSubtitleColor(),
                        ),
                      ),
                    ),
                    
                    // Icon Container (right side)
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 22,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
                
                // Expanded space for center alignment
                Expanded(
                  child: Center(
                    // Center text
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                // Bottom switch with elegant design
                Center(
                  child: GestureDetector(
                    onTap: () => onSwitchChanged(!switchValue),
                    child: Container(
                      width: 62,
                      height: 32,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: switchValue 
                          ? Colors.green.withOpacity(0.3) 
                          : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: switchValue 
                            ? Colors.green.shade400 
                            : Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        alignment: switchValue 
                          ? Alignment.centerRight 
                          : Alignment.centerLeft,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: switchValue 
                              ? Colors.green.shade500 
                              : Colors.grey.shade500,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              switchValue ? Icons.check : Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}