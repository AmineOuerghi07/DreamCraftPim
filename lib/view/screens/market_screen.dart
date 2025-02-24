import 'package:flutter/material.dart';
import 'package:pim_project/ProviderClasses/market_provider.dart';
import 'package:pim_project/view/screens/Components/category_grid.dart';
import 'package:pim_project/view/screens/Components/category_seeAllButton.dart';
import 'package:pim_project/view/screens/Components/header.dart';
import 'package:pim_project/view/screens/Components/plants_for_sell.dart';
import 'package:pim_project/view/screens/Components/search_bar.dart' as custom;
import 'package:provider/provider.dart';

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
                        context.read<MarketProvider>().toggleFilter();
                        print("Filter button tapped!");
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              Consumer<MarketProvider>(
                builder: (context, provider, _) {
                  return provider.isFilterActive
                      ?  CategoryGrid() // Replace with your filter component
                      : Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ListView.builder(
                              itemCount:
                                  6, // Ensure this is a valid list length
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CategorySeeallbutton(
                                          navigateSeeAll: () {}),
                                      const SizedBox(height: 8),
                                      PlantsForSell()
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
