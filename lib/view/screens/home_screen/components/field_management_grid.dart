import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/main.dart';
import 'package:pim_project/view/screens/components/home_cart.dart';
import 'package:pim_project/view/screens/components/land_regionsGrid.dart';
import 'package:pim_project/view_model/connected_region_view_model.dart';
import 'package:pim_project/view_model/land_for_rent_view_model.dart';
import 'package:provider/provider.dart';
import 'feature_card.dart';
import 'package:pim_project/model/services/api_client.dart'; // For Status

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
    return Consumer2<ConnectedRegionViewModel,LandForRentViewModel>(
             builder: (context, regionVM, landVM, child) {
          return SizedBox(
            height: 400,
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
    return SingleChildScrollView(
      key: const ValueKey('grid'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage your fields',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FeatureCard(
                  title: 'My Connected\nRegions',
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
                  title: 'Rent\nLands',
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
                  title: 'Inventory',
                  icon: Icons.inventory_2_outlined,
                  iconBgColor: Colors.orange[100]!,
                  onTap: () => widget.onFeatureSelected('inventory'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FeatureCard(
                  title: 'Balance',
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

  Widget _buildRegionsView(BuildContext context, ConnectedRegionViewModel viewModel) {
    return Column(
      key: const ValueKey('regions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => setState(() => _showRegions = false),
            ),
            Text(
              'My Connected Regions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildContentBasedOnStatus(context, viewModel),
        ),
      ],
    );
  }

  Widget _buildContentBasedOnStatus(BuildContext context, ConnectedRegionViewModel viewModel) {
    switch (viewModel.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.ERROR:
        return Center(child: Text(viewModel.message ?? 'An error occurred'));
      case Status.COMPLETED:
        final regions = viewModel.connectedRegions;
        if (regions == null || regions.isEmpty) {
          return Center(child: Text('No regions available'));
        }
        return LandRegionsGrid(
          landId: widget.landId, // Removed ! operator
          regions: regions,
        );
      case Status.INITIAL:
      default:
        return Center(child: Text('Tap to load regions'));
    }
  }
  Widget _buildRentLandsView(BuildContext context, LandForRentViewModel viewModel) {
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
            ),
            Text(
              'Lands for Rent',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildRentLandsContent(context, viewModel),
        ),
      ],
    );
  }

  Widget _buildRentLandsContent(BuildContext context, LandForRentViewModel viewModel) {
    switch (viewModel.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.ERROR:
        return Center(child: Text(viewModel.message ?? 'An error occurred'));
      case Status.COMPLETED:
        final lands = viewModel.landsForRent;
        if (lands == null || lands.isEmpty) {
          return Center(child: Text('No lands available for rent'));
        }
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
                    "Surface: ${land.surface}m² • ${land.forRent ? 'For Rent' : 'Not Available'}",
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
      case Status.INITIAL:
      default:
        return Center(child: Text('Tap to load lands for rent'));
    }
  }

}

