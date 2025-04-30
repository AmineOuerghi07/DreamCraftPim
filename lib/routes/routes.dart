import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pim_project/model/services/UserPreferences.dart';
import 'package:pim_project/view/screens/OTPVerificationScreen.dart';
import 'package:pim_project/view/screens/PhoneNumberScreen.dart';
import 'package:pim_project/view/screens/about_screen.dart';
import 'package:pim_project/view/screens/add_plant_screen.dart';
import 'package:pim_project/view/screens/camera_screen.dart';
import 'package:pim_project/view/screens/chat_screen.dart';
import 'package:pim_project/view/screens/contact_screen.dart';
import 'package:pim_project/view/screens/editprofile_screen.dart';
import 'package:pim_project/view/screens/email_verification_screen.dart';
import 'package:pim_project/view/screens/forget_password_screen.dart';
import 'package:pim_project/view/screens/home_screen/home_screen.dart';
import 'package:pim_project/view/screens/humidity_screen.dart';
import 'package:pim_project/view/screens/land_details_screen.dart';
import 'package:pim_project/view/screens/land_screen.dart';
import 'package:pim_project/view/screens/language_screen.dart';
import 'package:pim_project/view/screens/loading_screen.dart';
import 'package:pim_project/view/screens/login_screen.dart';
import 'package:pim_project/view/screens/main_screen.dart';
import 'package:pim_project/view/screens/map_screen.dart';
import 'package:pim_project/view/screens/market_screen.dart';
import 'package:pim_project/view/screens/on_boarding_screen.dart';
import 'package:pim_project/view/screens/phone_verification_screen.dart';
import 'package:pim_project/view/screens/product_details_screen.dart';
import 'package:pim_project/view/screens/region_details_screen.dart';
import 'package:pim_project/view/screens/profile_screen.dart';
import 'package:pim_project/view/screens/reset_password_screen.dart';
import 'package:pim_project/view/screens/signup_screen.dart';
import 'package:pim_project/main.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

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
  static const String camera = '/camera';
  static const String productDetails = '/product-details';
  static const String loadingScreen = '/loading_screen';
  static const String processingScreen = '/processing';
  static const String chatScreen = '/chat_screen';
  static const String addplantScreen = '/add_plant_screen';
  static const String mapScreen = '/map_screen';
  static const String humidity = '/humidity_screen';
  static const String about = '/about_screen';
  static const String contact = '/contact_screen';
  static const String editProfile = '/editprofile';
  static const String languageScreen = '/language_screen';
  static const String settings = '/loading_screen';
  static const String onboarding = '/onboarding';
}

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RouteNames.loadingScreen,
  routes: [
    GoRoute(
      path: RouteNames.loadingScreen,
      builder: (context, state) => LoadingScreen(
        onLoaded: () async {
          // Check if this is a fresh install
          final isFirstInstall = await UserPreferences.getIsFirstInstall();

          if (isFirstInstall == null) {
            // Fresh install: show onboarding and mark as opened
            await UserPreferences.setIsFirstInstall(true);
            return RouteNames.onboarding;
          }

          // Not a fresh install: check user login status
          final rememberMe = await UserPreferences.getRememberMe();
          final userId = await UserPreferences.getUserId();
          final token = await UserPreferences.getToken();

          if (rememberMe && userId != null && token != null) {
            MyApp.userId = userId;
            return RouteNames.home;
          }

          return RouteNames.login;
        },
      ),
    ),
    GoRoute(
      path: RouteNames.onboarding,
      builder: (context, state) => const AnimatedOnboardingScreen(),
    ),
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [
        GoRoute(
          path: RouteNames.home,
          builder: (context, state) {
            final userId = state.extra as String? ?? MyApp.userId;
            return HomeScreen(userId: userId);
          },
        ),
        GoRoute(
          path: RouteNames.market,
          builder: (context, state) {
            final userId = state.extra as String? ?? MyApp.userId;
            return MarketScreen(userId: userId);
          },
        ),
        GoRoute(
          path: RouteNames.profile,
          builder: (context, state) {
            final userId = state.extra as String? ?? MyApp.userId;
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
          builder: (context, state) {
            final userId = state.extra as String? ?? MyApp.userId;
            return LandScreen(userId: userId);
          },
        ),
        GoRoute(
          path: RouteNames.languageScreen,
          builder: (context, state) => const LanguageScreen(),
        ),
        GoRoute(
          path: RouteNames.about,
          builder: (context, state) => const AboutScreen(),
        ),
        GoRoute(
          path: RouteNames.contact,
          builder: (context, state) => const ContactScreen(),
        ),
        GoRoute(
          path: RouteNames.editProfile,
          builder: (context, state) => EditProfileScreen(userData: state.extra as Map<String, dynamic>),
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
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: RouteNames.resetPassword,
      builder: (context, state) {
        final userId = state.uri.queryParameters['userId'] ?? '';
        return ResetPasswordScreen(userId: userId);
      },
    ),
    GoRoute(
      path: RouteNames.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: RouteNames.oTPVerification,
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return OTPVerificationScreen(email: email);
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
      builder: (context, state) => ChatScreen(initialData: state.extra as Map<String, dynamic>?),
    ),
    GoRoute(
      path: RouteNames.processingScreen,
      builder: (context, state) => const LoadingAnimationScreen(),
    ),
    GoRoute(
      path: '${RouteNames.addplantScreen}/:regionId',
      builder: (context, state) {
        final regionId = state.pathParameters['regionId']!;
        return AddPlantScreen(regionId: regionId);
      },
    ),

    GoRoute(
      path: '${RouteNames.humidity}/:humidity',
      builder: (context, state) {
        final humidity = state.pathParameters['humidity']!;
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return HumidityScreen(
          humidity: humidity,
          latitude: extra['latitude'] ?? 0.0,
          longitude: extra['longitude'] ?? 0.0,
        );
      },
    ),
    GoRoute(
      path: RouteNames.settings,
      builder: (context, state) => LoadingScreen(onLoaded: () async {
        return RouteNames.home;
      }),
    ),
  ],
  redirect: (context, state) {
    if (state.uri.toString() == RouteNames.loadingScreen) {
      return null; // Let LoadingScreen handle the redirect
    }
    return null;
  },
);

class LoadingScreen extends StatefulWidget {
  final Future<String> Function() onLoaded;

  const LoadingScreen({required this.onLoaded, super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndRedirect();
  }

  Future<void> _checkAndRedirect() async {
    try {
      final route = await widget.onLoaded();
      if (mounted) {
        // Vérifier si l'ID utilisateur est toujours présent
        final userId = await UserPreferences.getUserId();
        if (userId != null && userId.isNotEmpty) {
          MyApp.userId = userId;
          print('✅ [LoadingScreen] ID utilisateur restauré: $userId');
        } else {
          print('⚠️ [LoadingScreen] Aucun ID utilisateur trouvé');
        }
        GoRouter.of(context).go(route);
      }
    } catch (e) {
      print('❌ [LoadingScreen] Erreur lors de la redirection: $e');
      if (mounted) {
        GoRouter.of(context).go(RouteNames.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}