import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/view/screens/land_details_screen.dart';
import 'package:pim_project/view_model/forget_password_view_model.dart';
import 'package:pim_project/view_model/home_view_model.dart';
import 'package:pim_project/view_model/land_details_view_model.dart';
import 'package:pim_project/view_model/login_view_model.dart';
import 'package:pim_project/view_model/market_view_model.dart';
import 'package:pim_project/view_model/product_details_view_model.dart';
import 'package:pim_project/view_model/profile_view_model.dart';
import 'package:pim_project/view_model/region_details_view_model.dart';
import 'package:pim_project/view_model/reset_password_view_model.dart';
import 'package:pim_project/view_model/signup_view_model.dart';
import 'package:pim_project/view_model/verification_view_model.dart';
import 'package:pim_project/view_model/welcome_view_model.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/view/screens/login_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LandDetailsScreen())
      ]);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<LoginViewModel>(
              create: (context) => LoginViewModel()),
          ChangeNotifierProvider<ForgetPasswordViewModel>(
              create: (context) => ForgetPasswordViewModel()),
          ChangeNotifierProvider<HomeViewModel>(
              create: (context) => HomeViewModel()),
          ChangeNotifierProvider<LandDetailsViewModel>(
              create: (context) => LandDetailsViewModel()),
          ChangeNotifierProvider<MarketViewModel>(
              create: (context) => MarketViewModel()),
          ChangeNotifierProvider<ProductDetailsViewModel>(
              create: (context) => ProductDetailsViewModel()),
          ChangeNotifierProvider<ProfileViewModel>(
              create: (context) => ProfileViewModel()),
          ChangeNotifierProvider<RegionDetailsViewModel>(
              create: (context) => RegionDetailsViewModel()),
          ChangeNotifierProvider<ResetPasswordViewModel>(
              create: (context) => ResetPasswordViewModel()),
          ChangeNotifierProvider<SignupViewModel>(
              create: (context) => SignupViewModel()),
          ChangeNotifierProvider<VerificationViewModel>(
              create: (context) => VerificationViewModel()),
          ChangeNotifierProvider<WelcomeViewModel>(
              create: (context) => WelcomeViewModel()),
        ],
        child: Builder(builder: (context) {
          return MaterialApp.router(
            title: "PIM",
            theme: ThemeData(
                colorScheme:
                    ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
            routerConfig: _router,
          );
        }));
  }
}
