// view/screens/land_screen/land_screen.dart
import 'package:flutter/material.dart';
import 'package:pim_project/view/screens/components/app_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/view/screens/Components/header.dart';
import 'package:pim_project/view/screens/components/internal_server_error.dart';
import 'package:pim_project/view/screens/Components/search_bar.dart' as custom;
import 'package:pim_project/view_model/land_view_model.dart';
import 'package:pim_project/view/screens/land_screen/components/land_filter_dialog.dart';
import 'package:pim_project/view/screens/land_screen/components/add_land_dialog.dart';
import 'package:pim_project/view/screens/land_screen/components/land_list_view.dart';
import 'package:pim_project/view/screens/land_screen/components/land_header_section.dart';
import 'package:pim_project/view/screens/land_screen/components/no_land_component.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class LandScreen extends StatefulWidget {
  final String userId;

  const LandScreen({super.key, required this.userId});

  @override
  State<LandScreen> createState() => _LandScreenState();
}

class _LandScreenState extends State<LandScreen> {
  String _username = '';
  bool _isLoading = true;
  String _selectedFilter = 'all'; 
  String _selectedLocation = 'all';
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

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
      print('❌ [LandScreen] Erreur lors de la récupération des données utilisateur: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void unfocus() {
    if (searchFocusNode.hasFocus) {
      searchFocusNode.unfocus();
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => LandFilterDialog(
        selectedFilter: _selectedFilter,
        selectedLocation: _selectedLocation,
        onFilterChanged: (filter) {
          setState(() => _selectedFilter = filter);
        },
        onLocationChanged: (location) {
          setState(() => _selectedLocation = location);
        },
      ),
    );
  }

  void _showAddLandDialog() {
    showDialog(
      context: context,
      builder: (context) => AddLandDialog(userId: widget.userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Fetch lands on init
    Future.microtask(() {
      Provider.of<LandViewModel>(context, listen: false).fetchLandsByUserId(widget.userId);
    });

    return GestureDetector(
      onTap: unfocus,
      child: Scaffold(
        body: Column(
          children: [
            const Padding(padding: EdgeInsets.symmetric(horizontal: 26, vertical: 12)),
            _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Header(
                  greetingText: '${l10n.hello} ',
                  username: _username,
                  userId: widget.userId,
                ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    custom.SearchBar(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      onFilterTap: _showFilterDialog,
                      onChanged: (query) {
                        Provider.of<LandViewModel>(context, listen: false).searchLands(query);
                      },
                      l10n: l10n,
                    ),
                    const SizedBox(height: 16),
                    LandHeaderSection(),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Consumer<LandViewModel>(
                        builder: (context, viewModel, child) {
                          if (viewModel.landsResponse.status == Status.LOADING) {
                            return const Center(child: AppProgressIndicator(
          loadingText: 'Growing data...',
          // You can customize colors to match your app theme
          primaryColor: const Color(0xFF4CAF50), // Green
          secondaryColor: const Color(0xFF8BC34A), // Light Green
          size: 150, // Adjust size as needed
        ),);
                          } else if (viewModel.landsResponse.status == Status.ERROR) {
                            return InternalServerError(
                              message: null,
                              onRetry: () {viewModel.fetchLandsByUserId(widget.userId);},
                            );
                          } else if (viewModel.filteredLands.isEmpty && viewModel.lands.isEmpty) {
                            return NoLandsComponent(
                              onAddLandPressed: _showAddLandDialog,
                            );
                          } else if (viewModel.filteredLands.isEmpty) {
                            return Center(child: Text(l10n.noLandsMatchSearch));
                          }
                          
                          return LandListView(
                            lands: viewModel.filteredLands,
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
        floatingActionButton: Consumer<LandViewModel>(
          builder: (context, viewModel, child) {
            // Only show FAB if there are lands OR if we're not in the "no lands" state
            bool showFAB = !(viewModel.filteredLands.isEmpty && viewModel.lands.isEmpty);
            
            return showFAB ? SizedBox(
              width: 50,
              height: 50,
              child: FloatingActionButton(
                onPressed: _showAddLandDialog,
                backgroundColor: Colors.green.withAlpha(191),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ) : const SizedBox.shrink();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}