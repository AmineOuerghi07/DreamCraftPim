// view/screens/components/region_info.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegionInfo extends StatelessWidget {
  final String regionCount;
  final String cultivationType;
  final String location;
  final VoidCallback onAddRegion;
  final String buttonText;
  final bool showRegionCount; // New parameter to toggle region count or button
  final VoidCallback? onAddSensors; // Optional callback for "Add Sensors"

  const RegionInfo({
    super.key,
    required this.regionCount,
    required this.cultivationType,
    required this.location,
    required this.onAddRegion,
    required this.buttonText,
    this.showRegionCount = true, // Default to showing region count
    this.onAddSensors,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isSmallPhone = screenWidth < 360;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column with info
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              showRegionCount
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 12, 
                        vertical: isTablet ? 4 : 0
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(50, 68, 206, 155),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "$regionCount Regions",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                          fontSize: isTablet ? 16 : (isSmallPhone ? 12 : 14),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: onAddSensors,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 16 : 12, 
                          vertical: isTablet ? 8 : 6
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          l10n.addSensors,
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 16 : (isSmallPhone ? 12 : 14),
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                cultivationType,
                style: TextStyle(
                  fontSize: isTablet ? 28 : (isSmallPhone ? 20 : 24),
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isTablet ? 8 : 4),
              Row(
                children: [
                  Icon(Icons.location_pin, 
                    size: isTablet ? 20 : 16, 
                    color: Colors.grey
                  ),
                  SizedBox(width: isTablet ? 6 : 4),
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: isTablet ? 18 : (isSmallPhone ? 14 : 16),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Right Column: Add Button and Image
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onAddRegion,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 12, 
                    vertical: isTablet ? 8 : 6
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 16 : (isSmallPhone ? 12 : 14),
                    ),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              
            ],
          ),
        ),
      ],
    );
  }
}