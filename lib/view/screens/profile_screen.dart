import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.only(left: 20.0,right: 20.0, top: 60.0 , bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Avatar
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/profile.png'), 
              ),
              SizedBox(height: 12),
              // Name and Email
              Text(
                'Hamid Kano',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Hamid.kano@gmail.com',
                style: TextStyle(color: Colors.grey),
              ),
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
                child: Text('Edit Profile' , style: TextStyle(color: Colors.white),),
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
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // Handle toggle
                  },
                  activeColor: Colors.green,
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
                onTap: () {
                  // Handle Logout
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
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

