import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/model/domain/region.dart';
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
  
    // Only call `getRegionById` if the region is not already loaded.
    if (viewModel.region == null) {
      Future.microtask(() {
        viewModel.getRegionById(id);
      });
    }

    return Consumer<RegionDetailsViewModel>(
      builder: (context, viewModel, child) {
        final region = viewModel.region;

        // Show a loading indicator or placeholder if region data isn’t loaded yet
        if (region == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

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
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {},
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RegionInfo(
                    regionCount: region.plants.length.toString(), // Number of plants in the region
                    cultivationType: region.name, // Use region name as cultivation type
                    location:  region.land.cordonate, // Display land ID (or fetch land name if available)
                    onAddRegion: () {
                      _showAddPlantDialog(context, region);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                                value: "${region.surface.toStringAsFixed(0)}m²", // Display surface area
                                imageName: "square_foot.png",
                              ),
                              RegionDetailInfocard(
                                title: "Temperature",
                                value: "N/A", // Replace with actual data if available
                                imageName: "thermostat_arrow_up.png",
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RegionDetailInfocard(
                                title: "Humidity",
                                value: "N/A", // Replace with actual data if available
                                imageName: "humidity.png",
                              ),
                              RegionDetailInfocard(
                                title: "Irrigation",
                                value: "N/A", // Replace with actual data if available
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

  void _showAddPlantDialog(BuildContext context, Region region) {
    showDialog(
      context: context,
      builder: (context) => Consumer<RegionDetailsViewModel>(
        builder: (context, viewModel, child) {
          Future.microtask(() {
            if (viewModel.plants.isEmpty) {
              viewModel.loadPlants();
            }
          });

          return AlertDialog(
            title: const Text('Select a Plant'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : viewModel.plants.isEmpty
                      ? const Center(child: Text('No plants available'))
                      : ListView.builder(
                          itemCount: viewModel.plants.length,
                          itemBuilder: (context, index) {
                            final plant = viewModel.plants[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(plant.name)),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () =>
                                            viewModel.decrementQuantity(plant.id),
                                      ),
                                      Text(viewModel.getQuantity(plant.id).toString()),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () =>
                                            viewModel.incrementQuantity(plant.id),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await viewModel.addSelectedPlantsToRegion(region.id);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}