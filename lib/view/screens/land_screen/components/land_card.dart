import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pim_project/constants/constants.dart';

class LandCard extends StatelessWidget {
  final String title;
  final String location;
  final String description;
  final String imageUrl;
  final String id;
  final VoidCallback onDetailsTap;

  const LandCard({
    required this.title,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.id,
    required this.onDetailsTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 4,
      child: Row(
        children: [
          const Padding(padding: EdgeInsets.only(left: 8)),
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(8),
              right: Radius.circular(8),
            ),
            child: Image.network(
              imageUrl,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  width: 100,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 40,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 100,
                  width: 100,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Color(0xFF777777),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF777777),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    ElevatedButton(
                      onPressed: onDetailsTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.readDetails,
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}