import 'package:flutter/material.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/view_model/land_details_view_model.dart';
import 'package:provider/provider.dart';

class PlantsGrid extends StatelessWidget {
  final String landId;

  const PlantsGrid({super.key, required this.landId});

  @override
  Widget build(BuildContext context) {
    return Consumer<LandDetailsViewModel>(
      builder: (context, viewModel, child) {
        switch (viewModel.plantsResponse.status) {
          case Status.LOADING:
            return const Center(child: CircularProgressIndicator());
          case Status.ERROR:
            return Center(
              child: Text('Error: ${viewModel.plantsResponse.message}'),
            );
          case Status.COMPLETED:
            final plants = viewModel.plants;
            if (plants.isEmpty) {
              return const Center(child: Text('No plants found for this land'));
            }
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 3.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: plants.length,
              itemBuilder: (context, index) {
                final plantWithQty = plants[index];
                final plant = plantWithQty.plant;
                return SizedBox(
                  child: Card(
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
                  ),
                );
              },
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}