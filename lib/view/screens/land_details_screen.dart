import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/view/screens/components/land_regionsGrid.dart';
import 'package:pim_project/view/screens/components/plants_grid.dart';
import 'package:pim_project/view/screens/components/region_info.dart';

import 'components/info_card.dart';

class LandDetailsScreen extends StatelessWidget {
  final String id;
  const LandDetailsScreen({required this.id,super.key});

  @override
  Widget build(BuildContext context) {
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
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  margin: const EdgeInsets.all(12),
                  child:const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InfoCard(
                          title: "Expanse",
                          value: "3000m²",
                          imageName: "square_foot.png"),
                      InfoCard(
                          title: "Humidity",
                          value: "20%",
                          imageName: "humidity.png"),
                      InfoCard(
                          title: "Plants",
                          value: "4 Type",
                          imageName: "plant.png"),
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
                  Tab(text: "Land Regions"),
                  Tab(text: "Plants"),
                ],
              ),
              const SizedBox(height: 16),
              const Expanded(
                child: TabBarView(
                  children: [
                    LandRegionsGrid(),
                    PlantsGrid(),
                  ],
                ),
              ),
            ],
          ),
        ),
       
      ),
    );
  }
}
