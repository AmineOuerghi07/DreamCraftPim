// view/screens/home_screen/components/field_management_grid.dart
import 'package:flutter/material.dart';

import 'package:pim_project/main.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/view/screens/components/app_progress_indicator.dart';
import 'package:pim_project/view/screens/components/land_regionsGrid.dart';
import 'package:pim_project/view/screens/home_screen/components/no_connected_region.dart'; // Import the new component
import 'package:pim_project/view/screens/home_screen/components/no_land_for_rent.dart'; // Import the new component
import 'package:pim_project/view/screens/components/rent_land_card.dart';
import 'package:pim_project/view_model/connected_region_view_model.dart';
import 'package:pim_project/view_model/home_view_model.dart';
import 'package:pim_project/view_model/land_for_rent_view_model.dart';
import 'package:provider/provider.dart';
import 'feature_card.dart'; 
import 'package:pim_project/model/services/api_client.dart'; 
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart'; 

class FieldManagementGrid extends StatefulWidget {
  final Function(String) onFeatureSelected;
  final String? landId;

  const FieldManagementGrid({
    Key? key,
    required this.onFeatureSelected,
    this.landId,
  }) : super(key: key);

  @override
  _FieldManagementGridState createState() => _FieldManagementGridState();
}

class _FieldManagementGridState extends State<FieldManagementGrid> {
  bool _showRegions = false;
  bool _showRentLands = false;

  @override
  Widget build(BuildContext context) {
   // final l10n = AppLocalizations.of(context)!;
    // Get screen dimensions
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    
    // Calculate responsive height for grid container
    final gridHeight = isTablet ? size.height * 0.6 : size.height * 0.45;
    final gridHeightConstraint = isTablet ? 600.0 : 400.0;
    
    return Consumer2<ConnectedRegionViewModel, LandForRentViewModel>(
      builder: (context, regionVM, landVM, child) {
        return Container(
          height: gridHeight,
          constraints: BoxConstraints(
            maxHeight: gridHeightConstraint,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final slideAnimation = Tween<Offset>(
                begin: Offset(
                    _showRegions || _showRentLands ? 1.0 : -1.0, 0.0),
                end: Offset.zero,
              ).animate(animation);
              return SlideTransition(
                position: slideAnimation,
                child: child,
              );
            },
            child: _showRegions
                ? _buildRegionsView(context, regionVM)
                : _showRentLands
                    ? _buildRentLandsContent(context, landVM)
                    : _buildGridView(context),
          ),
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    final isLandscape = size.width > size.height;
    
    // Use different layout for landscape/tablet
    if (isTablet && isLandscape) {
      // 4 cards in a row for landscape tablets
      return SingleChildScrollView(
        key: const ValueKey('grid'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    title: l10n.myConnectedRegions,
                    icon: Icons.cloud_outlined,
                    iconBgColor: Colors.blue[100]!,
                    onTap: () {
                      setState(() => _showRegions = true);
                      widget.onFeatureSelected('regions');
                      Provider.of<ConnectedRegionViewModel>(context, listen: false)
                          .fetchConnectedRegions(MyApp.userId);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FeatureCard(
                    title: l10n.rentLands,
                    icon: Icons.eco_outlined,
                    iconBgColor: Colors.green[100]!,
                    onTap: () {
                      setState(() {
                        _showRegions = false;
                        _showRentLands = true;
                      });
                      widget.onFeatureSelected('lands');
                      Provider.of<LandForRentViewModel>(context, listen: false)
                          .fetchLandsForRent();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FeatureCard(
                    title: l10n.aiAssistant, // Changed from inventory to AI Assistant
                    icon: Icons.smart_toy_outlined, // Changed icon to represent AI/chatbot
                    iconBgColor: Colors.purple[100]!, // Changed color for visual distinction
                    onTap: () {
                      // Navigate to the chat screen using GoRouter
                      context.push(RouteNames.chatScreen);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FeatureCard(
                    title: l10n.balance,
                    icon: Icons.account_balance_wallet_outlined,
                    iconBgColor: Colors.yellow[100]!,
                    onTap: () {
                      widget.onFeatureSelected('balance');
                      // Navigate to the billing screen using GoRouter
                      context.push(RouteNames.billingScreen);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // 2x2 grid layout for portrait or phones
      return SingleChildScrollView(
        key: const ValueKey('grid'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    title: l10n.myConnectedRegions,
                    icon: Icons.cloud_outlined,
                    iconBgColor: Colors.blue[100]!,
                    onTap: () {
                      setState(() => _showRegions = true);
                      widget.onFeatureSelected('regions');
                      Provider.of<ConnectedRegionViewModel>(context, listen: false)
                          .fetchConnectedRegions(MyApp.userId);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FeatureCard(
                    title: l10n.rentLands,
                    icon: Icons.eco_outlined,
                    iconBgColor: Colors.green[100]!,
                    onTap: () {
                      setState(() {
                        _showRegions = false;
                        _showRentLands = true;
                      });
                      widget.onFeatureSelected('lands');
                      Provider.of<LandForRentViewModel>(context, listen: false)
                          .fetchLandsForRent();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    title: l10n.aiAssistant, // AI Assistant
                    icon: Icons.smart_toy_outlined, // Changed icon to represent AI/chatbot
                    iconBgColor: Colors.purple[100]!, // Changed color for visual distinction
                    onTap: () {
                      // Navigate to the chat screen using GoRouter
                      context.push(RouteNames.chatScreen);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FeatureCard(
                    title: l10n.balance,
                    icon: Icons.account_balance_wallet_outlined,
                    iconBgColor: Colors.yellow[100]!,
                    onTap: () {
                      widget.onFeatureSelected('balance');
                      // Navigate to the billing screen using GoRouter
                      context.push(RouteNames.billingScreen);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildRegionsView(BuildContext context, ConnectedRegionViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    return Column(
      key: const ValueKey('regions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => setState(() => _showRegions = false),
              iconSize: isTablet ? 28 : 24,
            ),
            Text(
              l10n.myConnectedRegions,
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 20 : 16),
        Expanded(
          child: _buildContentBasedOnStatus(context, viewModel),
        ),
      ],
    );
  }

Widget _buildContentBasedOnStatus(BuildContext context, ConnectedRegionViewModel viewModel) {
  final l10n = AppLocalizations.of(context)!;
  final size = MediaQuery.of(context).size;
  final isTablet = size.shortestSide >= 600;

  // Get the HomeViewModel to check for noRegionsFound status
  final homeViewModel = Provider.of<HomeViewModel>(context, listen: true);

  switch (viewModel.status) {
    case Status.LOADING:
      return Center(
        child:  AppProgressIndicator(
  loadingText: 'Growing data...',
  primaryColor: const Color(0xFF4CAF50), // Green
  secondaryColor: const Color(0xFF8BC34A), // Light Green
  size: 75, // Controls the overall size
),
      );
    case Status.ERROR:
      return Center(
        child: Text(
          viewModel.message ?? l10n.anErrorOccurred,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
          ),
        ),
      );
    case Status.COMPLETED:
      final regions = viewModel.connectedRegions;
      if (regions.isEmpty || homeViewModel.noRegionsFound) {
        // Use the NoConnectedRegion component here
        return NoConnectedRegion(
          onTryAgain: () {
            Provider.of<ConnectedRegionViewModel>(context, listen: false)
              .fetchConnectedRegions(MyApp.userId);
          },
        );
      }
      return LandRegionsGrid(
        landId: widget.landId,
        regions: regions,
      );
    case Status.INITIAL:
      return Center(
        child: Text(
          l10n.tapToLoadRegions,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
          ),
        ),
      );
  }
}
  
  
Widget _buildRentLandsContent(BuildContext context, LandForRentViewModel viewModel) {
  final l10n = AppLocalizations.of(context)!;
  final size = MediaQuery.of(context).size;
  final isTablet = size.shortestSide >= 600;

  return Column(
    key: const ValueKey('rentLands'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => setState(() => _showRentLands = false),
            iconSize: isTablet ? 28 : 24,
          ),
          Text(
            l10n.rentLands,
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      SizedBox(height: isTablet ? 20 : 16),
      Expanded(
        child: _buildRentLandsContentBasedOnStatus(context, viewModel),
      ),
    ],
  );
}

Widget _buildRentLandsContentBasedOnStatus(BuildContext context, LandForRentViewModel viewModel) {
  final l10n = AppLocalizations.of(context)!;
  final size = MediaQuery.of(context).size;
  final isTablet = size.shortestSide >= 600;
  final isLandscape = size.width > size.height;

  switch (viewModel.status) {
    case Status.LOADING:
      return Center(
        child:  AppProgressIndicator(
  loadingText: 'Growing data...',
  primaryColor: const Color(0xFF4CAF50), // Green
  secondaryColor: const Color(0xFF8BC34A), // Light Green
  size: 75, // Controls the overall size
),
      );
    case Status.ERROR:
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              viewModel.message ?? l10n.anErrorOccurred,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.fetchLandsForRent(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    case Status.COMPLETED:
      final lands = viewModel.landsForRent;
      // Check both if lands array is empty OR if the noLandsFound flag is true
      if (lands.isEmpty || viewModel.noLandsFound) {
        // Use the NoLandForRent component here
        return NoLandForRent(
          onTryAgain: () {
            viewModel.fetchLandsForRent();
          },
        );
      }
      
      // Responsive grid for tablets in landscape
      if (isTablet && isLandscape) {
        return GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns for landscape tablets
            childAspectRatio: 1.2, // Adjusted for better proportions
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: lands.length,
          itemBuilder: (context, index) {
            final land = lands[index];
            return RentLandCard(land: land);
          },
        );
      } else if (isTablet && !isLandscape) {
        // Special grid for tablets in portrait
        return GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, // Single column but with grid sizing for tablets portrait
            childAspectRatio: 2.0,
            mainAxisSpacing: 16,
          ),
          itemCount: lands.length,
          itemBuilder: (context, index) {
            final land = lands[index];
            return RentLandCard(land: land);
          },
        );
      } else {
        // Default list view for phones
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          itemCount: lands.length,
          itemBuilder: (context, index) {
            final land = lands[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: RentLandCard(land: land),
            );
          },
        );
      }
    case Status.INITIAL:
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.tapToLoadLands,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.fetchLandsForRent(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
  }
}

}