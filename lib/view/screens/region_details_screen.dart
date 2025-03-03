import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/view/screens/Components/region_detail_InfoCard.dart';
import 'package:pim_project/view/screens/Components/region_info.dart';
import 'package:pim_project/view/screens/Components/smart_regionsGrid.dart';
import 'package:pim_project/view/screens/components/connect_to_bleutooth.dart';
import 'package:pim_project/view_model/region_details_view_model.dart';
import 'package:provider/provider.dart';

class RegionDetailsScreen extends StatefulWidget {
  final String id;
  const RegionDetailsScreen({required this.id, super.key});

  @override
  State<RegionDetailsScreen> createState() => _RegionDetailsScreenState();
}

class _RegionDetailsScreenState extends State<RegionDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch region details after the widget is built
    Future.microtask(() {
      final viewModel = Provider.of<RegionDetailsViewModel>(context, listen: false);
      viewModel.getRegionById(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegionDetailsViewModel>(
      builder: (context, viewModel, child) {
        final region = viewModel.region; // Get the region from the ViewModel

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {},
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RegionInfo(
                    regionCount: "34",
                    cultivationType: "Maze Cultivation",
                    location: "Sfax, Chaaleb",
onAddRegion: () {
  if (region != null) {
    _showAddPlantDialog(context, region!);
  } else {
    // Handle the case where region is null (e.g., show an error message)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Region data is not available')),
    );
  }
},                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      margin: const EdgeInsets.all(12),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RegionDetailInfocard(
                                  title: "Expanse",
                                  value: "3000m²",
                                  imageName: "square_foot.png"),
                              RegionDetailInfocard(
                                  title: "Temperature",
                                  value: "25°C",
                                  imageName: "thermostat_arrow_up.png"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RegionDetailInfocard(
                                  title: "Humidity",
                                  value: "20%",
                                  imageName: "humidity.png"),
                              RegionDetailInfocard(
                                  title: "Irrigation",
                                  value: "50%",
                                  imageName: "humidity_high.png"),
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
                  const Expanded(
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
}

void _showAddPlantDialog(BuildContext context, Region region) {
  showDialog(
    context: context,
    builder: (context) => Consumer<RegionDetailsViewModel>(
      builder: (context, viewModel, child) {
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
                          return ListTile(
                            title: Text(plant.name),
                            onTap: () async {
                              await viewModel.addPlantToRegion(
                                   region, plant.id, );
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
          ),
        );
      },
    ),
  );
}

