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

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _profileData;
  bool _isPushNotificationEnabled = true;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    if (widget.userId.isNotEmpty) {
      fetchUserProfile(widget.userId);
    }
    
    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Start the animation
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    final isSmallPhone = screenSize.width < 360;
    
    // Calculate responsive sizes
    final avatarRadius = isTablet ? 75.0 : (isSmallPhone ? 45.0 : 55.0);
    final nameTextSize = isTablet ? 26.0 : (isSmallPhone ? 20.0 : 22.0);
    final emailTextSize = isTablet ? 16.0 : 14.0;
    final sectionTitleSize = isTablet ? 18.0 : 16.0;
    final iconSize = isTablet ? 28.0 : 24.0;
    final contentPadding = EdgeInsets.symmetric(
      horizontal: isTablet ? 30.0 : 15.0, 
      vertical: isTablet ? 60.0 : 40.0
    );
    final buttonHeight = isTablet ? 55.0 : 45.0;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Action pour les paramètres
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF3E754E),
                  const Color(0xFF5A9A6F),
                  Colors.white,
                  Colors.white,
                ],
                stops: const [0.0, 0.2, 0.5, 1.0],
              ),
            ),
          ),
          
          // Wave decoration
          Positioned(
            top: screenSize.height * 0.15,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: 100,
                color: Colors.white,
              ),
            ),
          ),
          
          // Content
          FadeTransition(
            opacity: _opacityAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: contentPadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenSize.height * 0.02),
                      
                      // Profile Avatar with decoration
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: Colors.white,
                          child: _profileData != null && _profileData!['image'] != null
                              ? Hero(
                                  tag: 'profile-image',
                                  child: ClipOval(
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
                                        return Icon(Icons.person, 
                                          color: const Color(0xFF3E754E),
                                          size: avatarRadius,
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.person, 
                                  size: avatarRadius, 
                                  color: const Color(0xFF3E754E),
                                ),
                        ),
                      ),
                      SizedBox(height: isTablet ? 20 : 12),
                      
                      // User info section with glass effect
                      Container(
                        width: isTablet ? screenSize.width * 0.6 : double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 25 : 15, 
                          horizontal: isTablet ? 30 : 20
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Name and Email
                            Text(
                              _profileData?['fullname'] ?? l10n.nameNotAvailable,
                              style: GoogleFonts.montserrat(
                                fontSize: nameTextSize, 
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF3E754E),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isTablet ? 8 : 4),
                            Text(
                              _profileData?['email'] ?? l10n.emailNotAvailable,
                              style: GoogleFonts.roboto(
                                color: Colors.grey.shade700,
                                fontSize: emailTextSize,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_profileData?['address'] != null) ...[
                              SizedBox(height: isTablet ? 8 : 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on, 
                                    size: emailTextSize, 
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      _profileData!['address'],
                                      style: GoogleFonts.roboto(
                                        color: Colors.grey.shade600,
                                        fontSize: emailTextSize,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            SizedBox(height: isTablet ? 25 : 15),
                            
                            // Edit Profile button
                            Container(
                              width: isTablet ? screenSize.width * 0.3 : screenSize.width * 0.6,
                              height: buttonHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(buttonHeight / 2),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF3E754E),
                                    Color(0xFF5A9A6F),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3E754E).withOpacity(0.3),
                                    blurRadius: 15,
                                    spreadRadius: -5,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_profileData != null) {
                                    context.push(RouteNames.editProfile, extra: _profileData);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(buttonHeight / 2),
                                  ),
                                ),
                                child: Text(
                                  l10n.editProfile, 
                                  style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: isTablet ? 30 : 20),
                      
                      // Sections with modern card design
                      Container(
                        width: isTablet ? screenSize.width * 0.6 : double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        padding: EdgeInsets.all(isTablet ? 30 : 20),
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
                            
                            Divider(
                              height: isTablet ? 40 : 30, 
                              thickness: 1, 
                              color: Colors.grey.shade200,
                            ),
                            
                            // Preferences
                            _buildSectionTitle(
                              l10n.preferences,
                              isTablet,
                              sectionTitleSize
                            ),
                            _buildListItem(
                              icon: Icons.notifications_active,
                              title: l10n.pushNotification,
                              trailing: Switch.adaptive(
                                value: _isPushNotificationEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _isPushNotificationEnabled = value;
                                  });
                                },
                                activeColor: const Color(0xFF3E754E),
                                activeTrackColor: const Color(0xFF3E754E).withOpacity(0.4),
                              ),
                              isTablet: isTablet,
                              iconSize: iconSize,
                            ),
                            _buildListItem(
                              icon: Icons.info_outline,
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
                            
                            SizedBox(height: isTablet ? 25 : 15),
                            
                            // Logout section with special styling
                            Container(
                              width: isTablet ? screenSize.width * 0.5 : double.infinity,
                              height: buttonHeight,
                              margin: EdgeInsets.only(top: isTablet ? 12 : 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.shade400,
                                    Colors.red.shade600,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(buttonHeight / 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 15,
                                    spreadRadius: -5,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _handleLogout,
                                  borderRadius: BorderRadius.circular(buttonHeight / 2),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.logout,
                                          color: Colors.white,
                                          size: iconSize,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          l10n.logout,
                                          style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontSize: isTablet ? 18 : 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: isTablet ? 20 : 10),
                      
                      // Version info
                      Text(
                        'Version 1.0.0',
                        style: GoogleFonts.roboto(
                          color: Colors.grey.shade500,
                          fontSize: isTablet ? 14 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isTablet, double fontSize) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isTablet ? 20.0 : 15.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey.shade200,
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.montserrat(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3E754E),
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey.shade200,
              thickness: 1,
            ),
          ),
        ],
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
      margin: EdgeInsets.symmetric(vertical: isTablet ? 6.0 : 4.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20.0 : 16.0,
          vertical: isTablet ? 6.0 : 2.0,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: textColor != null 
                ? textColor.withOpacity(0.1) 
                : const Color(0xFF3E754E).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon, 
            color: textColor ?? const Color(0xFF3E754E),
            size: iconSize,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.roboto(
            color: textColor ?? Colors.black87,
            fontSize: isTablet ? 18.0 : 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing ?? Icon(
          Icons.arrow_forward_ios, 
          size: isTablet ? 18 : 16,
          color: textColor ?? Colors.grey,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

// Wave clipper for decorative background
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    
    var firstControlPoint = Offset(size.width / 4, size.height - 30);
    var firstEndPoint = Offset(size.width / 2, size.height - 40);
    path.quadraticBezierTo(
      firstControlPoint.dx, firstControlPoint.dy, 
      firstEndPoint.dx, firstEndPoint.dy
    );
    
    var secondControlPoint = Offset(size.width * 0.75, size.height - 50);
    var secondEndPoint = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(
      secondControlPoint.dx, secondControlPoint.dy, 
      secondEndPoint.dx, secondEndPoint.dy
    );
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
