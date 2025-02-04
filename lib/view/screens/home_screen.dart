import 'package:flutter/material.dart';
import 'package:pim_project/view/screens/Components/header.dart';
import 'package:pim_project/view/screens/Components/search_bar.dart' as custom;
import 'package:pim_project/view/screens/Components/home_cart.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the search controller
    final TextEditingController searchController = TextEditingController();
    final FocusNode searchFocusNode = FocusNode();
        void _unfocus() {
      if (searchFocusNode.hasFocus) {
        searchFocusNode.unfocus();
      }
    }
    return GestureDetector(
      onTap: _unfocus,
      child: Scaffold(
        body: Column(
          children: [
            const Padding(padding: EdgeInsets.symmetric(horizontal: 26, vertical: 12)),
            Header(
              profileImage: "assets/images/profile.png",
              greetingText: "Haaa! ",
              username: "Mahamed",
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Use your custom SearchBar
                    custom.SearchBar(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      onFilterTap: () {
                        // Handle filter button action
                        print("Filter button tapped!");
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Need Our Help?",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                const Text("Feel free to contact our support for any troubles"),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text(
                                    "Call Now",
                                    style: TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Image.asset(
                            "assets/images/help.png",
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Your Greenhouses",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "12 Places",
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                        child: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: HomeCart(
              title: "Maze Cultivation",
              location: "Sfax, Chaaleb",
              description:
                  "Maze is a tropical plant which prefers warm humid weather.",
              imageUrl: 'assets/images/LandDemo.png',
              onDetailsTap: () {
                // Handle "Read Details" tap
                print("Details for card $index tapped!");
              },
            ),
          );
        },
      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: "Magasin"),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: "Regions"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            // Add navigation logic here
          },
        ),
      ),
    );
  }
}
