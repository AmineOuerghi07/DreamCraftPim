import 'package:flutter/material.dart';
import 'package:pim_project/ProviderClasses/market_provider.dart';
import 'package:pim_project/view/screens/Components/category_grid.dart';
import 'package:pim_project/view/screens/Components/category_seeAllButton.dart';

import 'package:pim_project/view/screens/Components/marketHeader.dart';
import 'package:pim_project/view/screens/Components/plants_for_sell.dart';
import 'package:pim_project/view/screens/Components/marketScreenSearchBar.dart' as custom;
import 'package:pim_project/view/screens/Components/seeAllProductsWithSameCategory.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/model/services/UserPreferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pim_project/constants/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/routes/routes.dart';

class MarketScreen extends StatefulWidget {
  final String userId;

  const MarketScreen({super.key, required this.userId});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _username = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/account/get-account/${widget.userId}');
      final response = await http.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _username = data['fullname'] ?? '';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ [MarketScreen] Erreur lors de la récupération des données utilisateur: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    // Fetch products only if the list is empty (prevents redundant API calls)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (marketProvider.products.isEmpty) {
        marketProvider.fetchProducts();
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
              Marketheader(
                greetingText: 'Bonjour ',
                username: _username,
                userId: widget.userId,
                onProfileTap: () {
                  context.push(RouteNames.profile, extra: widget.userId);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    custom.Marketscreensearchbar(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      onFilterTap: () {
                        if((marketProvider.isCategoryFilterActive)&&(marketProvider.changefilterIcon)) {
                        marketProvider.toggleCategoryFilter(marketProvider.category);
                        }else{
                          marketProvider.toggleFilter();
                        }
                                             
                        if (!marketProvider.isCategoryFilterActive) {
                          marketProvider.changeFilterIcon();
                        }
                        
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
                                    provider.changeFilterIcon();
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
