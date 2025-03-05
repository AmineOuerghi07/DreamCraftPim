import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/view/screens/Components/region_detail_InfoCard.dart';
import 'package:pim_project/view/screens/Components/region_info.dart';
import 'package:pim_project/view/screens/Components/smart_regionsGrid.dart';
import 'package:pim_project/view/screens/components/connect_to_bleutooth.dart';
import 'package:pim_project/view_model/region_details_view_model.dart';
import 'package:provider/provider.dart';

class RegionDetailsScreen extends StatelessWidget {
  final String id;
  const RegionDetailsScreen({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RegionDetailsViewModel>(context, listen: false);

    if (viewModel.region == null || viewModel.region!.id != id) {
      Future.microtask(() {
        viewModel.getRegionById(id);
      });
    }

    return Consumer<RegionDetailsViewModel>(
      builder: (context, viewModel, child) {
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
                    const PopupMenuItem<String>(
                      value: 'update',
                      child: ListTile(leading: Icon(Icons.edit), title: Text('Update Region')),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(leading: Icon(Icons.delete), title: Text('Delete Region')),
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
                    onAddRegion: () => _navigateToAddPlantScreen(context, region, viewModel),
                    buttonText: "Add Plant",
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
                                title: "Expanse",
                                value: "${region.surface.toStringAsFixed(0)}m²",
                                imageName: "square_foot.png",
                              ),
                              RegionDetailInfocard(
                                title: "Temperature",
                                value: "N/A",
                                imageName: "thermostat_arrow_up.png",
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RegionDetailInfocard(
                                title: "Humidity",
                                value: "N/A",
                                imageName: "humidity.png",
                              ),
                              RegionDetailInfocard(
                                title: "Irrigation",
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
                  const TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.green,
                    tabs: [
                      Tab(text: "Smart Region"),
                      Tab(text: "Plants"),
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

 void _navigateToAddPlantScreen(BuildContext context, Region region, RegionDetailsViewModel viewModel) {
  context.push('${RouteNames.addplantScreen}/${region.id}').then((result) {
    if (result != null && result is Map<String, int>) {
      // Pass the result directly to addSelectedPlantsToRegion
      viewModel.addSelectedPlantsToRegion(region.id, selectedPlants: result);
    }
  });
}

  void _showUpdateRegionDialog(BuildContext context, RegionDetailsViewModel viewModel) {
    final region = viewModel.region!;
    TextEditingController nameController = TextEditingController(text: region.name);
    TextEditingController surfaceController = TextEditingController(text: region.surface.toString());
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Region'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Region Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: surfaceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Surface Area (m²)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (nameController.text.isEmpty || surfaceController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please fill all fields"), backgroundColor: Colors.red),
                            );
                            return;
                          }

                          final surface = double.tryParse(surfaceController.text);
                          if (surface == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Invalid surface value"), backgroundColor: Colors.red),
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
                          );
                          print('Sending update payload: ${updatedRegion.toJson()}');
                          final response = await viewModel.updateRegion(updatedRegion);

                          setState(() => isLoading = false);

                          if (response.status == Status.COMPLETED) {
                            Navigator.of(dialogContext).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response.message ?? "Update failed"), backgroundColor: Colors.red),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, RegionDetailsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this region?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final response = await viewModel.deleteRegion(viewModel.region!.id);
              Navigator.of(context).pop();
              if (response.status == Status.COMPLETED && context.mounted) {
                context.go(RouteNames.land);
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response.message ?? 'Delete failed'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddSensorsDialog(BuildContext context, Region region, RegionDetailsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Sensors'),
        content: const Text('This feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}