// view/screens/market_screen.dart
import 'package:flutter/material.dart';
import 'package:pim_project/ProviderClasses/market_provider.dart';
import 'package:pim_project/view/screens/components/app_progress_indicator.dart';
import 'package:pim_project/view/screens/market_screen/components/category_grid.dart';
import 'package:pim_project/view/screens/market_screen/components/category_seeAllButton.dart';
import 'package:pim_project/view/screens/market_screen/components/plants_for_sell.dart';
import 'package:pim_project/view/screens/market_screen/components/marketScreenSearchBar.dart' as custom;
import 'package:pim_project/view/screens/market_screen/components/seeAllProductsWithSameCategory.dart';
import 'package:pim_project/view/screens/market_screen/components/marketHeader.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pim_project/constants/constants.dart';


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
            _username = data['fullname'] ?? 'User';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ [MarketScreen] Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Consumer<MarketProvider>(
                  builder: (context, provider, _) => provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Marketheader(
                        greetingText: l10n.hello,
                        username: _username,
                      ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    custom.Marketscreensearchbar(
                      l10n: l10n,
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
                      return const Center(child:  AppProgressIndicator(
  loadingText: 'Growing data...',
  primaryColor: const Color(0xFF4CAF50), // Green
  secondaryColor: const Color(0xFF8BC34A), // Light Green
  size: 100, // Controls the overall size
),);
                    }

                    if (provider.categories.isEmpty) {
                      return Center(child: Text(l10n.noCategories));
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
