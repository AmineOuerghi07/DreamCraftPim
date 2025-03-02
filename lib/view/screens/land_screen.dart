import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/view/screens/Components/header.dart';
import 'package:pim_project/view/screens/Components/search_bar.dart'
as custom;
import 'package:pim_project/view/screens/Components/home_cart.dart';
import 'package:pim_project/view/screens/map_screen.dart';
import 'package:pim_project/view_model/land_view_model.dart';
import 'package:provider/provider.dart';

class LandScreen extends StatelessWidget  {
  const LandScreen({
    super.key
  });


 void _loadData(BuildContext context) {
    final viewModel = Provider.of<LandViewModel>(context, listen: false);
      viewModel.fetchLands();
}
  @override
  Widget build(BuildContext context) {
    // Define the search controller
  Provider.of<LandViewModel>(context, listen: false).fetchLands();
      final TextEditingController searchController = TextEditingController();
    final FocusNode searchFocusNode = FocusNode();
    void _unfocus() {
      if (searchFocusNode.hasFocus) {
        searchFocusNode.unfocus();
      }
    }

void _showAddLandPopup(BuildContext context) {
  File? _selectedImage;
  TextEditingController locationController = TextEditingController();
  TextEditingController landNameController = TextEditingController();
  TextEditingController spaceController = TextEditingController();
  bool isLoading = false;

  Future<void> _pickImage(StateSetter setState) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _getCurrentLocation(StateSetter setState) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];

    setState(() {
      locationController.text = "${place.locality}, ${place.country}";
    });
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
                    // Close Icon
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => context.pop(),
                      ),
                    ),

                    // Title
                    Center(
                      child: Text(
                        "Add New Land",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Land Name Input
                    TextField(
                      controller: landNameController,
                      decoration: const InputDecoration(
                        labelText: "Land Name",
                        hintText: "Enter the name of the land",
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Location Input with Map Picker
                    TextField(
                      controller: locationController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Location",
                        hintText: "Choose location on map",
                        border: const UnderlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.map, color: Colors.blue),
                          onPressed: () async {
                            final selectedLocation = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OSMFlutterMap(),
                              ),
                            );

                            if (selectedLocation != null) {
                              setState(() {
                                locationController.text = selectedLocation;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Land Space Input
                    TextField(
                      controller: spaceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Space (m²)",
                        hintText: "Enter the land size in square meters",
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Image Upload
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () async {
                            await _pickImage(setState);
                          },
                          child: const Text(
                            "Upload Image",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (_selectedImage != null)
                          const Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Save Button
                    Center(
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (landNameController.text.isEmpty ||
                                    locationController.text.isEmpty ||
                                    spaceController.text.isEmpty ||
                                    _selectedImage == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please fill all fields and upload an image."),
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
                                  surface: double.tryParse(spaceController.text) ?? 0.0, id: '', forRent: false, image: '', regions: [] ,
                                );

final landViewModel = Provider.of<LandViewModel>(context, listen: false);
await landViewModel.addLand(land: newLand, image: _selectedImage!)
    .then((response) {
  if (response.status == Status.COMPLETED) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Land added successfully!"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message ?? "Failed to add land."),
        backgroundColor: Colors.red,
      ),
    );
  }
                                });

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
                            : const Text("Save", style: TextStyle(color: Colors.white)),
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
      onTap: _unfocus,
      child: Scaffold(
        body: Column(
          children: [
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 26, vertical: 12)),
          const    Header(
                profileImage: "assets/images/profile.png",
                greetingText: "Haaa! ",
                username: "Mahamed",
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Use your custom SearchBar
                        custom.SearchBar(
                          controller: searchController,
                          focusNode: searchFocusNode,
                          onFilterTap: () {

                          },
                        ),
                        const SizedBox(height: 16),
                          const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                        const        Text(
                                  "Your Greenhouses",
                                  style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Consumer < LandViewModel > (
                                  builder: (context, viewModel, child) {
                                    return Text(
                                      "${viewModel.lands.length} Places",
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
                                child: Consumer < LandViewModel > (
                                  builder: (context, viewModel, child) {
                                    return _buildLandList(viewModel);
                                  },
                                )),
                      ],
                    ),
                ),
              ),
          ],
        ),
        // Floating Action Button with + icon
        floatingActionButton: SizedBox(
          width: 50,
          height: 50,
          child: FloatingActionButton(
            onPressed: () {
              // Show the popup dialog
              _showAddLandPopup(context);
            },
            backgroundColor: Colors.green.withOpacity(0.75), // Button color
            child: const Icon(
              Icons.add, // + icon
              color: Colors.white, // Icon color
              size: 30, // Icon size
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Position at the bottom right
      ),
    );
  }
}
Widget _buildLandList(LandViewModel viewModel) {
  if (viewModel.landsResponse.status == Status.LOADING) {
    return const Center(child: CircularProgressIndicator());
  } else if (viewModel.landsResponse.status == Status.ERROR) {
    return Center(child: Text("Error: ${viewModel.landsResponse.message}"));
  } else if (viewModel.lands.isEmpty) {
    return const Center(child: Text("No lands available."));
  }

  return ListView.builder(
    itemCount: viewModel.lands.length,
    itemBuilder: (context, index) {
      final land = viewModel.lands[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
          child: HomeCart(
            title: land.name,
            location: land.cordonate,
            description: "Surface: ${land.surface}m² • ${land.forRent ? 'For Rent' : 'Not Available'}",
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