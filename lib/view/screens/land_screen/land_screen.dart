// view/screens/land_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/view/screens/Components/header.dart';
import 'package:pim_project/view/screens/Components/search_bar.dart' as custom;
import 'package:pim_project/view/screens/land_screen/components/land_card.dart';
import 'package:pim_project/view_model/land_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Future.microtask(() {
      Provider.of<LandViewModel>(context, listen: false).fetchLandsByUserId(widget.userId);
    });

    final TextEditingController searchController = TextEditingController();
    final FocusNode searchFocusNode = FocusNode();

    void unfocus() {
      if (searchFocusNode.hasFocus) {
        searchFocusNode.unfocus();
      }
    }
    
    void showFilterDialog(BuildContext context) {
      final landViewModel = Provider.of<LandViewModel>(context, listen: false);
      final locations = ['all', ...landViewModel.lands.map((land) => land.cordonate).toSet()];
      
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.filterOptions,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Rent Status Filter
                      Text(l10n.rentStatus),
                      Column(
                        children: [
                          RadioListTile(
                            title: Text(l10n.allLocations),
                            value: 'all',
                            groupValue: _selectedFilter,
                            onChanged: (value) {
                              setState(() => _selectedFilter = value.toString());
                            },
                          ),
                          RadioListTile(
                            title: Text(l10n.forRent),
                            value: 'forRent',
                            groupValue: _selectedFilter,
                            onChanged: (value) {
                              setState(() => _selectedFilter = value.toString());
                            },
                          ),
                          RadioListTile(
                            title: Text(l10n.notForRent),
                            value: 'notForRent',
                            groupValue: _selectedFilter,
                            onChanged: (value) {
                              setState(() => _selectedFilter = value.toString());
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Location Filter
                      Text(l10n.location),
                      DropdownButtonFormField<String>(
                        value: _selectedLocation,
                        items: locations.map((location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Text(location == 'all' ? l10n.allLocations : location),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedLocation = value!);
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.cancel),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor, 
                            ),
                            child: Text(l10n.apply),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

  

    void showAddLandPopup(BuildContext context) {
      File? selectedImage;
      TextEditingController locationController = TextEditingController();
      TextEditingController landNameController = TextEditingController();
      TextEditingController spaceController = TextEditingController();
      bool isLoading = false;
      final l10n = AppLocalizations.of(context)!;

      Future<void> pickImage(StateSetter setState) async {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            selectedImage = File(pickedFile.path);
          });
        }
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0, left: 16.0, bottom: 16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => context.pop(),
                          ),
                        ),
                        Center(
                          child: Text(
                            l10n.lands,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: landNameController,
                          decoration: InputDecoration(
                            labelText: l10n.landName,
                            hintText: l10n.landName,
                            border: UnderlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: locationController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: l10n.location,
                            hintText: l10n.location,
                            border: const UnderlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.map, color: Colors.blue),
                              onPressed: () async {
                                final selectedLocation = await context.push(RouteNames.mapScreen);
                                if (selectedLocation != null && mounted) {
                                  setState(() {
                                    locationController.text = selectedLocation as String;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: spaceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.surface,
                            hintText: l10n.surface,
                            border: UnderlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () async {
                                await pickImage(setState);
                              },
                              child: Text(
                                l10n.changeImage,
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (selectedImage != null)
                              const Icon(Icons.check_circle, color: Colors.green),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (landNameController.text.isEmpty ||
                                        locationController.text.isEmpty ||
                                        spaceController.text.isEmpty ||
                                        selectedImage == null) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.fillAllFields),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() {
                                      isLoading = true;
                                    });
                                    Land newLand = Land(
                                      name: landNameController.text,
                                      cordonate: locationController.text,
                                      surface: double.tryParse(spaceController.text) ?? 0.0,
                                      id: '',
                                      forRent: false,
                                      image: '',
                                      regions: [],
                                      rentPrice: 0,
                                      userId: widget.userId,
                                      ownerPhone: '',
                                    );
                                    
                                    // Fetch the owner's phone number before adding the land
                                    try {
                                      final url = Uri.parse('${AppConstants.baseUrl}/account/get-account/${widget.userId}');
                                      final userResponse = await http.get(url);
                                      
                                      if (userResponse.statusCode == 200 || userResponse.statusCode == 201) {
                                        final userData = jsonDecode(userResponse.body);
                                        // Try to get phone from either field
                                        final phoneNumber = userData['phone']?.toString() ?? 
                                                           userData['phonenumber']?.toString() ?? '';
                                        newLand = newLand.copyWith(ownerPhone: phoneNumber);
                                        print('Set owner phone number: $phoneNumber for new land');
                                      }
                                    } catch (e) {
                                      print('Error fetching owner phone number: $e');
                                    }
                                    
                                    final landViewModel = Provider.of<LandViewModel>(context, listen: false);
                                    await landViewModel.addLand(land: newLand, image: selectedImage!).then((response) {
                                      if (!mounted) return;
                                      if (response.status == Status.COMPLETED) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(l10n.profileUpdatedSuccess),
                                            backgroundColor:AppConstants.primaryColor,
                                          ),
                                        );
                                        Navigator.of(context).pop();
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(response.message ?? l10n.updateFailed),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    });
                                    if (!mounted) return;
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(l10n.save, style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }

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
                      onFilterTap: () => showFilterDialog(context),
                      onChanged: (query) {
                        Provider.of<LandViewModel>(context, listen: false).searchLands(query);
                      },
                      l10n: l10n,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.yourGreenhouses,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Consumer<LandViewModel>(
                          builder: (context, viewModel, child) {
                            return Text(
                              "${viewModel.filteredLands.length} ${l10n.places}",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Consumer<LandViewModel>(
                        builder: (context, viewModel, child) {
                          return _buildLandList(viewModel);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: SizedBox(
          width: 50,
          height: 50,
          child: FloatingActionButton(
            onPressed: () {
              showAddLandPopup(context);
            },
            backgroundColor: Colors.green.withAlpha(191),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildLandList(LandViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;
    
    if (viewModel.landsResponse.status == Status.LOADING) {
      return const Center(child: CircularProgressIndicator());
    } else if (viewModel.landsResponse.status == Status.ERROR) {
      return Center(child: Text("${l10n.error}: ${viewModel.landsResponse.message}"));
    } else if (viewModel.filteredLands.isEmpty && viewModel.lands.isEmpty) {
      return Center(child: Text(l10n.noLandsAvailable));
    } else if (viewModel.filteredLands.isEmpty) {
      return Center(child: Text(l10n.noLandsMatchSearch));
    }

    return ListView.builder(
      itemCount: viewModel.filteredLands.length,
      itemBuilder: (context, index) {
        final land = viewModel.filteredLands[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: LandCard(
            title: land.name,
            location: land.cordonate,
            description: "${l10n.surface}: ${land.surface}m² • ${land.forRent ? l10n.forRent : l10n.notAvailable}",
            imageUrl: land.image.isNotEmpty ? AppConstants.imagesbaseURL + land.image : 'assets/images/placeholder.png',
            id: land.id,
            onDetailsTap: () {
              GoRouter.of(context).push('/land-details/${land.id}');
            },
          ),
        );
      },
    );
  }
}