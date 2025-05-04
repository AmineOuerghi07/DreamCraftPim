import 'package:flutter/material.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconBgColor;
  final VoidCallback onTap;

  const FeatureCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.iconBgColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive calculations
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600; // Standard breakpoint for tablets
    final isLargeTablet = size.shortestSide >= 900; // For very large tablets or landscape tablets
    
    // Calculate responsive dimensions based on screen size
    // Significantly larger for tablet mode
    final cardHeight = isLargeTablet 
        ? size.height * 0.25 
        : (isTablet 
            ? size.height * 0.22 
            : size.height * 0.18);
            
    // Increased icon size for better visibility on tablets
    final iconSize = isLargeTablet ? 52.0 : (isTablet ? 44.0 : 28.0);
    
    // Larger font size for better readability on tablets
    final fontSize = isLargeTablet ? 20.0 : (isTablet ? 18.0 : 14.0);
    
    // Much larger icon container on tablets
    final iconContainerSize = isLargeTablet 
        ? size.width * 0.12
        : (isTablet 
            ? size.width * 0.10 
            : size.width * 0.1);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20), // Slightly larger radius
      child: Container(
        height: cardHeight,
        constraints: BoxConstraints(
          minHeight: isTablet ? 180 : 120, // Increased minimum height for tablets
          maxHeight: isTablet ? 300 : 180, // Increased maximum height for tablets
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20), // Matching the InkWell radius
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(isTablet ? 0.15 : 0.1), // Slightly stronger shadow on tablets
              spreadRadius: isTablet ? 2 : 1,
              blurRadius: isTablet ? 8 : 4,
              offset: Offset(0, isTablet ? 3 : 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 16.0 : 8.0), // More padding on tablets
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container with responsive size - much larger on tablets
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                constraints: BoxConstraints(
                  minWidth: isTablet ? 80 : 44,
                  minHeight: isTablet ? 80 : 44,
                  maxWidth: isTablet ? 120 : 80,
                  maxHeight: isTablet ? 120 : 80,
                ),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                  // Add subtle gradient for more visual appeal on larger screens
                  gradient: isTablet ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      iconBgColor,
                      Color.alphaBlend(iconBgColor.withOpacity(0.7), Colors.white),
                    ],
                  ) : null,
                  // Enhanced shadow effect for the icon on tablets
                  boxShadow: isTablet ? [
                    BoxShadow(
                      color: iconBgColor.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: iconSize,
                    color: isTablet ? Colors.grey[800] : Colors.grey[700], // Slightly darker on tablets for better contrast
                  ),
                ),
              ),
              
              SizedBox(height: isTablet ? size.height * 0.025 : size.height * 0.015), // More spacing on tablets
              
              // Title with responsive font size - larger on tablets
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 16.0 : 8.0), // More horizontal padding on tablets
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    letterSpacing: isTablet ? 0.5 : 0.2, // Improved letter spacing on tablets
                    height: isTablet ? 1.2 : 1.1, // Better line height for readability
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}