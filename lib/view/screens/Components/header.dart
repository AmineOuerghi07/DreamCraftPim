import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Header extends StatefulWidget {
  final String greetingText;
  final String username;
  final String userId;

  const Header({
    Key? key,
    required this.greetingText,
    required this.username,
    required this.userId,
  }) : super(key: key);

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserPhoto();
  }

  Future<void> _loadUserPhoto() async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/account/get-account/${widget.userId}');
      final response = await http.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (mounted && data['image'] != null) {
          // Vérifier si l'image n'est pas vide ou null
          final imageUrl = '${AppConstants.imagesbaseURL}${data['image']}';
          
          // Tester si l'URL est valide
          try {
            final testResponse = await http.head(Uri.parse(imageUrl));
            if (testResponse.statusCode == 200) {
              setState(() {
                _photoUrl = imageUrl;
                print('🖼️ [Header] Image URL mise à jour: $_photoUrl');
              });
            } else {
              print('❌ Image non accessible: ${testResponse.statusCode}');
            }
          } catch (e) {
            print('❌ Erreur lors du test de l\'URL de l\'image: $e');
          }
        }
      }
    } catch (e) {
      print('❌ Erreur lors du chargement de la photo: $e');
    }
  }

  @override
  void didUpdateWidget(Header oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _loadUserPhoto();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  context.push(RouteNames.profile, extra: widget.userId);
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green.shade100,
                  child: _photoUrl != null
                      ? ClipOval(
                            child: Image.network(
                              _photoUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('❌ Erreur de chargement de l\'image: $error');
                                return const Icon(Icons.person, size: 25, color: Colors.green);
                              },
                            ),
                          )
                        : const Icon(Icons.person, size: 25, color: Colors.green),
                ),
              ),
              const SizedBox(width: 12),
           Row(
  crossAxisAlignment: CrossAxisAlignment.center, // Align vertically centered
  children: [
    Text(
      widget.greetingText,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.grey,
        height: 1.2, // Makes vertical alignment tighter
      ),
    ),
    const SizedBox(width: 2), // very tight spacing
    Text(
      widget.username,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
    ),
  ],
),
 ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // Handle notification tap
            },
          ),
        ],
      ),
    );
  }
}