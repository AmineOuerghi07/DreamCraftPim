import 'package:flutter/material.dart';
import 'package:pim_project/ProviderClasses/market_provider.dart';
import 'package:pim_project/view/screens/Components/category_grid.dart';
import 'package:pim_project/view/screens/Components/category_seeAllButton.dart';

import 'package:pim_project/view/screens/Components/marketHeader.dart';
import 'package:pim_project/view/screens/Components/plants_for_sell.dart';
import 'package:pim_project/view/screens/Components/search_bar.dart' as custom;
import 'package:pim_project/view/screens/Components/seeAllProductsWithSameCategory.dart';
import 'package:provider/provider.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context, listen: false);

    // Fetch products only if the list is empty (prevents redundant API calls)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (marketProvider.products.isEmpty) {
        marketProvider.fetchProducts(); // Ensure products are only fetched once
      }
    });

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
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Marketheader(
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
                      },
                      onChanged: (value) {
                        // Ensure MarketProvider updates based on search input
                        context.read<MarketProvider>().setSearchTerm(value);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<MarketProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.categories.isEmpty) {
                      return const Center(
                          child: Text("No categories available"));
                    }

                    // Use a GridView for category display
                    if (provider.isFilterActive) {
                      return CategoryGrid(
                        categories: provider.categories,
                      ); // Display category grid
                    }
                    
                    if (provider.isCategoryFilterActive) {
                      return SeeAllProductsWithSameCategory(categorie: provider.category,);
                       
                    }

                    // Default view with list of categories
                    return ListView.builder(
                      itemCount: provider.categories.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CategorySeeallbutton(
                                  categories: provider.categories,
                                  index: index,
                                  navigateSeeAll: () {
                                    provider.toggleCategoryFilter(
                                        provider.categories[index]);
                                  }),
                              const SizedBox(height: 8),
                              PlantsForSell(
                                  products: provider.products
                                      .where((product) =>
                                          product.category ==
                                          provider.categories[index])
                                      .toList(),
                                  categories: provider.categories),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
