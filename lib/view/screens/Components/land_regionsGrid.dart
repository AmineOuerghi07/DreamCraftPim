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
          padding: EdgeInsets.all(isTablet ? 16.0 : 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: isTablet ? 16 : 12),
                child: Image(
                  image: const AssetImage("assets/images/plant.png"),
                  width: isTablet ? 80 : 60,
                  height: isTablet ? 80 : 60,
                ),
              ),
              SizedBox(height: isTablet ? 10 : 8),
              Text(
                region.name,
                style: TextStyle(
                  fontSize: isTablet ? 22 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isTablet ? 22 : 8),
              // Responsive layout for info section
              if (isTablet) 
                // Tablet layout - horizontal arrangement with more space
                buildTabletInfoSection(region, l10n)
              else 
                // Phone layout - more compact
                buildPhoneInfoSection(region, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTabletInfoSection(Region region, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Sensors info
        Column(
          children: [
            const Icon(Icons.sensors, size: 28, color: Colors.green),
            const SizedBox(height: 8),
            Text(
              "${region.sensors.length}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              l10n.sensors,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        
        // Plants info
        Column(
          children: [
            const Icon(Icons.grass, size: 28, color: Colors.green),
            const SizedBox(height: 8),
            Text(
              "${region.plants.length}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              l10n.plants,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        
        // Irrigation info
        Column(
          children: [
            const Icon(Icons.water_drop, size: 28, color: Colors.green),
            const SizedBox(height: 8),
            const Text(
              "60%",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              l10n.irrigation,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildPhoneInfoSection(Region region, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.sensors, size: 20, color: Colors.green),
            SizedBox(height: 12),
            Icon(Icons.grass, size: 20, color: Colors.green),
            SizedBox(height: 12),
            Icon(Icons.water_drop, size: 20, color: Colors.green),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${region.sensors.length} ${l10n.sensors}",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              "${region.plants.length} ${l10n.plants}",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              "60% ${l10n.irrigation}",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  int calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) return 4;
    if (screenWidth >= 900) return 3;
    if (screenWidth >= 600) return 2;
    return 2;
  }

  double getChildAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) return 1.1;
    if (screenWidth >= 900) return 1.0;
    if (screenWidth >= 600) return 0.9; // Slightly taller cards for tablets
    return 0.8; // Original aspect ratio for phones
  }
}