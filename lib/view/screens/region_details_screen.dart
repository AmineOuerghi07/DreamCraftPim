import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/view/screens/Components/region_detail_InfoCard.dart';
import 'package:pim_project/view/screens/Components/region_info.dart';
import 'package:pim_project/view/screens/Components/smart_regionsGrid.dart';
import 'package:pim_project/view/screens/components/connect_to_bleutooth.dart';

class RegionDetailsScreen extends StatelessWidget {
  final String id;
  const RegionDetailsScreen({required this.id, super.key});

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
                onAddRegion: () {},
              ),
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
                              title: "Irragation",
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
                    // PlantsGrid(),
                    ConnectToBluetooth(),
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
