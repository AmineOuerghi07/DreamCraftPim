// view/screens/land_screen/components/no_lands_component.dart

import 'package:flutter/material.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoLandsComponent extends StatelessWidget {
  final VoidCallback? onAddLandPressed;

  const NoLandsComponent({
    Key? key,
    this.onAddLandPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image with some padding
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Image.asset(
              'assets/images/no_lands.png',
              width: 200,
              height: 200,
            ),
          ),
          // No lands message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              l10n.noLandData,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Subtitle message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              l10n.addYourFirstLand,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Add land button
          if (onAddLandPressed != null)
            ElevatedButton.icon(
              onPressed: onAddLandPressed,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                l10n.clickToAddLand,
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}