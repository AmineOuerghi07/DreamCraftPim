import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pim_project/model/services/user_service.dart';
import 'package:pim_project/model/domain/user.dart';
import 'package:pim_project/model/services/UserPreferences.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

import 'package:pim_project/routes/routes.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  
  const EditProfileScreen({super.key, this.userData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _showPasswordFields = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _currentImageUrl;

  late UserService _userService;

  @override
  void initState() {
    super.initState();
    print('🔄 EditProfileScreen initialisé');
    final apiClient = ApiClient(baseUrl: AppConstants.baseUrl);
    _userService = UserService(apiClient: apiClient);
  }

 

  Future<void> _pickImage() async {
    print('📸 Début de la sélection d\'image...');
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      print('📂 Fichier sélectionné: ${pickedFile?.path}');

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          print('✅ Image chargée avec succès: ${_image?.path}');
        });
      } else {
        print('❌ Aucune image sélectionnée');
      }
    } catch (e) {
      print('❌ Erreur lors de la sélection de l\'image: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final userId = await UserPreferences.getUserId();
      if (userId == null) {
        throw Exception('Identifiant utilisateur introuvable');
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${AppConstants.baseUrl}/account/update/$userId'),
      );

      // Add text fields
      Map<String, String> fields = {
        'fullname': _fullNameController.text.trim(),
        'address': _addressController.text.trim(),
        'phonenumber': _phoneController.text.trim(),
        
      };

      request.fields.addAll(fields);

      if (_showPasswordFields && _passwordController.text.isNotEmpty) {
        if (_passwordController.text != _confirmPasswordController.text) {
          throw Exception('Les mots de passe ne correspondent pas');
        }
        request.fields['password'] = _passwordController.text;
      }

      if (_image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            _image!.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil mis à jour avec succès"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Retourner directement au profil
        context.go(RouteNames.profile, extra: {'userId': userId});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Échec de la mise à jour du profil"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.editProfile,
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.green.shade100,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : (_currentImageUrl != null
                              ? NetworkImage(_currentImageUrl!) as ImageProvider
                              : null),
                      child: (_image == null && _currentImageUrl == null)
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
                  labelText: l10n.fullName,
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: l10n.address,
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: Text(l10n.changePassword),
                value: _showPasswordFields,
                onChanged: (value) {
                  setState(() {
                    _showPasswordFields = value ?? false;
                  });
                },
              ),
              if (_showPasswordFields) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: l10n.newPassword,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (_showPasswordFields && (value == null || value.isEmpty)) {
                      return l10n.pleaseEnterPassword;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: l10n.confirmPassword,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (_showPasswordFields) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseConfirmPassword;
                      }
                      if (value != _passwordController.text) {
                        return l10n.passwordsDoNotMatch;
                      }
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
