// view/screens/components/CardTopIndicator.dart
import 'package:flutter/material.dart';
import 'package:pim_project/model/domain/highlight_level.dart';

class CardTopIndicator extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String subtitle;
  final HighlightLevel highlightLevel;
  final String title; // Needed for determining subtitle color
  final bool isDisabled;

  const CardTopIndicator({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.subtitle,
    required this.highlightLevel,
    required this.title,
    required this.isDisabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    // Format the display value
    String displayValue = _formatDisplayValue(title, subtitle);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Value Container (left side) - with shimmer effect while loading
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 12 : 10, 
            vertical: isTablet ? 8 : 6
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            displayValue,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: getSubtitleColor(),
            ),
          ),
        ),
        
        // Icon Container (right side)
        Container(
          width: isTablet ? 42 : 38,
          height: isTablet ? 42 : 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: isTablet ? 24 : 22,
            color: isDisabled ? Colors.white70 : iconColor,
          ),
        ),
      ],
    );
  }
  
  // Format the display value for better readability based on sensor type
  String _formatDisplayValue(String title, String subtitle) {
    // For sensors with potential complex formatting needs
    switch (title) {
      case "Lighting":
        if (subtitle.contains("Detected") && subtitle.contains("On")) {
          return "On (Light)";
        } else if (subtitle.contains("Detected") && subtitle.contains("Off")) {
          return "Off (Light)";
        } else if (subtitle.contains("Not detected") && subtitle.contains("On")) {
          return "On (Dark)";
        } else if (subtitle.contains("Not detected") && subtitle.contains("Off")) {
          return "Off (Dark)";
        } else {
          return subtitle;
        }
        
      case "Irrigation":
        if (subtitle.contains("Active")) {
          return "Active";
        } else {
          return "Inactive";
        }
        
      case "Ventilator":
        if (subtitle.contains("Active")) {
          return "Active";
        } else {
          return "Inactive";
        }
        
      case "Soil":
        // Return exactly "Dry" or "Moist"
        if (subtitle.contains("Dry")) {
          return "Dry";
        } else if (subtitle.contains("Moist")) {
          return "Moist";
        } else {
          return subtitle;
        }
        
      default:
        // For Temperature, Humidity, and others, use original
        return subtitle;
    }
  }

  // Determine subtitle color based on highlightLevel and title
  Color getSubtitleColor() {
    if (isDisabled) {
      return Colors.white70; // Disabled text color
    }
    
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
        } else if (title == "Humidity") {
          return const Color(0xFF4968FF); // Blue for humidity
        } else if (title == "Temperature") {
          return const Color(0xFFFF6B4A); // Warm color for temperature
        } else {
          return const Color(0xFFB9A900); // Default safe color
        }
    }
  }
}