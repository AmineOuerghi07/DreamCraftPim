// view/screens/land_details_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pim_project/main.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/view_model/land_details_view_model.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/view_model/land_view_model.dart';
import 'package:pim_project/view/screens/components/land_regionsGrid.dart';
import 'package:pim_project/view/screens/components/plants_grid.dart';
import 'package:pim_project/view/screens/components/region_info.dart';
import 'components/info_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LandDetailsScreen extends StatelessWidget {
  final String id;
  const LandDetailsScreen({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LandDetailsViewModel>(
      builder: (context, viewModel, child) {
        // Schedule fetch after the build is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.landResponse.data?.id != id) {
            viewModel.fetchLandById(id);
            viewModel.fetchRegionsForLand(id);
            viewModel.fetchPlantsForLand(id);
          }
        });
        return WillPopScope(
          onWillPop: () async {
            // Fetch updated plants when navigating back
            await viewModel.fetchPlantsForLand(id);
            return true; // Allow navigation
          },
          child: _buildScaffold(context, viewModel.landResponse),
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context, ApiResponse<Land> response) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onSelected: (value) => _handleMenuSelection(value, context),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'update',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Update Land'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'setForRent',
                  child: ListTile(
                    leading: Icon(Icons.real_estate_agent),
                    title: response.data?.forRent == true 
                        ? Text('Land For Rent: ON')
                        : Text('Set Land For Rent'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete Land'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: _buildBody(context, response),
      ),
    );
  }

  void _handleMenuSelection(String value, BuildContext context) {
    final viewModel = Provider.of<LandDetailsViewModel>(context, listen: false);
    final land = viewModel.landResponse.data;
    switch (value) {
      case 'update':
        // Navigate to update screen
        _showUpdateLandPopup(context, land!);
        break;
      case 'setForRent':
        if (land != null) {
          // Only show confirmation if not already for rent
          if (!land.forRent) {
            _showSetForRentConfirmationDialog(context, viewModel, land);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("This land is already set for rent"),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
        break;
      case 'delete':
        _showDeleteConfirmationDialog(context, viewModel);
        break;
    }
  }

  void _showUpdateLandPopup(BuildContext parentContext, Land land) {
    File? _selectedImage;
    TextEditingController locationController =
        TextEditingController(text: land.cordonate);
    TextEditingController landNameController =
        TextEditingController(text: land.name);
    TextEditingController spaceController =
        TextEditingController(text: land.surface.toString());
    bool _isForRent = land.forRent;

    // Declare isLoading outside of the StatefulBuilder so it persists.
    bool isLoading = false;

    // Get screen width for responsive dialog
    final screenWidth = MediaQuery.of(parentContext).size.width;
    final isTablet = screenWidth > 600;

    Future<void> _pickImage(StateSetter setState) async {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              // Make dialog more responsive
              insetPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 64.0 : 16.0,
                vertical: 24.0,
              ),
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ),
                      Center(
                        child: Text(
                          AppLocalizations.of(context)!.updateLand,
                          style: TextStyle(
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: isTablet ? 24 : 16),
                      TextField(
                        controller: landNameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.landName,
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.location,
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      TextField(
                        controller: spaceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Space (m²)",
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      // For Rent Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppLocalizations.of(context)!.forRent,
                              style: TextStyle(fontSize: isTablet ? 18 : 16)),
                          ToggleButtons(
                            isSelected: [_isForRent, !_isForRent],
                            onPressed: (index) {
                              setState(() {
                                _isForRent = index == 0;
                              });
                            },
                            children: [
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(AppLocalizations.of(context)!.yes)),
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(AppLocalizations.of(context)!.no)),
                            ],
                            borderColor: Colors.grey,
                            selectedBorderColor: Colors.green,
                            selectedColor: Colors.white,
                            fillColor: Colors.green.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () async {
                              await _pickImage(setState);
                            },
                            child: const Text(
                              "Change Image",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          _selectedImage != null
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : (land.image.isNotEmpty
                                  ? Icon(Icons.image, color: Colors.green.shade700)
                                  : const SizedBox.shrink()),
                        ],
                      ),
                      SizedBox(height: isTablet ? 32 : 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  // Validate fields
                                  if (landNameController.text.isEmpty ||
                                      locationController.text.isEmpty ||
                                      spaceController.text.isEmpty) {
                                    ScaffoldMessenger.of(parentContext)
                                        .showSnackBar(const SnackBar(
                                      content: Text("Please fill all required fields"),
                                      backgroundColor: Colors.red,
                                    ));
                                    return;
                                  }

                                  // Set loading true
                                  setState(() {
                                    isLoading = true;
                                  });

                                  final updatedLand = land.copyWith(
                                    name: landNameController.text,
                                    cordonate: locationController.text,
                                    surface: double.tryParse(spaceController.text),
                                    forRent: _isForRent,
                                  );

                                  // Use the parent's context to access the provider
                                  final viewModel = Provider.of<LandDetailsViewModel>(
                                      parentContext,
                                      listen: false);
                                  final response = await viewModel.updateLand(
                                    updatedLand,
                                    image: _selectedImage,
                                  );

                                  // Set loading false
                                  setState(() {
                                    isLoading = false;
                                  });

                                  if (response.status == Status.COMPLETED) {
                                    Navigator.of(dialogContext).pop(); // Close dialog
                                    await viewModel.fetchLandById(land.id);
                                    final viewModelLand = Provider.of<LandViewModel>(
                                        parentContext,
                                        listen: false);
                                    viewModelLand.fetchLands();
                                  } else {
                                    ScaffoldMessenger.of(parentContext)
                                        .showSnackBar(SnackBar(
                                      content:
                                          Text(response.message ?? "Update failed"),
                                      backgroundColor: Colors.red,
                                    ));
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 32 : 20, 
                                vertical: isTablet ? 16 : 12),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Update",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 18 : 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSetForRentConfirmationDialog(
      BuildContext context, LandDetailsViewModel viewModel, Land land) {
    // Get screen dimensions for responsive dialog
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Set Land For Rent',
          style: TextStyle(fontSize: isTablet ? 22 : 18),
        ),
        content: Text(
          'Are you sure you want to make this land available for rent?',
          style: TextStyle(fontSize: isTablet ? 18 : 16),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Update the land with forRent = true
              final updatedLand = land.copyWith(forRent: true);
              
              // Call the updateLand method
              final response = await viewModel.updateLand(updatedLand);
              
              // Pop dialog
              if (context.mounted) context.pop();
              
              if (response.status == Status.COMPLETED) {
                // Refresh land data
                await viewModel.fetchLandById(land.id);
                
                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Land is now available for rent"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                // Show error message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response.message ?? "Failed to update land"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, LandDetailsViewModel viewModel) {
    // Get screen width for responsive dialog
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Confirm Delete',
          style: TextStyle(fontSize: isTablet ? 22 : 18),
        ),
        content: Text(
          'Are you sure you want to delete this land?',
          style: TextStyle(fontSize: isTablet ? 18 : 16),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Close dialog
              await viewModel.deleteLand(id);
              context.go(RouteNames.land);
              if (context.mounted) {
                // Pop details screen and refresh list
                context.pop();
                Provider.of<LandViewModel>(context, listen: false)
                    .fetchLandsByUserId(MyApp.userId);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ApiResponse<Land> response) {
    if (response.status == Status.LOADING) {
      return const Center(child: CircularProgressIndicator());
    }

    if (response.status == Status.ERROR) {
      return Center(child: Text(response.message!));
    }

    if (response.data == null) {
      return const Center(child: Text('No land data available'));
    }

    final land = response.data!;
    return _buildLandContent(context, land);
  }

  Widget _buildLandContent(BuildContext context, Land land) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // More precise device type detection
    final isTablet = screenWidth > 600;
    final isSmallPhone = screenWidth < 360;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24.0 : (isSmallPhone ? 12.0 : 16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Region info section - now more responsive
          LayoutBuilder(
            builder: (context, constraints) {
              return RegionInfo(
                regionCount: "${land.regions.length}",
                cultivationType: land.name,
                location: land.cordonate,
                onAddRegion: () => _showAddRegionPopup(context, land),
                buttonText: 'AddRegion',
              );
            },
          ),
          SizedBox(height: isTablet ? 24 : 16),
          
          // Info cards section - improved tablet layout
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth;
              
              if (isTablet) {
                // Enhanced tablet layout with container styling
                return Container(
                  width: double.infinity,
                
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InfoCard(
                        title: "Expanse",
                        value: "${land.surface}m²",
                        imageName: "square_foot.png",
                      ),
                      InfoCard(
                        title: "Humidity",
                        value: "${land.surface}%",
                        imageName: "humidity.png",
                      ),
                      InfoCard(
                        title: "Plants",
                        value: "${land.surface} ",
                        imageName: "plant.png",
                      ),
                    ],
                  ),
                );
              } else if (cardWidth < 400) {
                // Narrow screens - stack cards vertically with responsive sizing
                return Column(
                  children: [
                    _buildInfoCard(context, "Expanse", "${land.surface}m²", "square_foot.png", cardWidth),
                    _buildInfoCard(context, "Humidity", "${land.surface}%", "humidity.png", cardWidth),
                    _buildInfoCard(context, "Plants", "${land.surface}", "plant.png", cardWidth),
                  ],
                );
              } else {
                // Wider phone screens
                final cardHeight = screenWidth > 400 ? 150.0 : 120.0;
                
                return Container(
                  height: cardHeight,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InfoCard(
                          title: "Expanse",
                          value: "${land.surface}m²",
                          imageName: "square_foot.png",
                        ),
                        InfoCard(
                          title: "Humidity",
                          value: "${land.surface}%",
                          imageName: "humidity.png",
                        ),
                        InfoCard(
                          title: "Plants",
                          value: "${land.surface} ",
                          imageName: "plant.png",
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
          
          SizedBox(height: isTablet ? 24 : 16),
          
          // Tab bar - with responsive text size
          TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green,
            labelStyle: TextStyle(
              fontSize: isTablet ? 18 : (isSmallPhone ? 14 : 16),
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: isTablet ? "Land Regions" : "Regions"),
              Tab(text: "Plants"),
            ],
          ),
          
          SizedBox(height: isTablet ? 24 : 16),
          
          // Tab views - take remaining space
          Expanded(
            child: TabBarView(
              children: [
                Consumer<LandDetailsViewModel>(
                  builder: (context, viewModel, _) {
                    if (viewModel.regionsResponse.status == Status.LOADING) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (viewModel.regionsResponse.status == Status.ERROR) {
                      return Center(child: Text(viewModel.regionsResponse.message!));
                    }
                    return LandRegionsGrid(
                      landId: id,
                      regions: viewModel.regions,
                    );
                  },
                ),
                PlantsGrid(landId: id),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build a single info card for narrow screens - enhanced with responsive sizing
  Widget _buildInfoCard(BuildContext context, String title, String value, String imageName, double width) {
    // Adjust height based on screen width for better proportions
    final isTablet = MediaQuery.of(context).size.width > 600;
    final cardHeight = isTablet ? 100.0 : 80.0;
    
    return Container(
      width: width,
      height: cardHeight,
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 12.0 : 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 18 : 16,
                ),
              ),
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: isTablet ? 18 : 16,
                    ),
                  ),
                  SizedBox(width: isTablet ? 12 : 8),
                  Image.asset(
                    "assets/images/$imageName",
                    width: isTablet ? 32 : 24,
                    height: isTablet ? 32 : 24,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showAddRegionPopup(BuildContext context, Land landId) {
  TextEditingController nameController = TextEditingController();
  TextEditingController surfaceController = TextEditingController();

  // Get screen dimensions for better responsiveness
  final screenWidth = MediaQuery.of(context).size.width;
  final isTablet = screenWidth > 600;
  final isSmallPhone = screenWidth < 360;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            // Make dialog more responsive on different devices
            insetPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 64.0 : (isSmallPhone ? 16.0 : 24.0),
              vertical: isTablet ? 32.0 : 24.0,
            ),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Add New Region",
                        style: TextStyle(
                          fontSize: isTablet ? 24 : (isSmallPhone ? 18 : 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 24 : 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Region Name",
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    TextField(
                      controller: surfaceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Surface Area (m²)",
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: isTablet ? 32 : 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.isEmpty ||
                              surfaceController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please fill all fields"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final surface = double.tryParse(surfaceController.text);
                          if (surface == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Invalid surface value"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final viewModel = Provider.of<LandDetailsViewModel>(
                              context,
                              listen: false);

                          // Create Region object
                          final newRegion = Region(
                            id: "",
                            name: nameController.text,
                            surface: surface,
                            land: landId,
                            isConnected: false,
                          );

                          final response =
                              await viewModel.addRegion(newRegion).timeout(
                                    const Duration(seconds: 15),
                                    onTimeout: () {
                                      return ApiResponse.error('Request timed out');
                                    },
                                  );

                          if (response.status == Status.COMPLETED) {
                            Navigator.of(dialogContext).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    response.message ?? "Failed to add region"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 32 : (isSmallPhone ? 16 : 20), 
                            vertical: isTablet ? 16 : 12
                          ),
                        ),
                        child: Text(
                          "Add Region",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 18 : (isSmallPhone ? 14 : 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}