import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
          }
        });
        return _buildScaffold(context, viewModel.landResponse);
      },
    );
     
  }

  Widget _buildScaffold(BuildContext context,ApiResponse<Land> response) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
    //      backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.go(RouteNames.land),
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
        body: _buildBody(context,response),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Update Land",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: landNameController,
                      decoration: const InputDecoration(
                        labelText: "Land Name",
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: "Location",
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: spaceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Space (m²)",
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // For Rent Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("For Rent:",
                            style: TextStyle(fontSize: 16)),
                        ToggleButtons(
                          isSelected: [_isForRent, !_isForRent],
                          onPressed: (index) {
                            setState(() {
                              _isForRent = index == 0;
                            });
                          },
                          children: const [
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text("Yes")),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text("No")),
                          ],
                          borderColor: Colors.grey,
                          selectedBorderColor: Colors.green,
                          selectedColor: Colors.white,
                          fillColor: Colors.green.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                                ? Icon(Icons.image,
                                    color: Colors.green.shade700)
                                : const SizedBox.shrink()),
                      ],
                    ),
                    const SizedBox(height: 20),
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
                                    content: Text(
                                        "Please fill all required fields"),
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
                                  surface: double.tryParse(
                                      spaceController.text),
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
                                  Navigator.of(dialogContext)
                                      .pop(); // Close dialog
                                  await viewModel.fetchLandById(land.id);
  final viewModelLand = Provider.of<LandViewModel>(
                                    parentContext,
                                    listen: false);
                                    viewModelLand.fetchLands();                                
                                    } else {
                                  ScaffoldMessenger.of(parentContext)
                                      .showSnackBar(SnackBar(
                                    content: Text(response.message ??
                                        "Update failed"),
                                    backgroundColor: Colors.red,
                                  ));
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("Update",
                                style: TextStyle(color: Colors.white)),
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
void _showDeleteConfirmationDialog(BuildContext context, LandDetailsViewModel viewModel) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Confirm Delete'),
      content: const Text('Are you sure you want to delete this land?'),
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
 Provider.of<LandViewModel>(context, listen: false).fetchLands();
             }
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

  Widget _buildBody(BuildContext context,ApiResponse<Land> response) {
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
    return _buildLandContent(context,land);
  }

  Widget _buildLandContent(BuildContext context, Land land) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RegionInfo(
            regionCount: "34", 
            cultivationType: land.name,
            location: land.cordonate,
            onAddRegion: () => _showAddRegionPopup(context, land.id),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              margin: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoCard(
                      title: "Expanse",
                      value: "${land.surface}m²",
                      imageName: "square_foot.png"),
                  InfoCard(
                      title: "Humidity",
                      value: "${land.surface }%",
                      imageName: "humidity.png"),
                  InfoCard(
                      title: "Plants",
                      value: "${land.surface } ",
                      imageName: "plant.png"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green,
            tabs: [
              Tab(text: "Land Regions"),
              Tab(text: "Plants"),
            ],
          ),
          const SizedBox(height: 16),
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
                    print("efezfez${viewModel.regions}");
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
}

void _showAddRegionPopup(BuildContext context, String landId) {
  TextEditingController nameController = TextEditingController();
  TextEditingController surfaceController = TextEditingController();


  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Region Name",
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: surfaceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Surface Area (m²)",
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed:  () async {
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
                                  // Add other required fields as per your Region model
                                );

                                final response = await viewModel.addRegion(newRegion)
      .timeout(const Duration(seconds: 15), onTimeout: () {
        return ApiResponse.error('Request timed out');
      });

                               
                                if (response.status == Status.COMPLETED) {
                                  Navigator.of(dialogContext).pop();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response.message ??
                                          "Failed to add region"),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: 
                             const Text("Add Region",
                                style: TextStyle(color: Colors.white)),
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