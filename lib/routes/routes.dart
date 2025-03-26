import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/main.dart';

import 'package:pim_project/view/screens/OTPVerificationScreen.dart';
import 'package:pim_project/view/screens/PhoneNumberScreen.dart';
import 'package:pim_project/view/screens/add_plant_screen.dart';
import 'package:pim_project/view/screens/camera_screen.dart';
import 'package:pim_project/view/screens/chat_screen.dart';
import 'package:pim_project/view/screens/email_verification_screen.dart';
import 'package:pim_project/view/screens/forget_password_screen.dart';
import 'package:pim_project/view/screens/home_screen.dart';
import 'package:pim_project/view/screens/land_details_screen.dart';
import 'package:pim_project/view/screens/land_screen.dart';
import 'package:pim_project/view/screens/loading_screen.dart';
import 'package:pim_project/view/screens/login_screen.dart';
import 'package:pim_project/view/screens/main_screen.dart';
import 'package:pim_project/view/screens/map_screen.dart';
import 'package:pim_project/view/screens/market_screen.dart';
import 'package:pim_project/view/screens/phone_verification_screen.dart';
import 'package:pim_project/view/screens/product_details_screen.dart';
import 'package:pim_project/view/screens/region_details_screen.dart';
import 'package:pim_project/view/screens/profile_screen.dart';
import 'package:pim_project/view/screens/reset_password_screen.dart';
import 'package:pim_project/view/screens/signup_screen.dart';
import 'package:pim_project/view_model/land_details_view_model.dart';
import 'package:provider/provider.dart';


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
  static const String login = '/login';
  static const String forgetPassword = '/forget-password';
  static const String signup = '/signup';
  static const String resetPassword = '/reset-password';
  static const String emailVerification = '/email-verification';
  static const String phoneVerification = '/phone-verification';
  static const String phoneNumberScreen = '/phone-number';
  static const String oTPVerification = '/otp-verification';
  static const String camera = '/camera' ;
  static const String productDetails = '/product-details';
  static const String loadingScreen= '/loading_screen';
  static const String chatScreen= '/chat_screen';
  static const String addplantScreen= '/add_plant_screen';
  static const String mapScreen= '/map_screen';


}




final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RouteNames.login,
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
          
          builder: (context, state) {
            String id = state.extra as String ?? "";
            return HomeScreen(userId: id);
          } 
        ),
        GoRoute(
          path: RouteNames.market,
          builder: (context, state) => const MarketScreen(),
        ),
        
    GoRoute(
  path: RouteNames.profile,
  builder: (context, state) {
    final userId = state.extra as String? ?? ''; // Safely get userId
    if (userId.isEmpty) {
      print("🚨 Error: User ID is empty or null!");
    } else {
      print("✅ User ID received: $userId");
    }
    return ProfileScreen(userId: userId);
  },
),



        GoRoute(
          path: RouteNames.land,
          builder: (context, state) => const LandScreen(),
        ),
       

      ],
    ),
 GoRoute(
          path: RouteNames.phoneNumberScreen,
          builder: (context, state) => const PhoneNumberScreen(),
        ),
        GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
        GoRoute(
          path: RouteNames.forgetPassword,
          builder: (context, state) =>  const ForgotPasswordScreen(),
        ),
           GoRoute(
          path: RouteNames.loadingScreen,
          builder: (context, state) =>  const LoadingAnimationScreen(),
        ),
GoRoute(
  path: RouteNames.resetPassword,
  builder: (context, state) {
    final userId = state.uri.queryParameters['userId'] ?? '';  // Extract userId from query params
    return ResetPasswordScreen(userId: userId);
  },
),




        GoRoute(
          path: RouteNames.signup,
          builder: (context, state) =>  const SignupScreen(),
          ),
          GoRoute(
  path: RouteNames.oTPVerification,
  builder: (context, state) {
    final email = state.uri.queryParameters['email'] ?? '';  // Get the email from query parameters
    return OTPVerificationScreen(email: email);  // Pass the email to OTPVerificationScreen
  },
),
          GoRoute(
            path: RouteNames.emailVerification,
            builder: (context, state) => const EmailVerificationScreen(),
          ),
          GoRoute(
            path: RouteNames.phoneVerification,
            builder: (context, state) => const PhoneVerificationScreen(),
          ),
    // ✅ Land Details Route (outside ShellRoute since it's a separate screen)
    GoRoute(
      path: '${RouteNames.landDetails}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return 
          LandDetailsScreen(id: id);
      },
    ),
    
    GoRoute(
      path: '${RouteNames.regionDetails}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return RegionDetailsScreen(id: id);
      },
    ),
    GoRoute(
      path: '${RouteNames.productDetails}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProductDetailsScreen(id: id);
      },
    ),
       GoRoute(
      path: RouteNames.camera,
      builder: (context, state) => const CameraScreen(),
      
    ),
     GoRoute(
      path: RouteNames.mapScreen,
      builder: (context, state) => const OSMFlutterMap(),
      
    ),
         GoRoute(
      path: RouteNames.chatScreen,
      builder: (context, state) => const ChatScreen(),
      
    ),

GoRoute(
  path: '${RouteNames.addplantScreen}/:regionId', 
  builder: (context, state) {
    final regionId = state.pathParameters['regionId']!;
    return AddPlantScreen(regionId: regionId);
  },
),
  ],
);
