// view/screens/components/land_regionsGrid.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/view_model/land_details_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LandRegionsGrid extends StatelessWidget {
  final String ?landId;
  final List<Region> regions;

  const LandRegionsGrid({
    super.key,
    required this.landId,
    required this.regions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    if (regions.isEmpty) {
      return Center(child: Text(l10n.noRegionsFound));
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12.0 : 4.0,
        vertical: isTablet ? 8.0 : 0.0,
      ),
      child: GridView.builder(
        padding: EdgeInsets.all(isTablet ? 8.0 : 4.0),
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: calculateCrossAxisCount(context),
          childAspectRatio: getChildAspectRatio(context),
          crossAxisSpacing: isTablet ? 16 : 8,
          mainAxisSpacing: isTablet ? 16 : 8,
        ),
        itemCount: regions.length,
        itemBuilder: (context, index) {
          final region = regions[index];
          return buildRegionCard(context, region, isTablet);
        },
      ),
    );
  }

  Widget buildRegionCard(BuildContext context, Region region, bool isTablet) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallPhone = screenWidth < 360;
    final isP30Pro = screenWidth >= 360 && screenWidth <= 420; // Target P30 Pro size range
    
    // Adjust sizes specifically for P30 Pro
    final imageSize = isTablet ? 80.0 : (isSmallPhone ? 40.0 : (isP30Pro ? 45.0 : 50.0));
    
    return GestureDetector(
      onTap: () {
        if (landId != null) {
          final landDetailsVM = context.read<LandDetailsViewModel>();
          context.push(
            '${RouteNames.regionDetails}/${region.id}',
            extra: landDetailsVM,
          );
        } else {
          context.push('${RouteNames.regionDetails}/${region.id}');
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        ),
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 16.0 : (isP30Pro ? 4.0 : 8.0)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image section
                  Padding(
                    padding: EdgeInsets.only(top: isTablet ? 16 : 4),
                    child: Image(
                      image: const AssetImage("assets/images/plant.png"),
                      width: imageSize,
                      height: imageSize,
                    ),
                  ),
                  
                  // Name section
                  SizedBox(height: isTablet ? 10 : 2),
                  Text(
                    region.name,
                    style: TextStyle(
                      fontSize: isTablet ? 22 : (isSmallPhone ? 14 : (isP30Pro ? 15 : 18)),
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  
                  // Space before info section
                  SizedBox(height: isTablet ? 22 : (isP30Pro ? 12 : 8)),
                  
                  // Info section - flexible layout
                  if (isTablet) 
                    // Tablet layout - horizontal arrangement with more space
                    buildTabletInfoSection(region, l10n)
                  else if (isP30Pro)
                    // Special compact layout for P30 Pro
                    buildP30ProInfoSection(region, l10n)
                  else
                    // Other phones layout
                    buildCompactPhoneInfoSection(region, l10n, isSmallPhone),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  // Special layout for P30 Pro to prevent overflow
  Widget buildP30ProInfoSection(Region region, AppLocalizations l10n) {
    return Flexible(
      fit: FlexFit.loose,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icons column
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sensors, size: 16, color: Colors.green),
              SizedBox(height: 6),
              Icon(Icons.grass, size: 16, color: Colors.green),
              SizedBox(height: 6),
              Icon(Icons.water_drop, size: 16, color: Colors.green),
            ],
          ),
          
          SizedBox(width: 8),
          
          // Text column
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${region.sensors.length} ${l10n.sensors}",
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                Text(
                  "${region.plants.length} ${l10n.plants}",
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                Text(
                  "60% ${l10n.irrigation}",
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTabletInfoSection(Region region, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Sensors info
        Expanded(
          child: Column(
            children: [
              const Icon(Icons.sensors, size: 28, color: Colors.green),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "${region.sensors.length}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  l10n.sensors,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        
        // Plants info
        Expanded(
          child: Column(
            children: [
              const Icon(Icons.grass, size: 28, color: Colors.green),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "${region.plants.length}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  l10n.plants,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        
        // Irrigation info
        Expanded(
          child: Column(
            children: [
              const Icon(Icons.water_drop, size: 28, color: Colors.green),
              const SizedBox(height: 8),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "60%",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  l10n.irrigation,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Original more compact phone layout
  Widget buildCompactPhoneInfoSection(Region region, AppLocalizations l10n, bool isSmallPhone) {
    final iconSize = isSmallPhone ? 14.0 : 18.0;
    final fontSize = isSmallPhone ? 12.0 : 14.0;
    final spacingHeight = isSmallPhone ? 8.0 : 10.0;
    
    return Flexible(
      fit: FlexFit.loose,
      child: Container(
        width: double.infinity,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.sensors, size: iconSize, color: Colors.green),
                SizedBox(height: spacingHeight),
                Icon(Icons.grass, size: iconSize, color: Colors.green),
                SizedBox(height: spacingHeight),
                Icon(Icons.water_drop, size: iconSize, color: Colors.green),
              ],
            ),
            SizedBox(width: isSmallPhone ? 8 : 12),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${region.sensors.length} ${l10n.sensors}",
                    style: TextStyle(fontSize: fontSize),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: spacingHeight),
                  Text(
                    "${region.plants.length} ${l10n.plants}",
                    style: TextStyle(fontSize: fontSize),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: spacingHeight),
                  Text(
                    "60% ${l10n.irrigation}",
                    style: TextStyle(fontSize: fontSize),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) return 4;
    if (screenWidth >= 900) return 3;
    if (screenWidth >= 600) return 2;
    return 2; // For phones, always use 2 columns
  }

  double getChildAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) return 1.1;
    if (screenWidth >= 900) return 1.0;
    if (screenWidth >= 600) return 0.9; // Tablets
    if (screenWidth >= 360 && screenWidth <= 420) return 0.85; // P30 Pro specific
    if (screenWidth < 360) return 0.7; // Small phones
    return 0.8; // Regular phones
  }
}