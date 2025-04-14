import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pim_project/main.dart';
import 'dart:io';
import 'dart:async';  // Ajout de l'import pour TimeoutException
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
  bool _isLoading = false;
  bool _showPasswordFields = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _currentImageUrl;
  bool _formChanged = false;

  late UserService _userService;

  @override
void initState() {
  super.initState();
  print('🔄 EditProfileScreen initialisé');

  final apiClient = ApiClient(baseUrl: AppConstants.baseUrl);
  _userService = UserService(apiClient: apiClient);

    if (widget.userData != null) {
      _fullNameController.text = widget.userData!['fullname'] ?? '';
      _addressController.text = widget.userData!['address'] ?? '';
      _phoneController.text = widget.userData!['phonenumber'] ?? '';
      _currentImageUrl = widget.userData!['image']; // <- Récupère l'URL de l'image
      print('🌐 Image actuelle : $_currentImageUrl');
    }

    // Add listeners to detect changes in form fields
    _fullNameController.addListener(_onFormChanged);
    _addressController.addListener(_onFormChanged);
    _phoneController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
    _confirmPasswordController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    // Remove listeners when the widget is disposed
    _fullNameController.removeListener(_onFormChanged);
    _addressController.removeListener(_onFormChanged);
    _phoneController.removeListener(_onFormChanged);
    _passwordController.removeListener(_onFormChanged);
    _confirmPasswordController.removeListener(_onFormChanged);
    
    _fullNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {
      _formChanged = true;
    });
  }

  Future<void> _pickImage() async {
    print('📸 Début de la sélection d\'image...');
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      print('📂 Fichier sélectionné: ${pickedFile?.path}');

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _formChanged = true;
          print('✅ Image chargée avec succès: ${_image?.path}');
        });
      } else {
        print('❌ Aucune image sélectionnée');
      }
    } catch (e) {
      print('❌ Erreur lors de la sélection de l\'image: $e');
      _showErrorDialog('Error selecting image: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile() async {
    print('🔄 Début de la mise à jour du profil');
    if (!_formKey.currentState!.validate()) {
      print('❌ Validation du formulaire échouée');
      return;
    }

    // If no changes were made
    if (!_formChanged && _image == null) {
      print('ℹ️ Aucun changement détecté');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noChangesMessage ?? "No changes to save"),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    print('🔄 Chargement en cours...');

    try {
      final userId = await UserPreferences.getUserId();
      print('👤 ID utilisateur: $userId');
      if (userId == null) {
        throw Exception(AppLocalizations.of(context)!.userIdNotFound ?? 'User ID not found');
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${AppConstants.baseUrl}/account/update/$userId'),
      );
      print('🌐 URL de requête: ${AppConstants.baseUrl}/account/update/$userId');

      // Add text fields
      Map<String, String> fields = {
        'fullname': _fullNameController.text.trim(),
        'address': _addressController.text.trim(),
        'phonenumber': _phoneController.text.trim(),
      };

      request.fields.addAll(fields);
      print('📝 Champs ajoutés: $fields');

      if (_showPasswordFields && _passwordController.text.isNotEmpty) {
        if (_passwordController.text != _confirmPasswordController.text) {
          throw Exception(AppLocalizations.of(context)!.passwordsDoNotMatch ?? 'Passwords do not match');
        }
        request.fields['password'] = _passwordController.text;
        print('🔑 Mot de passe ajouté à la requête');
      }

      if (_image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            _image!.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
        print('📸 Image ajoutée à la requête: ${_image!.path}');
      }

      // Add token to headers if available
      final token = await UserPreferences.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
        print('🔐 Token d\'authentification ajouté');
      }

      print('📤 Envoi de la requête...');
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏱️ Délai d\'attente dépassé');
          throw TimeoutException('Request timed out. Please check your connection.');
        },
      );
      
      print('📥 Réponse reçue avec statut: ${streamedResponse.statusCode}');
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Mise à jour réussie!');
        // Parse the response to get updated user data
        final responseData = json.decode(response.body);
        print('📄 Données reçues: $responseData');
        final updatedUser = User.fromJson(responseData);
        
        // Update stored user data
        await UserPreferences.setUser(updatedUser);
        print('💾 Données utilisateur mises à jour localement');
        
        // Reset form changed flag
        setState(() {
          _formChanged = false;
        });
        
        // Show success message with detailed feedback
        _showSuccessMessage();
        print('📱 Message de succès affiché');
        
        // Return to profile screen after short delay
        print('⏳ Redirection vers le profil dans 2 secondes...');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            print('🔄 Redirection vers le profil');
            context.go(RouteNames.profile, extra: {'userId': userId});
          }
        });
      } else {
        // Try to parse error message from response
        String errorMsg;
        try {
          final errorData = json.decode(response.body);
          errorMsg = errorData['message'] ?? 
                    errorData['error'] ?? 
                    "Error code: ${response.statusCode}";
          print('❌ Erreur: $errorMsg');
        } catch (_) {
          errorMsg = "Error code: ${response.statusCode}";
          print('❌ Erreur de statut: ${response.statusCode}');
        }
        
        _showErrorSnackBar(errorMsg);
      }
    } on TimeoutException {
      print('⏱️ Exception de délai d\'attente');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(AppLocalizations.of(context)!.requestTimeout ?? 'Request timed out');
    } catch (e) {
      print('❌ Exception: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(e.toString());
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.profileUpdatedSuccess ?? "Profile updated successfully",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF82C784),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.editProfile,
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _updateProfile,
              tooltip: l10n.save,
            ),
        ],
      ),
      body: _isLoading 
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF82C784)),
            ),
          )
        : SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: Colors.black26,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Image Section
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF82C784),
                                    width: 3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.green.shade50,
                                  backgroundImage: _image != null 
                                    ? FileImage(_image!) 
                                    : (_currentImageUrl != null 
                                        ? NetworkImage(
                                            _currentImageUrl!.startsWith('http')
                                                ? _currentImageUrl!
                                                : '${AppConstants.imagesbaseURL}${_currentImageUrl!}'
                                          ) as ImageProvider 
                                        : null),
                                  child: (_image == null && _currentImageUrl == null)
                                    ? const Icon(Icons.person, size: 60, color: Color(0xFF82C784))
                                    : null,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF82C784),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.clickToChangePhoto,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Form Fields
                        _buildCustomTextField(
                          controller: _fullNameController,
                          label: l10n.fullName,
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.pleaseEnterName;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        _buildCustomTextField(
                          controller: _addressController,
                          label: l10n.address,
                          icon: Icons.location_on,
                        ),
                        const SizedBox(height: 20),
                        
                        _buildCustomTextField(
                          controller: _phoneController,
                          label: l10n.phoneNumber,
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),
                        
                        // Password Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CheckboxListTile(
                                title: Text(
                                  l10n.changePassword,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4B8B4B),
                                  ),
                                ),
                                value: _showPasswordFields,
                                activeColor: const Color(0xFF82C784),
                                contentPadding: EdgeInsets.zero,
                                controlAffinity: ListTileControlAffinity.leading,
                                onChanged: (value) {
                                  setState(() {
                                    _showPasswordFields = value ?? false;
                                    if (!_showPasswordFields) {
                                      _passwordController.clear();
                                      _confirmPasswordController.clear();
                                    }
                                  });
                                },
                              ),
                              if (_showPasswordFields) ...[
                                const SizedBox(height: 16),
                                _buildCustomTextField(
                                  controller: _passwordController,
                                  label: l10n.newPassword,
                                  icon: Icons.lock,
                                  obscureText: !_isPasswordVisible,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.green.shade700,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  validator: (value) {
                                    if (_showPasswordFields && (value == null || value.isEmpty)) {
                                      return l10n.pleaseEnterPassword;
                                    }
                                    if (_showPasswordFields && value != null && value.length < 6) {
                                      return l10n.passwordTooShort ?? 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildCustomTextField(
                                  controller: _confirmPasswordController,
                                  label: l10n.confirmPassword,
                                  icon: Icons.lock_outline,
                                  obscureText: !_isConfirmPasswordVisible,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.green.shade700,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                      });
                                    },
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
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Save Buttonac
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                              elevation: 2,
                              shadowColor: Colors.green.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.save),
                                    const SizedBox(width: 12),
                                    Text(
                                      l10n.save,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }
  
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF82C784)),
        suffixIcon: suffixIcon,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF82C784), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}