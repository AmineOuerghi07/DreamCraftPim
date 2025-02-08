import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/view/screens/home_screen.dart';
import 'package:pim_project/view/screens/land_details_screen.dart';
import 'package:pim_project/view/screens/land_screen.dart';
import 'package:pim_project/view/screens/main_screen.dart';
import 'package:pim_project/view/screens/market_screen.dart';
import 'package:pim_project/view/screens/region_details_screen.dart';
import 'package:pim_project/view/screens/profile_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GlobalKey<NavigatorState> shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

class RouteNames {
  static const String home = '/';
  static const String market = '/market_screen';
  static const String regionDetails = '/region-details';
  static const String profile = '/profile';
  static const String landDetails = '/land-details';
  static const String land = '/land';
}

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RouteNames.home,
  routes: [
    // ✅ Shell Route to keep BottomNavigationBar visible
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        return MainScreen(child: child); // ✅ Keeps BottomNavigationBar fixed
      },
      routes: [
        GoRoute(
          path: RouteNames.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: RouteNames.market,
          builder: (context, state) => const MarketScreen(),
        ),
        GoRoute(
          path: RouteNames.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: RouteNames.land,
          builder: (context, state) => const LandScreen(),
        ),
      ],
    ),

    // ✅ Land Details Route (outside ShellRoute since it's a separate screen)
    GoRoute(
      path: '${RouteNames.landDetails}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return LandDetailsScreen(id: id);
      },
    ),
    GoRoute(
      path: '${RouteNames.regionDetails}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return RegionDetailsScreen(id: id);
      },
    ),
  ],
);
