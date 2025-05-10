import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/view_model/land_details_view_model.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/view_model/land_view_model.dart';
import 'package:pim_project/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Import components
import 'components/land_header.dart';
import 'components/land_stats_section.dart';
import 'components/dialogs/update_land_dialog.dart';
import 'components/dialogs/add_region_dialog.dart';
import 'components/dialogs/rent_dialog.dart';
import 'components/dialogs/delete_confirmation_dialog.dart';
import 'components/land_tab_section.dart';
class LandDetailsScreen extends StatelessWidget {
  final String id;
  const LandDetailsScreen({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LandDetailsViewModel>(
      builder: (context, viewModel, child) {
        // Schedule fetch after the build is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.landResponse.data?.id != id) {
            viewModel.fetchLandById(id);
            viewModel.fetchRegionsForLand(id);
            viewModel.fetchPlantsForLand(id);
          }
        });
        return WillPopScope(
          onWillPop: () async {
            // Fetch updated plants when navigating back
            await viewModel.fetchPlantsForLand(id);
            return true; // Allow navigation
          },
          child: _buildScaffold(context, viewModel.landResponse),
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context, ApiResponse<Land> response) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
          actions: [
            _buildPopupMenu(context, response),
          ],
        ),
        body: _buildBody(context, response),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, ApiResponse<Land> response) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black),
      onSelected: (value) => _handleMenuSelection(value, context),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'update',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text(l10n.updateLand),
          ),
        ),
        PopupMenuItem<String>(
          value: 'toggleRent',
          child: ListTile(
            leading: Icon(
              response.data?.forRent == true 
                  ? Icons.not_interested 
                  : Icons.real_estate_agent,
              color: response.data?.forRent == true 
                  ? Colors.red
                  : Colors.green,
            ),
            title: response.data?.forRent == true 
                ? Text(l10n.disableForRent)
                : Text(l10n.setForRent),
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text(l10n.deleteLand),
          ),
        ),
      ],
    );
  }

  void _handleMenuSelection(String value, BuildContext context) {
    final viewModel = Provider.of<LandDetailsViewModel>(context, listen: false);
    final land = viewModel.landResponse.data;
    
    if (land == null) return;
    
    switch (value) {
      case 'update':
        showUpdateLandDialog(context, land);
        break;
      case 'toggleRent':
        if (land.forRent) {
          showDisableRentDialog(context, viewModel, land);
        } else {
          showSetForRentDialog(context, viewModel, land);
        }
        break;
      case 'delete':
        showDeleteConfirmationDialog(
          context,
          onConfirm: () async {
            await viewModel.deleteLand(id);
            context.go(RouteNames.land);
            if (context.mounted) {
              Provider.of<LandViewModel>(context, listen: false)
                  .fetchLandsByUserId(MyApp.userId);
            }
          }
        );
        break;
    }
  }

  Widget _buildBody(BuildContext context, ApiResponse<Land> response) {
    final l10n = AppLocalizations.of(context)!;
    
    if (response.status == Status.LOADING) {
      return const Center(child: CircularProgressIndicator());
    }

    if (response.status == Status.ERROR) {
      return Center(child: Text(response.message!));
    }

    if (response.data == null) {
      return Center(child: Text(l10n.noLandDataAvailable));
    }

    final land = response.data!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24.0 : 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Land header with region count, name, location
          LandHeader(
            land: land,
            onAddRegion: () => showAddRegionDialog(context, land),
          ),
          
          SizedBox(height: isTablet ? 24 : 16),
          
          // Stats section with info cards
          LandStatsSection(land: land),
          
          SizedBox(height: isTablet ? 24 : 16),
          
          // Tabs section with regions and plants
          Expanded(
            child: LandTabsSection(landId: id),
          ),
        ],
      ),
    );
  }
}