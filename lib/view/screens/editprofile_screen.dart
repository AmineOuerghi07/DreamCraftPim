import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pim_project/main.dart';
import 'dart:io';
import 'package:pim_project/model/services/user_service.dart';
import 'package:pim_project/model/domain/user.dart';
import 'package:pim_project/model/services/UserPreferences.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  late UserService _userService;

  @override
  void initState() {
    super.initState();
    // Initialize ApiClient with the baseUrl from AppConstants
    final apiClient = ApiClient(baseUrl: AppConstants.baseUrl);
    _userService = UserService(apiClient: apiClient);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await UserPreferences.getUser();
    if (user != null) {
      setState(() {
        _fullNameController.text = user.fullname;
        _addressController.text = user.address;
        _phoneController.text = user.phonenumber;
        if (user.image != null && user.image!.isNotEmpty) {
          _image = File(user.image!);
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final userId = await UserPreferences.getUserId();

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Identifiant utilisateur introuvable')),
        );
        return;
      }

      try {
        Map<String, dynamic> updateData = {
          'fullname': _fullNameController.text,
          'address': _addressController.text,
          'phonenumber': _phoneController.text,
        };

        File? imageToUpload = _image;
        
        final response = await _userService.updateUserProfile(
          userId,
          updateData,
          imageToUpload,
        );

        if (response.status == Status.COMPLETED && response.data != null) {
          final updatedUser = response.data;

          await UserPreferences.setUser(updatedUser!);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil mis à jour avec succès')),
          );

          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : ${response.message}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur inattendue : ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
     appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () => context.pop(),
  ),
  title: Text(
    l10n.editProfile,
    style: const TextStyle(color: Colors.black),
  ),
  centerTitle: true,
),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
       GestureDetector(
  onTap: _pickImage,
  child: Column(
    children: [
      CircleAvatar(
        radius: 50,
        backgroundImage: _image != null ? FileImage(_image!) : null,
        child: _image == null
            ? const Icon(Icons.camera_alt, size: 50, color: Color(0xFF82C784))
            : null,
      ),
      const SizedBox(height: 8),
      Text(
        l10n.clickToChangePhoto,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    ],
  ),
),

              const SizedBox(height: 20),
               TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF4F4F4),
                  hintText: 'Full Name',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? l10n.pleaseEnterFullName : null,
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF4F4F4),
                  hintText: l10n.address,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? l10n.pleaseEnterAddress : null,
              ),
              const SizedBox(height: 16),


               // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF4F4F4),
                  hintText: l10n.phoneNumber,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? l10n.pleaseEnterPhoneNumber : null,
              ),
              const SizedBox(height: 20),


              // Save Button
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF488236),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.save, style: const TextStyle(color: Colors.white)),
              
              )
            ],
          ),
        ),
      ),
    );
  }
}