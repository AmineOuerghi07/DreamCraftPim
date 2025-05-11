import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/view_model/land_details_view_model.dart';
import 'package:pim_project/view_model/land_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void showUpdateLandDialog(BuildContext parentContext, Land land) {
  //final l10n = AppLocalizations.of(parentContext)!;
  File? _selectedImage;
  
  TextEditingController locationController = TextEditingController(text: land.cordonate);
  TextEditingController landNameController = TextEditingController(text: land.name);
  TextEditingController spaceController = TextEditingController(text: land.surface.toString());
  bool _isForRent = land.forRent;

  // Declare isLoading outside of the StatefulBuilder so it persists.
  bool isLoading = false;

  // Get screen width for responsive dialog
  final screenWidth = MediaQuery.of(parentContext).size.width;
  final isTablet = screenWidth > 600;

  Future<void> _pickImage(StateSetter setState) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                                  ScaffoldMessenger.of(parentContext).showSnackBar(
                                    SnackBar(
                                      content: Text(dialogL10n.fillAllFields),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
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
                                  ScaffoldMessenger.of(parentContext).showSnackBar(
                                    SnackBar(
                                      content: Text(response.message ?? dialogL10n.updateFailed),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
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