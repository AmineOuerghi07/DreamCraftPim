// view/screens/components/header.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../constants/constants.dart';
import '../../../../routes/routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Pour TimeoutException

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
      final url = Uri.parse('${AppConstants.baseUrl}/account/get-account/${widget.userId}');
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
  void didUpdateWidget(Header oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _loadUserPhoto();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
   // final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    context.push(RouteNames.profile, extra: widget.userId);
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.green.shade100,
                    child: _isLoading
                        ? const CircularProgressIndicator(strokeWidth: 0)
                        : _photoUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  _photoUrl!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint('Erreur de chargement de l\'image: $error');
                                    return const Icon(
                                      Icons.person,
                                      size: 25,
                                      color: AppConstants.primaryColor,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 25,
                                color: AppConstants.primaryColor,
                              ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.hello,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.username,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // TODO: Implémenter la gestion des notifications
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}