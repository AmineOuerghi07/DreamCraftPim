import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/ProviderClasses/bottom_navigation_bar_provider_class.dart';
import 'package:pim_project/constants/constants.dart';
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
    return Consumer<BottomNavigationProvider>(
      builder: (context, provider, child) {
        return Directionality(
          textDirection: TextDirection.ltr, // Force LTR direction
          child: Stack(
            clipBehavior: Clip.none,
            children: [

              // Custom Bottom Navigation Bar
              Container(
                height: 60, // Height of the navigation bar
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home, color: provider.selectedIndex == 0 ? AppConstants.primaryColor : Colors.grey),
                            SizedBox(height: 4),
                            Text(l10n.home, style: TextStyle(fontSize: 12, color: provider.selectedIndex == 0 ? AppConstants.primaryColor : Colors.grey)),
                          ],
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.store, color: provider.selectedIndex == 1 ? AppConstants.primaryColor : Colors.grey),
                            SizedBox(height: 4),
                            Text(l10n.market, style: TextStyle(fontSize: 12, color: provider.selectedIndex == 1 ? AppConstants.primaryColor : Colors.grey)),
                          ],
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, color: provider.selectedIndex == 3 ? AppConstants.primaryColor : Colors.grey),
                            SizedBox(height: 4),
                            Text(l10n.lands, style: TextStyle(fontSize: 12, color: provider.selectedIndex == 3 ? AppConstants.primaryColor : Colors.grey)),
                          ],
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person, color: provider.selectedIndex == 4 ? AppConstants.primaryColor : Colors.grey),
                            SizedBox(height: 4),
                            Text(l10n.profile, style: TextStyle(fontSize: 12, color: provider.selectedIndex == 4 ? AppConstants.primaryColor : Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Floating Camera Icon
              Positioned(
                left: MediaQuery.of(context).size.width / 2 - 22.5, // Center the icon horizontally
                bottom: 25, // Adjust the elevation
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
                      color: AppConstants.primaryColor, // Background color of the circle
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
}