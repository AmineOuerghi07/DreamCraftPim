import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/routes/routes.dart';
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
    return Consumer<LandViewModel>(
      builder: (context, viewModel, child) {
        final response = viewModel.landResponse;

        // Trigger fetch if needed
        if (response.status == Status.INITIAL || 
            (response.status == Status.COMPLETED && response.data?.id != id)) {
          Future.microtask(() => viewModel.fetchLandById(id));
        }

        return _buildScaffold(context,response);
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
        body: _buildBody(response),
      ),
    );
  }


void _handleMenuSelection(String value, BuildContext context) {
  final viewModel = Provider.of<LandViewModel>(context, listen: false);
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

void _showUpdateLandPopup(BuildContext context, Land land) {
  File? _selectedImage;
  TextEditingController locationController = TextEditingController(text: land.cordonate);
  TextEditingController landNameController = TextEditingController(text: land.name);
  TextEditingController spaceController = TextEditingController(text: land.surface.toString());
  bool isLoading = false;
  bool _isForRent = land.forRent;

  Future<void> _pickImage(StateSetter setState) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        onPressed: () => Navigator.of(context).pop(),
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
                        const Text("For Rent:", style: TextStyle(fontSize: 16)),
                        ToggleButtons(
                          isSelected: [_isForRent, !_isForRent],
                          onPressed: (index) => setState(() => _isForRent = index == 0),
                          children: const [
                            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Yes")),
                            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("No")),
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
                          onPressed: () async => await _pickImage(setState),
                          child: const Text(
                            "Change Image",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        if (_selectedImage != null)
                          const Icon(Icons.check_circle, color: Colors.green)
                        else if (land.image.isNotEmpty)
                          Icon(Icons.image, color: Colors.green.shade700)
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          if (landNameController.text.isEmpty || 
                              locationController.text.isEmpty || 
                              spaceController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please fill all required fields"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          setState(() => isLoading = true);
                          
                          final updatedLand = land.copyWith(
                            name: landNameController.text,
                            cordonate: locationController.text,
                            surface: double.tryParse(spaceController.text),
                            forRent: _isForRent,
                          );

                          final viewModel = Provider.of<LandViewModel>(context, listen: false);
                          final response = await viewModel.updateLand(
                            id,
                            updatedLand,
                            image: _selectedImage,
                          );

                          setState(() => isLoading = false);
                          
                          if (response.status == Status.COMPLETED) {
                            Navigator.of(context).pop();
                           await viewModel.fetchLandById(id);
                              await viewModel.fetchLands();
   // Refresh data
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(response.message ?? "Update failed"),
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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Update", style: TextStyle(color: Colors.white)),
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
void _showDeleteConfirmationDialog(BuildContext context, LandViewModel viewModel) {
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
          
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

  Widget _buildBody(ApiResponse<Land> response) {
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
    return _buildLandContent(land);
  }

  Widget _buildLandContent(Land land) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RegionInfo(
            regionCount: "34", // Update with land.regionCount if available
            cultivationType: land.name ?? "N/A",
            location: land.cordonate,
            onAddRegion: () {},
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
                      value: "${land.surface ?? 'N/A'}%",
                      imageName: "humidity.png"),
                  InfoCard(
                      title: "Plants",
                      value: "${land.surface ?? 'N/A'} ",
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
                LandRegionsGrid(landId: id),
                PlantsGrid(landId: id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}