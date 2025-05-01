import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/main.dart';
import 'package:pim_project/view/screens/components/home_cart.dart';
import 'package:pim_project/view/screens/components/land_regionsGrid.dart';
import 'package:pim_project/view_model/connected_region_view_model.dart';
import 'package:pim_project/view_model/land_for_rent_view_model.dart';
import 'package:provider/provider.dart';
import 'feature_card.dart'; // Your responsive FeatureCard
import 'package:pim_project/model/services/api_client.dart'; // For Status
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
                    ? _buildRentLandsView(context, landVM)
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
                    title: l10n.inventory,
                    icon: Icons.inventory_2_outlined,
                    iconBgColor: Colors.orange[100]!,
                    onTap: () => widget.onFeatureSelected('inventory'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FeatureCard(
                    title: l10n.balance,
                    icon: Icons.account_balance_wallet_outlined,
                    iconBgColor: Colors.yellow[100]!,
                    onTap: () => widget.onFeatureSelected('balance'),
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
                    title: l10n.inventory,
                    icon: Icons.inventory_2_outlined,
                    iconBgColor: Colors.orange[100]!,
                    onTap: () => widget.onFeatureSelected('inventory'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FeatureCard(
                    title: l10n.balance,
                    icon: Icons.account_balance_wallet_outlined,
                    iconBgColor: Colors.yellow[100]!,
                    onTap: () => widget.onFeatureSelected('balance'),
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

    switch (viewModel.status) {
      case Status.LOADING:
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: isTablet ? 4.0 : 3.0,
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
        if (regions.isEmpty) {
          return Center(
            child: Text(
              l10n.noRegionsAvailable,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
              ),
            ),
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

  Widget _buildRentLandsView(BuildContext context, LandForRentViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    return Column(
      key: const ValueKey('rent_lands'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => setState(() {
                _showRentLands = false;
              }),
              iconSize: isTablet ? 28 : 24,
            ),
            Text(
              l10n.landsForRent,
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 20 : 16),
        Expanded(
          child: _buildRentLandsContent(context, viewModel),
        ),
      ],
    );
  }

  Widget _buildRentLandsContent(BuildContext context, LandForRentViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    switch (viewModel.status) {
      case Status.LOADING:
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: isTablet ? 4.0 : 3.0,
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
        final lands = viewModel.landsForRent;
        if (lands.isEmpty) {
          return Center(
            child: Text(
              l10n.noLandsForRent,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          );
        }
        
        // Responsive grid for tablets in landscape
        if (isTablet && MediaQuery.of(context).orientation == Orientation.landscape) {
          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two columns for landscape tablets
              childAspectRatio: 2.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: lands.length,
            itemBuilder: (context, index) {
              final land = lands[index];
              return HomeCart(
                title: land.name,
                location: land.cordonate,
                description:
                    "${l10n.surface}: ${land.surface}m² • ${land.forRent ? l10n.forRent : l10n.notAvailable}",
                imageUrl: land.image.isNotEmpty
                    ? AppConstants.imagesbaseURL + land.image
                    : 'assets/images/placeholder.png',
                id: land.id,
                onDetailsTap: () {
                  GoRouter.of(context).push('/land-details/${land.id}');
                },
              );
            },
          );
        } else {
          // Default list view for phones and portrait orientation
          return ListView.builder(
            itemCount: lands.length,
            itemBuilder: (context, index) {
              final land = lands[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: HomeCart(
                  title: land.name,
                  location: land.cordonate,
                  description:
                      "${l10n.surface}: ${land.surface}m² • ${land.forRent ? l10n.forRent : l10n.notAvailable}",
                  imageUrl: land.image.isNotEmpty
                      ? AppConstants.imagesbaseURL + land.image
                      : 'assets/images/placeholder.png',
                  id: land.id,
                  onDetailsTap: () {
                    GoRouter.of(context).push('/land-details/${land.id}');
                  },
                ),
              );
            },
          );
        }
      case Status.INITIAL:
        return Center(
          child: Text(
            l10n.tapToLoadLands,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
            ),
          ),
        );
    }
  }
}