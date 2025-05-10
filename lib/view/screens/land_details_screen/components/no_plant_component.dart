import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoPlantComponent extends StatelessWidget {
  const NoPlantComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_plants.png',
            width: isTablet ? 200 : 150,
            height: isTablet ? 200 : 150,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noPlantsFound, // Ensure this string is defined in your l10n files
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addPlant, // Ensure this string is defined in your l10n files
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}