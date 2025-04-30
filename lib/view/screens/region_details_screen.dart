import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/view/screens/Components/region_detail_InfoCard.dart';
import 'package:pim_project/view/screens/Components/region_info.dart';
import 'package:pim_project/view/screens/Components/smart_regionsGrid.dart';
import 'package:pim_project/view/screens/components/connect_to_bleutooth.dart';
import 'package:pim_project/view_model/land_details_view_model.dart';
import 'package:pim_project/view_model/region_details_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegionDetailsScreen extends StatelessWidget {
  final String id;
  final LandDetailsViewModel? landDetailsViewModel;
  const RegionDetailsScreen({required this.id,this.landDetailsViewModel, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = Provider.of<RegionDetailsViewModel>(context, listen: false);
    final landVM = landDetailsViewModel ?? context.read<LandDetailsViewModel>();
    if (viewModel.region == null || viewModel.region!.id != id) {
      Future.microtask(() {
        viewModel.getRegionById(id);
      });
    }

    return Consumer<RegionDetailsViewModel>(
      builder: (contextRegionDetailsViewModel, viewModel, child) {
        final regionResponse = viewModel.regionResponse;

        if (regionResponse?.status == Status.LOADING || regionResponse == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (regionResponse.status == Status.ERROR) {
          return Scaffold(body: Center(child: Text(regionResponse.message!)));
        }

        final region = viewModel.region!;
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
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onSelected: (value) => _handleMenuSelection(value, context, viewModel),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'update',
                      child: ListTile(leading: const Icon(Icons.edit), title: Text(l10n.updateRegion)),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(leading: const Icon(Icons.delete), title: Text(l10n.deleteRegion)),
                    ),
                  ],
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RegionInfo(
                    regionCount: region.plants.length.toString(),
                    cultivationType: region.name,
                    location: viewModel.land?.cordonate ?? "Loading...",
                    onAddRegion: () => _navigateToAddPlantScreen(contextRegionDetailsViewModel, region, viewModel, landVM),
                    buttonText: l10n.addPlant,
                    showRegionCount: false,
                    onAddSensors: () => _showAddSensorsDialog(context, region, viewModel),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      margin: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RegionDetailInfocard(
                                title: l10n.expanse,
                                value: "${region.surface.toStringAsFixed(0)}m²",
                                imageName: "square_foot.png",
                              ),
                              RegionDetailInfocard(
                                title: l10n.temperature,
                                value: "N/A",
                                imageName: "thermostat_arrow_up.png",
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RegionDetailInfocard(
                                title: l10n.humidity,
                                value: "N/A",
                                imageName: "humidity.png",
                              ),
                              RegionDetailInfocard(
                                title: l10n.irrigation,
                                value: "N/A",
                                imageName: "humidity_high.png",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.green,
                    tabs: [
                      Tab(text: l10n.smartRegion),
                      Tab(text: l10n.plants),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      children: [
                        SmartRegionsGrid(),
                        ConnectToBluetooth(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleMenuSelection(String value, BuildContext context, RegionDetailsViewModel viewModel) {
    switch (value) {
      case 'update':
        if (viewModel.region != null) _showUpdateRegionDialog(context, viewModel);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(context, viewModel);
        break;
    }
  }

  void _navigateToAddPlantScreen(
    BuildContext context,
    Region region,
    RegionDetailsViewModel regionVM,
    LandDetailsViewModel landVM,
  ) {
    context.push('${RouteNames.addplantScreen}/${region.id}').then((result) async {
      if (result != null && result is Map<String, int>) {
        await regionVM.addSelectedPlantsToRegion(region.id, selectedPlants: result);
        print('Navigation ViewModel instance: $landVM, hash: ${landVM.hashCode}');
        await landVM.fetchPlantsForLand(region.land.id);
        print('Fetch completed for landId: ${region.land.id}, quantity: ${landVM.plants.isNotEmpty ? landVM.plants.first.totalQuantity : "none"}');
      }
    });
  }

  void _showUpdateRegionDialog(BuildContext context, RegionDetailsViewModel viewModel) {
    final region = viewModel.region!;
    TextEditingController nameController = TextEditingController(text: region.name);
    TextEditingController surfaceController = TextEditingController(text: region.surface.toString());
    bool isLoading = false;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.updateRegion),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.regionName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: surfaceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.surfaceArea,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (nameController.text.isEmpty || surfaceController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.pleaseFillAllRequiredFields), backgroundColor: Colors.red),
                            );
                            return;
                          }

                          final surface = double.tryParse(surfaceController.text);
                          if (surface == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.invalidSurfaceValue), backgroundColor: Colors.red),
                            );
                            return;
                          }

                          setState(() => isLoading = true);

                          final updatedRegion = Region(
                            id: region.id,
                            name: nameController.text,
                            surface: surface,
                            land: region.land,
                            sensors: region.sensors,
                            plants: region.plants,
                            isConnected: region.isConnected,
                          );
                          print('Sending update payload: ${updatedRegion.toJson()}');
                          final response = await viewModel.updateRegion(updatedRegion);

                          setState(() => isLoading = false);

                          if (response.status == Status.COMPLETED) {
                            Navigator.of(dialogContext).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response.message ?? l10n.updateFailed), backgroundColor: Colors.red),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(l10n.update),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, RegionDetailsViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final response = await viewModel.deleteRegion(viewModel.region!.id);
              Navigator.of(context).pop();
              if (response.status == Status.COMPLETED && context.mounted) {
                context.go(RouteNames.land);
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response.message ?? l10n.deleteFailed), backgroundColor: Colors.red),
                );
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddSensorsDialog(BuildContext context, Region region, RegionDetailsViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addSensors),
        content: Text(l10n.comingSoon),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
