import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/ProviderClasses/bottom_navigation_bar_provider_class.dart';
import 'package:pim_project/main.dart';

import 'package:pim_project/routes/routes.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

  Future<void> _openCamera(BuildContext context) async {
    context.push(RouteNames.camera);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculer une hauteur responsive pour la barre de navigation
    final navBarHeight = screenHeight * 0.08;
    // Limiter la hauteur entre 60 et 80
    final clampedNavBarHeight = navBarHeight.clamp(60.0, 80.0);
    
    return Consumer<BottomNavigationProvider>(
      builder: (context, provider, child) {
        return Directionality(
          textDirection: TextDirection.ltr, // Force LTR direction
          child: Stack(
            clipBehavior: Clip.none,
            children: [

              // Custom Bottom Navigation Bar
              Container(
                height: clampedNavBarHeight, // Hauteur responsive
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Home
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          provider.setIndex(0);
                          context.go(RouteNames.home,extra:  MyApp.userId);
                        },
                        child: _buildNavItem(
                          Icons.home, 
                          l10n.home, 
                          provider.selectedIndex == 0,
                          clampedNavBarHeight
                        ),
                      ),
                    ),
                    // Market
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          provider.setIndex(1);
                          context.go(RouteNames.market);
                        },
                        child: _buildNavItem(
                          Icons.store, 
                          l10n.market, 
                          provider.selectedIndex == 1,
                          clampedNavBarHeight
                        ),
                      ),
                    ),
                    // Empty space for the camera icon
                    Expanded(
                      child: Container(), // Empty container to reserve space
                    ),
                    // Lands
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          provider.setIndex(3);
                          context.go(RouteNames.land);
                        },
                        child: _buildNavItem(
                          Icons.map, 
                          l10n.lands, 
                          provider.selectedIndex == 3,
                          clampedNavBarHeight
                        ),
                      ),
                    ),
                    // Profile
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          provider.setIndex(4);
                          context.go(RouteNames.profile,extra: MyApp.userId);
                        },
                        child: _buildNavItem(
                          Icons.person, 
                          l10n.profile, 
                          provider.selectedIndex == 4,
                          clampedNavBarHeight
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Floating Camera Icon
              Positioned(
                left: screenWidth / 2 - 25, // Centre l'icône horizontalement
                bottom: clampedNavBarHeight * 0.5, // Position responsive
                child: GestureDetector(
                  onTap: () async {
                    // Handle camera icon tap
                    await _openCamera(context);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green, // Background color of the circle
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Méthode d'aide pour construire un élément de navigation uniforme
  Widget _buildNavItem(IconData icon, String label, bool isSelected, double height) {
    final color = isSelected ? Colors.green : Colors.grey;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon, 
            color: color,
            size: height * 0.35, // Taille d'icône responsive
          ),
          SizedBox(height: height * 0.06),
          Text(
            label, 
            style: TextStyle(
              fontSize: height * 0.2, // Taille de texte responsive
              color: color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}