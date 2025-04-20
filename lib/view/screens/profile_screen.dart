import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final url = Uri.parse('${AppConstants.baseUrl}/account/get-account/$userId');
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green.shade100,
              child: _profileData != null && _profileData!['image'] != null
                  ? ClipOval(
                      child: Image.network(
                        // Vérifier si l'image contient déjà l'URL complète
                        _profileData!['image'].startsWith('http')
                            ? _profileData!['image']
                            : '${AppConstants.imagesbaseURL}${_profileData!['image']}',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('❌ Erreur de chargement d\'image: $error');
                          return const Icon(Icons.error, color: Colors.red);
                        },
                      ),
                    )
                  : const Icon(Icons.person, size: 50, color: Colors.green),
            ),
            const SizedBox(height: 12),
            // Name and Email
            Text(
              _profileData?['fullname'] ?? l10n.nameNotAvailable,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _profileData?['email'] ?? l10n.emailNotAvailable,
              style: const TextStyle(color: Colors.grey),
            ),
            if (_profileData?['address'] != null)
              Text(
                '${l10n.address}: ${_profileData!['address']}',
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 12),
            // Edit Profile
            ElevatedButton(
              onPressed: () {
                if (_profileData != null) {
                  context.push(RouteNames.editProfile, extra: _profileData);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(l10n.editProfile, style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 15),
            // Inventories
            _buildSectionTitle('Inventories'),
            _buildListItem(
              icon: Icons.receipt_long,
              title: l10n.myBillings,
              onTap: () {},
            ),
            _buildListItem(
              icon: Icons.support_agent,
              title: l10n.contactSupport,
              onTap: () {
                context.push(RouteNames.contact);
              },
            ),
            const SizedBox(height: 15),
            // Preferences
            _buildSectionTitle(l10n.preferences),
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
            ),
            _buildListItem(
              icon: Icons.info,
              title: l10n.about,
              onTap: () {
                context.push(RouteNames.about);
              },
            ),
            _buildListItem(
              icon: Icons.language,
              title: l10n.changeLanguage,
              onTap: () {
                context.go(RouteNames.languageScreen);
              },
            ),
            _buildListItem(
              icon: Icons.logout,
              title: l10n.logout,
              textColor: Colors.red,
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('userId');
                if (context.mounted) {
                  context.go(RouteNames.login);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
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
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}