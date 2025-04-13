import 'package:flutter/material.dart';
import '../../model/domain/user.dart';
import '../../constants/constants.dart';

class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  String _getImageUrl() {
    print('🖼️ [ProfileScreen] Construction de l\'URL de l\'image:');
    print('   - Image de l\'utilisateur: ${user.image}');
    print('   - URL de base: ${AppConstants.imagesbaseURL}');

    if (user.image != null) {
      final baseUrl = AppConstants.imagesbaseURL.endsWith('/') 
          ? AppConstants.imagesbaseURL.substring(0, AppConstants.imagesbaseURL.length - 1)
          : AppConstants.imagesbaseURL;
      final fullUrl = '$baseUrl/${user.image}';
      print('   ✅ Construction de l\'URL complète: $fullUrl');
      return fullUrl;
    }
    print('   ⚠️ Utilisation de l\'image par défaut');
    return 'assets/images/default_profile.png';
  }

  @override
  Widget build(BuildContext context) {
    print('🖼️ [ProfileScreen] Construction du widget');
    print('   - ID utilisateur: ${user.userId}');
    print('   - Nom: ${user.fullname}');
    print('   - Image: ${user.image}');
    
    final imageUrl = _getImageUrl();
    print('   - URL finale de l\'image: $imageUrl');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user.image != null
                  ? NetworkImage(_getImageUrl())
                  : const AssetImage('assets/images/default_profile.png') as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(
              user.fullname,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Téléphone'),
              subtitle: Text(user.phone),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Adresse'),
              subtitle: Text(user.address),
            ),
          ],
        ),
      ),
    );
  }
} 