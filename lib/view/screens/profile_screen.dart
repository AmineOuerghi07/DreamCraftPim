// view/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
          SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
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
    final isSmallPhone = screenSize.width < 360;
    
    // Calculate responsive sizes
    final avatarRadius = isTablet ? 70.0 : (isSmallPhone ? 40.0 : 50.0);
    final nameTextSize = isTablet ? 24.0 : (isSmallPhone ? 18.0 : 20.0);
    final emailTextSize = isTablet ? 16.0 : 14.0;
    final sectionTitleSize = isTablet ? 18.0 : 16.0;
    final iconSize = isTablet ? 28.0 : 24.0;
    final contentPadding = EdgeInsets.symmetric(
      horizontal: isTablet ? 40.0 : 20.0, 
      vertical: isTablet ? 80.0 : 60.0
    );
    final buttonHeight = isTablet ? 50.0 : 40.0;
    
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: contentPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Avatar - Responsive size
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: Colors.green.shade100,
                child: _profileData != null && _profileData!['image'] != null
                    ? ClipOval(
                        child: Image.network(
                          // Vérifier si l'image contient déjà l'URL complète
                          _profileData!['image'].startsWith('http')
                              ? _profileData!['image']
                              : '${AppConstants.imagesbaseURL}${_profileData!['image']}',
                          width: avatarRadius * 2,
                          height: avatarRadius * 2,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('❌ Erreur de chargement d\'image: $error');
                            return Icon(Icons.error, 
                              color: Colors.red,
                              size: avatarRadius,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.person, 
                        size: avatarRadius, 
                        color: Colors.green
                      ),
              ),
              SizedBox(height: isTablet ? 20 : 12),
              
              // User info section - Responsive text sizes
              Container(
                width: isTablet ? screenSize.width * 0.6 : double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? 20 : 10, 
                  horizontal: isTablet ? 24 : 16
                ),
                decoration: BoxDecoration(
                  color: isTablet ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isTablet ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                    )
                  ] : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Name and Email
                    Text(
                      _profileData?['fullname'] ?? l10n.nameNotAvailable,
                      style: TextStyle(
                        fontSize: nameTextSize, 
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isTablet ? 8 : 4),
                    Text(
                      _profileData?['email'] ?? l10n.emailNotAvailable,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: emailTextSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_profileData?['address'] != null) ...[
                      SizedBox(height: isTablet ? 8 : 4),
                      Text(
                        '${l10n.address}: ${_profileData!['address']}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: emailTextSize,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    SizedBox(height: isTablet ? 20 : 12),
                    
                    // Edit Profile button
                    SizedBox(
                      width: isTablet ? screenSize.width * 0.3 : screenSize.width * 0.6,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_profileData != null) {
                            context.push(RouteNames.editProfile, extra: _profileData);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          l10n.editProfile, 
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
              
              SizedBox(height: isTablet ? 30 : 15),
              
              // Sections with responsive containers
              Container(
                width: isTablet ? screenSize.width * 0.6 : double.infinity,
                decoration: BoxDecoration(
                  color: isTablet ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isTablet ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                    )
                  ] : null,
                ),
                padding: EdgeInsets.all(isTablet ? 24 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Inventories
                    _buildSectionTitle(
                      AppLocalizations.of(context)!.inventories,
                      isTablet,
                      sectionTitleSize
                    ),
                    _buildListItem(
                      icon: Icons.receipt_long,
                      title: l10n.myBillings,
                      onTap: () {},
                      isTablet: isTablet,
                      iconSize: iconSize,
                    ),
                    _buildListItem(
                      icon: Icons.support_agent,
                      title: l10n.contactSupport,
                      onTap: () {
                        context.push(RouteNames.contact);
                      },
                      isTablet: isTablet,
                      iconSize: iconSize,
                    ),
                    
                    SizedBox(height: isTablet ? 24 : 15),
                    
                    // Preferences
                    _buildSectionTitle(
                      l10n.preferences,
                      isTablet,
                      sectionTitleSize
                    ),
                    _buildListItem(
                      icon: Icons.notifications,
                      title: l10n.pushNotification,
                      trailing: Switch(
                        value: _isPushNotificationEnabled,
                        onChanged: (value) {
                          setState(() {
                            _isPushNotificationEnabled = value;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                      isTablet: isTablet,
                      iconSize: iconSize,
                    ),
                    _buildListItem(
                      icon: Icons.info,
                      title: l10n.about,
                      onTap: () {
                        context.push(RouteNames.about);
                      },
                      isTablet: isTablet,
                      iconSize: iconSize,
                    ),
                    _buildListItem(
                      icon: Icons.language,
                      title: l10n.changeLanguage,
                      onTap: () {
                        context.go(RouteNames.languageScreen);
                      },
                      isTablet: isTablet,
                      iconSize: iconSize,
                    ),
                    
                    SizedBox(height: isTablet ? 20 : 10),
                    
                    // Logout section with special styling
                    Container(
                      width: isTablet ? screenSize.width * 0.5 : double.infinity,
                      margin: EdgeInsets.only(top: isTablet ? 12 : 8),
                      decoration: BoxDecoration(
                        color: isTablet ? Colors.red.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                      ),
                      child: _buildListItem(
                        icon: Icons.logout,
                        title: l10n.logout,
                        textColor: Colors.red,
                        onTap: _handleLogout,
                        isTablet: isTablet,
                        iconSize: iconSize,
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

  Widget _buildSectionTitle(String title, bool isTablet, double fontSize) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isTablet ? 16.0 : 8.0,
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    Color? textColor,
    required bool isTablet,
    required double iconSize,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: isTablet ? 6.0 : 2.0),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16.0 : 8.0,
          vertical: isTablet ? 4.0 : 0.0,
        ),
        leading: Icon(
          icon, 
          color: textColor ?? Colors.black,
          size: iconSize,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? Colors.black,
            fontSize: isTablet ? 18.0 : 16.0,
            fontWeight: isTablet ? FontWeight.w500 : FontWeight.normal,
          ),
          textAlign: isTablet ? TextAlign.center : TextAlign.start,
        ),
        trailing: trailing ?? Icon(
          Icons.arrow_forward_ios, 
          size: isTablet ? 20 : 16,
          color: Colors.grey,
        ),
        onTap: onTap,
        shape: isTablet ? RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ) : null,
        tileColor: isTablet && textColor == null ? Colors.grey.withOpacity(0.05) : null,
      ),
    );
  }
}
