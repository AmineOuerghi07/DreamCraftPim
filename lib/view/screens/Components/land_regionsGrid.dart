import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/model/domain/region.dart';

class LandRegionsGrid extends StatelessWidget {
  final String landId;
  final List<Region> regions;

  const LandRegionsGrid({
    super.key,
    required this.landId,
    required this.regions,
  });

  @override
  Widget build(BuildContext context) {
    if (regions.isEmpty) {
      return const Center(child: Text("No regions found"));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: calculateCrossAxisCount(context),
            childAspectRatio: 0.8,
          ),
          itemCount: regions.length,
          itemBuilder: (context, index) {
            final region = regions[index];
            return GestureDetector(
              onTap: () {
                GoRouter.of(context).push('/region-details/${region.id}');
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Image(
                          image: AssetImage("assets/images/plant.png"),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        region.name, // Use actual region name
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.sensors, size: 20, color: Colors.green),
                              SizedBox(height: 12),
                              Icon(Icons.grass, size: 20, color: Colors.green),
                              SizedBox(height: 12),
                              Icon(Icons.water_drop, size: 20, color: Colors.green),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${region.sensors.length} Sensors", // Use actual sensor count
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "${region.plants.length} Plants", // Use actual plant count
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "60% Irrigation", // You can update this if you have irrigation data
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  int calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) return 4;
    if (screenWidth >= 800) return 3;
    return 2;
  }
}