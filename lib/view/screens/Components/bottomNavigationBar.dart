import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/ProviderClasses/bottom_navigation_bar_provider_class.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:provider/provider.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavigationProvider>(
      builder: (context, provider, child) {
        return BottomNavigationBar(
          currentIndex: provider.selectedIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: "Market"),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: "Lands"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            provider.setIndex(index);

            switch (index) {
              case 0:
                context.go(RouteNames.home); // ✅ Uses `context.go()` for ShellRoute
                break;
              case 1:
                context.go(RouteNames.market);
                break;
              case 2:
                context.go(RouteNames.land);
                break;
              case 3:
                context.go(RouteNames.profile);
                break;
            }
          },
        );
      },
    );
  }
}
