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
          setState(() {
            _photoUrl = '${AppConstants.imagesbaseURL}${data['image']}';
            print('🖼️ [Header] Image URL mise à jour: $_photoUrl');
          });
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
                            errorBuilder: (context, error, stackTrace) {
                              print('❌ Erreur lors du chargement de l\'image: $error');
                              return const Icon(Icons.person, size: 25, color: Colors.green);
                            },
                          ),
                        )
                      : const Icon(Icons.person, size: 25, color: Colors.green),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.greetingText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    widget.username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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