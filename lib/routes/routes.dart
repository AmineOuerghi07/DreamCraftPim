import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/view/screens/home_screen.dart';
import 'package:pim_project/view/screens/land_details_screen.dart';
import 'package:pim_project/view/screens/market_screen.dart';
import 'package:pim_project/view/screens/region_details_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

// Define route names for better maintainability
class RouteNames {
  static const String home = '/';
  static const String landDetails = '/land-details';
  static const String RegionDetails = '/region-details';
  static const String Market = '/market_screen';
}

// Configure the GoRouter
final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RouteNames.home,
  routes: [
    // Home Route
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: RouteNames.Market,
      builder: (context, state) => const MarketScreen(),
    ),
    // here exmple of  Land Details Route (accepting a parameter)
    GoRoute(
      path: '${RouteNames.landDetails}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return LandDetailsScreen(id: id); // Pass the ID to the screen
      },
    ),
    GoRoute(
      path: '${RouteNames.RegionDetails}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return RegionDetailsScreen(id: id); // Pass the ID to the screen
      },
    ),
  ],
);
