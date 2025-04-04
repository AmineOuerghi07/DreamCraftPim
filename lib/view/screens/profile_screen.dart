import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:pim_project/routes/routes.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:pim_project/constants/constants.dart';

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
   // final userId = MyApp.userId;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 60.0, bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Avatar
              _isLoading
                  ? CircularProgressIndicator()
                  : CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileData != null &&
                              _profileData!['photos'] != null &&
                              _profileData!['photos'].isNotEmpty
                          ? NetworkImage(_profileData!['photos'][0])
                          : AssetImage('assets/images/gatous.png') as ImageProvider,
                    ),
              SizedBox(height: 12),
              // Name and Email
              _isLoading
                  ? CircularProgressIndicator()
                  : Text(
                      _profileData?['fullname'] ?? 'Name not available',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
              _isLoading
                  ? CircularProgressIndicator()
                  : Text(
                      _profileData?['email'] ?? 'Email not available',
                      style: TextStyle(color: Colors.grey),
                    ),
              _isLoading
                  ? CircularProgressIndicator()
                  : _profileData?['address'] != null
                      ? Text(
                          'Address: ${_profileData!['address']}',
                          style: TextStyle(color: Colors.grey),
                        )
                      : Container(),
              SizedBox(height: 12),
              // Edit Profile Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to Edit Profile
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Edit Profile', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 15),
              // Inventories Section
              _buildSectionTitle('Inventories'),
              _buildListItem(
                icon: Icons.receipt_long,
                title: 'My Billings',
                onTap: () {
                  // Handle My Billings tap
                },
              ),
              _buildListItem(
                icon: Icons.support_agent,
                title: 'Contact Support',
                onTap: () {
                  // Handle Contact Support tap
                },
              ),
              SizedBox(height: 15),
              // Preferences Section
              _buildSectionTitle('Preferences'),
              _buildListItem(
                icon: Icons.notifications,
                title: 'Push Notification',
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
                title: 'About',
                onTap: () {
                  // Handle About tap
                },
              ),
              _buildListItem(
                icon: Icons.language,
                title: 'Change Language',
                onTap: () {
                  // Handle Change Language tap
                },
              ),
              _buildListItem(
                icon: Icons.logout,
                title: 'Logout',
                textColor: Colors.red,
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.remove('userId'); // Clear saved user data
                  context.go(RouteNames.login); 
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
