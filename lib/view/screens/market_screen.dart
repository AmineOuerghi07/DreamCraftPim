import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/view/screens/Components/category_seeAllButton.dart';
import 'package:pim_project/view/screens/Components/header.dart';
import 'package:pim_project/view/screens/Components/home_cart.dart';
import 'package:pim_project/view/screens/Components/plants_for_sell.dart';
import 'package:pim_project/view/screens/Components/search_bar.dart' as custom;

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

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
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Header(
                profileImage: "assets/images/profile.png",
                greetingText: "Haaa! ",
                username: "Mahamed",
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    custom.SearchBar(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      onFilterTap: () {
                        print("Filter button tapped!");
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.builder(
                    itemCount: 6, // Ensure this is a valid list length
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CategorySeeallbutton(navigateSeeAll: () {}),
                            const SizedBox(height: 8),
                            PlantsForSell()
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
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
