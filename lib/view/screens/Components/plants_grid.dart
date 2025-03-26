import 'package:flutter/material.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/view_model/land_details_view_model.dart';
import 'package:provider/provider.dart';

class PlantsGrid extends StatelessWidget {
  final String landId;

  const PlantsGrid({super.key, required this.landId});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LandDetailsViewModel>(context, listen: false);
    print('PlantsGrid ViewModel instance: $vm');
    return Consumer<LandDetailsViewModel>(
      builder: (context, viewModel, child) {
        print('Consumer rebuilding, plants: ${viewModel.plants.length}, instance: $viewModel');
        final plants = viewModel.plants;

        if (plants.isEmpty && viewModel.plantsResponse.status == Status.LOADING) {
          return const Center(child: CircularProgressIndicator());
        }

        if (plants.isEmpty && viewModel.plantsResponse.status == Status.ERROR) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${viewModel.plantsResponse.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.fetchPlantsForLand(landId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (plants.isEmpty) {
          return const Center(child: Text('No plants found for this land'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: plants.length,
          itemBuilder: (context, index) {
            final plantWithQty = plants[index];
            final plant = plantWithQty.plant;
            print('Building card for ${plant.name}, quantity: ${plantWithQty.totalQuantity}');
            return Card(
              key: ValueKey('${plant.id}_${plantWithQty.totalQuantity}'), // Unique key
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    plant.imageUrl.isNotEmpty
                        ? Image.network(
                            plant.imageUrl,
                            width: 100,
                            height: 100,
                            errorBuilder: (context, error, stackTrace) =>
                                const Image(
                              image: AssetImage("assets/images/cherry.png"),
                              width: 100,
                              height: 100,
                            ),
                          )
                        : const Image(
                            image: AssetImage("assets/images/cherry.png"),
                            width: 100,
                            height: 100,
                          ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(49, 228, 161, 85),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            "Plant",
                            style: TextStyle(
                              color: Color.fromARGB(255, 246, 125, 3),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          plant.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "${plantWithQty.totalQuantity} plants",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}