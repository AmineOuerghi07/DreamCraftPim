// view/screens/land_details_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pim_project/constants/constants.dart';
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
        final l10n = AppLocalizations.of(context)!;

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
    final l10n = AppLocalizations.of(context)!;
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
                PopupMenuItem<String>(
                  value: 'update',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text(AppLocalizations.of(context)!.updateLand),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'toggleRent',
                  child: ListTile(
                    leading: Icon(
                      response.data?.forRent == true 
                          ? Icons.not_interested 
                          : Icons.real_estate_agent,
                      color: response.data?.forRent == true 
                          ? Colors.red
                          : Colors.green,
                    ),
                    title: response.data?.forRent == true 
                        ? Text(AppLocalizations.of(context)!.disableForRent)
                        : Text(AppLocalizations.of(context)!.setForRent),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text(AppLocalizations.of(context)!.deleteLand),
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
      case 'toggleRent':
        if (land != null) {
          // Show appropriate confirmation dialog based on current status
          if (land.forRent) {
            _showDisableRentConfirmationDialog(context, viewModel, land);
          } else {
            _showSetForRentConfirmationDialog(context, viewModel, land);
          }
        }
        break;
      case 'delete':
        _showDeleteConfirmationDialog(context, viewModel);
        break;
    }
  }

  void _showUpdateLandPopup(BuildContext parentContext, Land land) {
    final l10n = AppLocalizations.of(parentContext)!;
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
            final dialogL10n = AppLocalizations.of(context)!;
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
                          dialogL10n.updateLand,
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
                          labelText: dialogL10n.landName,
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          labelText: dialogL10n.location,
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      TextField(
                        controller: spaceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: dialogL10n.surface,
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      // For Rent Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(dialogL10n.forRent,
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
                                  child: Text(dialogL10n.yes)),
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(dialogL10n.no)),
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
                            child: Text(
                              dialogL10n.changeImage,
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          _selectedImage != null
                              ? const Icon(Icons.check_circle, color: AppConstants.primaryColor)
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
                                        .showSnackBar(SnackBar(
                                      content: Text(dialogL10n.fillAllFields),
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
                                          Text(response.message ?? dialogL10n.updateFailed),
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
                                  dialogL10n.update,
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
    final l10n = AppLocalizations.of(context)!;
    
    // Text controller for the price input
    final TextEditingController priceController = TextEditingController();
    // Add the current price if already set
    if (land.rentPrice != null && land.rentPrice! > 0) {
      priceController.text = land.rentPrice.toString();
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) {
          bool isValidPrice = true;
          
          return AlertDialog(
            title: Text(
              l10n.setForRent,
              style: TextStyle(fontSize: isTablet ? 22 : 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.confirmSetForRent,
                  style: TextStyle(fontSize: isTablet ? 18 : 16),
                ),
                SizedBox(height: isTablet ? 24 : 16),
                Text(
                  l10n.setRentalPrice,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.price,
                    hintText: l10n.enterRentalPrice,
                    suffixText: 'DT/month',
                    errorText: isValidPrice ? null : l10n.invalidSurfaceValue,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      // Validate price input
                      if (value.isEmpty) {
                        isValidPrice = false;
                      } else {
                        try {
                          double price = double.parse(value);
                          isValidPrice = price > 0;
                        } catch (e) {
                          isValidPrice = false;
                        }
                      }
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () async {
                  // Validate price input before proceeding
                  if (priceController.text.isEmpty) {
                    setState(() {
                      isValidPrice = false;
                    });
                    return;
                  }
                  
                  double? price;
                  try {
                    price = double.parse(priceController.text);
                    if (price <= 0) {
                      setState(() {
                        isValidPrice = false;
                      });
                      return;
                    }
                  } catch (e) {
                    setState(() {
                      isValidPrice = false;
                    });
                    return;
                  }
                  
                  // Update the land with forRent = true and the rental price
                  final updatedLand = land.copyWith(
                    forRent: true,
                    rentPrice: price,
                  );
                  
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
                        SnackBar(
                          content: Text(l10n.landIsNowForRent),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    // Show error message
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(response.message ?? l10n.updateFailed),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(l10n.confirm, style: TextStyle(color: Colors.green)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showDisableRentConfirmationDialog(
      BuildContext context, LandDetailsViewModel viewModel, Land land) {
    // Get screen dimensions for responsive dialog
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          l10n.disableForRent,
          style: TextStyle(fontSize: isTablet ? 22 : 18),
        ),
        content: Text(
          l10n.confirmDisableForRent,
          style: TextStyle(fontSize: isTablet ? 18 : 16),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              // Update the land with forRent = false
              final updatedLand = land.copyWith(forRent: false);
              
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
                    SnackBar(
                      content: Text(l10n.landIsNoLongerForRent),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
              } else {
                // Show error message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response.message ?? l10n.updateFailed),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(l10n.confirm, style: TextStyle(color: Colors.red)),
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
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          l10n.confirmDelete,
          style: TextStyle(fontSize: isTablet ? 22 : 18),
        ),
        content: Text(
          l10n.confirmDeleteMessage,
          style: TextStyle(fontSize: isTablet ? 18 : 16),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(l10n.cancel),
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
            child: Text(l10n.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ApiResponse<Land> response) {
    final l10n = AppLocalizations.of(context)!;
    
    if (response.status == Status.LOADING) {
      return const Center(child: CircularProgressIndicator());
    }

    if (response.status == Status.ERROR) {
      return Center(child: Text(response.message!));
    }

    if (response.data == null) {
      return Center(child: Text(l10n.noLandDataAvailable));
    }

    final land = response.data!;
    return _buildLandContent(context, land);
  }

  Widget _buildLandContent(BuildContext context, Land land) {
    final l10n = AppLocalizations.of(context)!;
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
  //  final screenHeight = MediaQuery.of(context).size.height;
    
    // More precise device type detection
    final isTablet = screenWidth > 600;
    final isSmallPhone = screenWidth < 360;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24.0 : 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Region info section - Use original for phones, new for tablets
          LayoutBuilder(
            builder: (context, constraints) {
              if (isTablet) {
                // Use the responsive RegionInfo for tablets
                return RegionInfo(
                  regionCount: "${land.regions.length}",
                  cultivationType: land.name,
                  location: land.cordonate,
                  onAddRegion: () => _showAddRegionPopup(context, land),
                  buttonText: l10n.addRegion,
                );
              } else {
                // Use original design for phones
                return _buildOriginalRegionInfo(context, land);
              }
            },
          ),
          SizedBox(height: isTablet ? 24 : 16),
          
          // Info cards section - same container but different internal layout
          SizedBox(
            height: isTablet ? 400 : 150, // Taller for tablet's column layout
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
              ),
              elevation: 4,
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: isTablet 
                  // Column layout for tablet
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InfoCard(
                          title: l10n.expanse,
                          value: "${land.surface}m²",
                          imageName: "square_foot.png",
                        ),
                        InfoCard(
                          title: l10n.humidity,
                          value: "${land.surface}%",
                          imageName: "humidity.png",
                        ),
                        InfoCard(
                          title: l10n.plants,
                          value: "${land.surface}",
                          imageName: "plant.png",
                        ),
                      ],
                    )
                  // Row layout for phones - exactly like original
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InfoCard(
                          title: l10n.expanse,
                          value: "${land.surface}m²",
                          imageName: "square_foot.png",
                        ),
                        InfoCard(
                          title: l10n.humidity,
                          value: "${land.surface}%",
                          imageName: "humidity.png",
                        ),
                        InfoCard(
                          title: l10n.plants,
                          value: "${land.surface}",
                          imageName: "plant.png",
                        ),
                      ],
                    ),
              ),
            ),
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
              Tab(text: isTablet ? l10n.landRegions : l10n.regions),
              Tab(text: l10n.plants),
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

  // Original RegionInfo implementation for phones
  Widget _buildOriginalRegionInfo(BuildContext context, Land land) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(50, 68, 206, 155),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "${land.regions.length} ${l10n.regionsCount}",
                style: const TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              land.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_pin, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  land.cordonate,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Right Column: Add Button and Image
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => _showAddRegionPopup(context, land),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  l10n.addRegion,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Image(
              image: AssetImage("assets/images/google_maps_location_picker.png"),
              width: 100,
              height: 100,
            ),
          ],
        ),
      ],
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
  final l10n = AppLocalizations.of(context)!;

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
                        l10n.addNewRegion,
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
                      decoration: InputDecoration(
                        labelText: l10n.regionName,
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    TextField(
                      controller: surfaceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.surfaceArea,
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
                              SnackBar(
                                content: Text(l10n.pleaseFillFields),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final surface = double.tryParse(surfaceController.text);
                          if (surface == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.invalidSurfaceValue),
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
                                      return ApiResponse.error(l10n.requestTimeout);
                                    },
                                  );

                          if (response.status == Status.COMPLETED) {
                            Navigator.of(dialogContext).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    response.message ?? l10n.failedToAddRegion),
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
                          l10n.addRegion,
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