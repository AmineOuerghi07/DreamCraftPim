// view/screens/land_screen/components/add_land_dialog.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/view_model/land_view_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddLandDialog extends StatefulWidget {
  final String userId;

  const AddLandDialog({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AddLandDialog> createState() => _AddLandDialogState();
}

class _AddLandDialogState extends State<AddLandDialog> {
  File? selectedImage;
  final TextEditingController locationController = TextEditingController();
  final TextEditingController landNameController = TextEditingController();
  final TextEditingController spaceController = TextEditingController();
  bool isLoading = false;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveLand() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (landNameController.text.isEmpty ||
        locationController.text.isEmpty ||
        spaceController.text.isEmpty ||
        selectedImage == null) {
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
            backgroundColor: AppConstants.primaryColor,
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
    
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
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
                    onPressed: pickImage,
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
                  onPressed: isLoading ? null : _saveLand,
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
      ),
    );
  }
}