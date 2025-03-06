import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/view/screens/Components/header.dart';
import 'package:pim_project/view/screens/Components/search_bar.dart' as custom;
import 'package:pim_project/view/screens/Components/home_cart.dart';

class LandScreen extends StatelessWidget {
  const LandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the search controller
    final TextEditingController searchController = TextEditingController();
    final FocusNode searchFocusNode = FocusNode();
    void unfocus() {
      if (searchFocusNode.hasFocus) {
        searchFocusNode.unfocus();
      }
    }

    return GestureDetector(
      onTap: unfocus,
      child: Scaffold(
        body: Column(
          children: [
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 26, vertical: 12)),
            const Header(
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
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 16),
                 
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Your Greenhouses",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "12 Places",
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
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
                              id: "6952315ald2", // To be changed with the needed one from the database
                              onDetailsTap: () {
                                GoRouter.of(context).push(
                                    '/land-details/6952315ald2'); // passing the Static Id for now
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
     //   bottomNavigationBar: const BottomNavigationBarWidget(),
      ),
    );
  }
}
