// view/screens/components/SmartRegionCard.dart
import 'package:flutter/material.dart';
import 'package:pim_project/model/domain/highlight_level.dart';

import 'package:pim_project/view/screens/region_details_screen/components/card_top_indicator.dart';

class SmartRegionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool switchValue;
  final ValueChanged<bool> onSwitchChanged;
  final HighlightLevel highlightLevel;
  final bool isDisabled;

  const SmartRegionCard({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.switchValue,
    required this.onSwitchChanged,
    required this.highlightLevel,
    required this.isDisabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    
    // Base background color based on switchValue and isDisabled
    Color baseColor;
    if (isDisabled) {
      baseColor = const Color(0xFF9E9E9E); // Disabled grey color
    } else {
      baseColor = switchValue ? const Color(0xFF204D4F) : const Color(0xFF505050);
    }

    // Add subtle gradient effect
    LinearGradient cardGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor,
        Color.lerp(baseColor, Colors.black, 0.2) ?? baseColor,
      ],
    );

    // Define card decoration without borders and shadows
    BoxDecoration cardDecoration = BoxDecoration(
      gradient: cardGradient,
      borderRadius: BorderRadius.circular(16),
      // Removed border
      // Removed box shadow
    );

    return Card(
      elevation: 0, // No additional elevation as we're using custom shadows
      margin: EdgeInsets.all(isTablet ? 6 : 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: cardDecoration,
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 12 : 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Using the new CardTopIndicator component
              CardTopIndicator(
                icon: icon,
                iconColor: iconColor,
                subtitle: subtitle,
                highlightLevel: highlightLevel,
                title: title,
                isDisabled: isDisabled,
              ),
              
              // Expanded space for center alignment
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: isDisabled ? Colors.white70 : Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
              // Bottom switch with elegant design
              Center(
                child: GestureDetector(
                  onTap: isDisabled ? null : () => onSwitchChanged(!switchValue),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isTablet ? 70 : 62,
                    height: isTablet ? 36 : 32,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isDisabled
                        ? Colors.grey.withOpacity(0.3)
                        : (switchValue 
                            ? Colors.green.withOpacity(0.3) 
                            : Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDisabled
                          ? Colors.grey.shade400
                          : (switchValue 
                              ? Colors.green.shade400 
                              : Colors.grey.shade400),
                        width: 1.5,
                      ),
                      // Removed BoxShadow from switch
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      alignment: switchValue 
                        ? Alignment.centerRight 
                        : Alignment.centerLeft,
                      child: Container(
                        width: isTablet ? 30 : 26,
                        height: isTablet ? 30 : 26,
                        decoration: BoxDecoration(
                          color: isDisabled
                            ? Colors.grey.shade500
                            : (switchValue 
                                ? Colors.green.shade500 
                                : Colors.grey.shade500),
                          shape: BoxShape.circle,
                          // Removed BoxShadow from switch thumb
                        ),
                        child: Center(
                          child: Icon(
                            switchValue ? Icons.check : Icons.close,
                            size: isTablet ? 18 : 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Status indicator (new)
              if (highlightLevel != HighlightLevel.normal)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        highlightLevel == HighlightLevel.danger 
                            ? Icons.warning_amber_rounded 
                            : Icons.info_outline,
                        size: isTablet ? 14 : 12,
                        color: _getStatusColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        highlightLevel == HighlightLevel.danger 
                            ? 'Attention required' 
                            : 'Check recommended',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          color: _getStatusColor(),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method for status indicator color
  Color _getStatusColor() {
    if (isDisabled) {
      return Colors.white70;
    }
    
    return highlightLevel == HighlightLevel.danger
        ? const Color(0xFFCF2F2F)  // Danger color
        : const Color(0xFFEAA31F); // Warning color
  }
}