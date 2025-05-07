import 'package:flutter/material.dart';
import 'package:pim_project/ProviderClasses/cartProvider.dart';
import 'package:pim_project/view/screens/components/factureDialog.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/main.dart'; // Import for accessing MyApp.userId

class Marketheader extends StatefulWidget {
  final String greetingText;
  final String username;

  const Marketheader({
    required this.greetingText,
    required this.username,
    Key? key,
  }) : super(key: key);

  @override
  State<Marketheader> createState() => _MarketheaderState();
}

class _MarketheaderState extends State<Marketheader> {
  String? _photoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserPhoto();
  }

  Future<void> _loadUserPhoto() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/account/get-account/${MyApp.userId}');
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('La requête a expiré'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (mounted && data['image'] != null) {
          final imageUrl = '${AppConstants.imagesbaseURL}${data['image']}';
          
          try {
            final testResponse = await http.head(Uri.parse(imageUrl)).timeout(
              const Duration(seconds: 5),
              onTimeout: () => throw TimeoutException('La vérification de l\'image a expiré'),
            );
            
            if (testResponse.statusCode == 200 && mounted) {
              setState(() => _photoUrl = imageUrl);
            }
          } catch (e) {
            debugPrint('Erreur lors de la vérification de l\'image: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement de la photo: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Header background color
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _isLoading
                ? CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : _photoUrl != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(_photoUrl!),
                      backgroundColor: Colors.green.shade100,
                      onBackgroundImageError: (exception, stackTrace) {
                        debugPrint('Erreur de chargement de l\'image: $exception');
                      },
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(
                        Icons.person,
                        size: 25,
                        color: Colors.green,
                      ),
                    ),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${widget.greetingText} ',
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                    TextSpan(
                      text: widget.username, // from database
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return GestureDetector(
                child: const Icon(Icons.shopping_cart, color: Colors.green),
                onTap: () {
                  CartBottomSheet.show(context, () {
                    // Handle payment completion
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }
}