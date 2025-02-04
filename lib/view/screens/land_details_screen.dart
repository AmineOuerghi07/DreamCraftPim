import 'package:flutter/material.dart';

class LandDetailsScreen extends StatelessWidget {
  const LandDetailsScreen({super.key});

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
            onPressed: () => Navigator.of(context).pop(),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                              50, 68, 206, 155), // Light green background
                          borderRadius:
                              BorderRadius.circular(16), // Rounded edges
                        ),
                        child: const Text(
                          "34 Regions",
                          style: TextStyle(
                            color: Colors.green, // Green text color
                            fontWeight: FontWeight.w500, // Medium font weight
                          ),
                        ),
                      ),
                      const Text(
                        "Maze Cultivation",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(Icons.location_pin,
                              size: 16, color: Colors.grey),
                          Text(
                            "Sfax, Chaaleb",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Add Region functionality
                        },
                        child: const Text(
                          "Add Region",
                          style: TextStyle(
                            color: Colors.black, // Green text color
                            fontWeight: FontWeight.bold, // Bold font weight
                          ),
                        ),
                      ),
                      const Image(
                          image: AssetImage(
                              "../assets/images/google_maps_location_picker.png"),
                          width: 100,
                          height: 100),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoCard("Expanse", "3000m²", "square_foot.png"),
                  _buildInfoCard("Humidity", "20%", "humidity.png"),
                  _buildInfoCard("Plants", "4 Type", "plant.png"),
                ],
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
              Expanded(
                child: TabBarView(
                  children: [
                    _buildLandRegionsGrid(),
                    _buildPlantsGrid(),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, String imagename) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image(
                image: AssetImage("../assets/images/" + imagename),
                width: 32,
                height: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLandRegionsGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Image(
                  image: AssetImage("../assets/images/plant.png"),
                  width: 100,
                  height: 100,
                ),
                Text(
                  "Region ${index + 1}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sensors, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text("5 Sensors"),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.grass, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text("250 Plants"),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.water_drop, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text("60% Irrigation"),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildPlantsGrid() {
  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 1,
      childAspectRatio: 3.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
    ),
    itemCount: 4,
    itemBuilder: (context, index) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Image(
                image: AssetImage("../assets/images/cherry.png"),
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 0, width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                          49, 228, 161, 85), // Light green background
                      borderRadius: BorderRadius.circular(16), // Rounded edges
                    ),
                    child: const Text(
                      "Fruits",
                      style: TextStyle(
                        color: Color.fromARGB(
                            255, 246, 125, 3), // Green text color
                        fontWeight: FontWeight.w500, // Medium font weight
                      ),
                    ),
                  ),
                  const Text("Cherry Plant",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  const Text("120 plants",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
