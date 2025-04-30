import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NavigationHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const NavigationHeader({
    Key? key,
    required this.title,
    this.onBackPressed,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBackButton)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          else
            const SizedBox(width: 40),
            
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: screenWidth < 360 ? 16 : 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3E754E),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Espace pour équilibrer le bouton retour
          if (showBackButton)
            const SizedBox(width: 40)
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }
} 