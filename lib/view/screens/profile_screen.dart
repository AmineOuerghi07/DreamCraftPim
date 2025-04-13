import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/view/screens/about_screen.dart';
import 'package:pim_project/view/screens/contact_screen.dart';
import 'package:pim_project/view/screens/editprofile_screen.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/view/screens/language_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  bool _isPushNotificationEnabled = true; // Add this line

  @override
  void initState() {
    super.initState();
    print("📌 ProfileScreen initialized with userId: ${widget.userId}");
    if (widget.userId.isNotEmpty) {
      fetchUserProfile(widget.userId);
    } else {
      print("🚨 Error: userId is empty in ProfileScreen!");
    }
  }

  Future<void> fetchUserProfile(String userId) async {
  if (userId.isEmpty) {
    print("🚨 Error: User ID is empty! Not making request.");
    return;
  }

  final url = Uri.parse('${AppConstants.baseUrl}/account/get-account/$userId');
  print("🔵 Sending request to: $url");

  try {
    final response = await http.get(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          _profileData = data;
          _isLoading = false;
        });
      }
    } else {
      print('🔴 Error: Status Code ${response.statusCode}');
      print('🔴 Response Body: ${response.body}');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  } catch (e) {
    print('🔴 Exception while fetching profile: $e');
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 60.0, bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Avatar
              _isLoading
                  ? const CircularProgressIndicator()
                  : CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.green.shade100,
                      child: _profileData != null && 
                              _profileData!['photos'] != null &&
                              _profileData!['photos'].isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                _profileData!['photos'][0],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.person, size: 50, color: Colors.green);
                                },
                              ),
                            )
                          : const Icon(Icons.person, size: 50, color: Colors.green),
                    ),
              const SizedBox(height: 12),
              // Name and Email
              _isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      _profileData?['fullname'] ?? l10n.nameNotAvailable,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      _profileData?['email'] ?? l10n.emailNotAvailable,
                      style: const TextStyle(color: Colors.grey),
                    ),
              _isLoading
                  ? const CircularProgressIndicator()
                  : _profileData?['address'] != null
                      ? Text(
                          '${l10n.address}: ${_profileData!['address']}',
                          style: const TextStyle(color: Colors.grey),
                        )
                      : Container(),
              const SizedBox(height: 12),
              // Edit Profile Button
              ElevatedButton(
                onPressed: () {
                  context.push(RouteNames.editProfile);
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
              // Inventories Section
              _buildSectionTitle('Inventories'),
              _buildListItem(
                icon: Icons.receipt_long,
                title: l10n.myBillings,
                onTap: () {
                  // Handle My Billings tap
                },
              ),
              _buildListItem(
                icon: Icons.support_agent,
                title: l10n.contactSupport,
                onTap: () {
                  context.push(RouteNames.contact);
                },
              ),
              const SizedBox(height: 15),
              // Preferences Section
              _buildSectionTitle(l10n.preferences),
              _buildListItem(
                icon: Icons.notifications,
                title: l10n.pushNotification,
                trailing: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Switch(
                    value: _isPushNotificationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isPushNotificationEnabled = value;
                      });
                    },
                    activeColor: Colors.green,
                  ),
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
                  // Handle Change Language tap
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
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
