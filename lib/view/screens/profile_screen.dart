// view/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pim_project/view_model/login_view_model.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isPushNotificationEnabled = true;
  
  @override
  void initState() {
    super.initState();
    if (widget.userId.isNotEmpty) {
      fetchUserProfile(widget.userId);
    }
  }

  Future<void> fetchUserProfile(String userId) async {
    final url =
        Uri.parse('${AppConstants.baseUrl}/account/get-account/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _profileData = data;
          });
        }
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  Future<void> _handleLogout() async {
    try {
      final loginViewModel = context.read<LoginViewModel>();
      await loginViewModel.logout();
      
      if (mounted) {
        // Forcer la navigation vers l'écran de connexion
        context.go(RouteNames.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Get screen dimensions for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    // Calculate responsive sizes
    final avatarRadius = isTablet ? 50.0 : 40.0;
    final titleSize = isTablet ? 20.0 : 16.0;
    final textSize = isTablet ? 16.0 : 14.0;
    final iconSize = isTablet ? 24.0 : 20.0;
    final verticalSpacing = isTablet ? 20.0 : 16.0;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _profileData == null
            ? Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // En-tête profil
                    Container(
                      padding: EdgeInsets.only(top: 30, bottom: 20),
                      child: Column(
                        children: [
                          // Photo de profil
                          CircleAvatar(
                            radius: avatarRadius,
                            backgroundColor: Colors.grey.shade100,
                            child: _profileData != null && _profileData!['image'] != null
                                ? ClipOval(
                                    child: Image.network(
                                      _profileData!['image'].startsWith('http')
                                          ? _profileData!['image']
                                          : '${AppConstants.imagesbaseURL}${_profileData!['image']}',
                                      width: avatarRadius * 2,
                                      height: avatarRadius * 2,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.person,
                                          color: Colors.green.shade800,
                                          size: avatarRadius,
                                        );
                                      },
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: avatarRadius,
                                    color: Colors.green.shade800,
                                  ),
                          ),
                          SizedBox(height: 10),
                          
                          // Nom complet
                          Text(
                            _profileData?['fullname'] ?? l10n.nameNotAvailable,
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          // Email
                          if (_profileData?['email'] != null) ...[
                            SizedBox(height: 6),
                            Text(
                              _profileData!['email'],
                              style: TextStyle(
                                fontSize: textSize,
                                color: Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          
                          // Adresse si disponible
                          if (_profileData?['address'] != null) ...[
                            SizedBox(height: 4),
                            Text(
                              _profileData!['address'],
                              style: TextStyle(
                                fontSize: textSize,
                                color: Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          
                          SizedBox(height: 20),
                          
                          // Bouton d'édition du profil
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: OutlinedButton.icon(
                              onPressed: () {
                                if (_profileData != null) {
                                  context.push(RouteNames.editProfile, extra: _profileData);
                                }
                              },
                              icon: Icon(Icons.edit_outlined, size: 18),
                              label: Text(l10n.editProfile),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green.shade800,
                                side: BorderSide(color: Colors.green.shade200),
                                padding: EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Divider(color: Colors.grey.shade200),
                    
                    // Contenu principal
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Outils
                          Text(
                            l10n.myBillings.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildSimpleListItem(
                            icon: Icons.receipt_long,
                            title: l10n.myBillings,
                            onTap: () {},
                            iconSize: iconSize,
                          ),
                          Divider(color: Colors.grey.shade200),
                          _buildSimpleListItem(
                            icon: Icons.support_agent,
                            title: l10n.contactSupport,
                            onTap: () {
                              context.push(RouteNames.contact);
                            },
                            iconSize: iconSize,
                          ),
                          
                          SizedBox(height: verticalSpacing * 1.2),
                          
                          // Section paramètres
                          Text(
                            l10n.preferences.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 8),
                          
                          // Notifications
                          _buildSwitchItem(
                            icon: Icons.notifications_outlined,
                            title: l10n.pushNotification,
                            value: _isPushNotificationEnabled,
                            onChanged: (value) {
                              setState(() {
                                _isPushNotificationEnabled = value;
                              });
                            },
                            iconSize: iconSize,
                          ),
                          
                          Divider(color: Colors.grey.shade200),
                          _buildSimpleListItem(
                            icon: Icons.language,
                            title: l10n.changeLanguage,
                            onTap: () {
                              context.go(RouteNames.languageScreen);
                            },
                            iconSize: iconSize,
                          ),
                          
                          Divider(color: Colors.grey.shade200),
                          _buildSimpleListItem(
                            icon: Icons.info_outline,
                            title: l10n.about,
                            onTap: () {
                              context.push(RouteNames.about);
                            },
                            iconSize: iconSize,
                          ),
                          
                          SizedBox(height: verticalSpacing * 2),
                          
                          // Bouton de déconnexion
                          Container(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: _handleLogout,
                              child: Text(
                                l10n.logout,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 16,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSimpleListItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required double iconSize,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: iconSize,
              color: Colors.grey.shade700,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: iconSize - 8,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required double iconSize,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: iconSize,
            color: Colors.grey.shade700,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.green.shade600,
          ),
        ],
      ),
    );
  }
}
