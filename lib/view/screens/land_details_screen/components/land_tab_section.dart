import 'package:flutter/material.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/view/screens/land_details_screen/components/no_plant_component.dart';
import 'package:pim_project/view/screens/land_details_screen/components/no_region_component.dart';
import 'package:pim_project/view_model/land_details_view_model.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/view/screens/components/land_regionsGrid.dart';
import 'package:pim_project/view/screens/components/plants_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class LandTabsSection extends StatelessWidget {
  final String landId;

  const LandTabsSection({
    Key? key,
    required this.landId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isSmallPhone = screenWidth < 360;

    return Column(
      children: [
        // Tab bar
        TabBar(
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          labelStyle: TextStyle(
            fontSize: isTablet ? 18 : (isSmallPhone ? 14 : 16),
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(text: isTablet ? l10n.landRegions : l10n.regions),
            Tab(text: l10n.plants),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Tab views
        Expanded(
          child: TabBarView(
            children: [
              _buildRegionsTab(context),
              _buildPlantsTab(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegionsTab(BuildContext context) {
    return Consumer<LandDetailsViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.regionsResponse.status == Status.LOADING) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.regionsResponse.status == Status.ERROR) {
          return Center(child: Text(viewModel.regionsResponse.message!));
        }
        
        // Show NoRegionComponent if there are no regions
        if (viewModel.regions.isEmpty) {
          return const NoRegionComponent();
        }
        
        return LandRegionsGrid(
          landId: landId,
          regions: viewModel.regions,
        );
      },
    );
  }

  Widget _buildPlantsTab(BuildContext context) {
    return Consumer<LandDetailsViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.plantsResponse.status == Status.LOADING) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.plantsResponse.status == Status.ERROR) {
          return Center(child: Text(viewModel.plantsResponse.message!));
        }
        
        // Show NoPlantComponent if there are no plants
        if (viewModel.plants.isEmpty) {
          return const NoPlantComponent();
        }
        
        return PlantsGrid(landId: landId);
      },
    );
  }
}