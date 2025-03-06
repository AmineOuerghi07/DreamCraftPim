import 'package:flutter/material.dart';
import 'package:pim_project/ProviderClasses/SeeAllProductsProvider.dart';
import 'package:pim_project/ProviderClasses/SmartRegionsProvider.dart';
import 'package:pim_project/ProviderClasses/bottom_navigation_bar_provider_class.dart';
import 'package:pim_project/ProviderClasses/cartProvider.dart';
import 'package:pim_project/ProviderClasses/factureProvider.dart';
import 'package:pim_project/ProviderClasses/market_provider.dart';
import 'package:pim_project/ProviderClasses/product_details_provider.dart';


import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/view/screens/Components/factureDialog.dart';
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

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          ChangeNotifierProvider<BottomNavigationProvider>(
              create: (context) => BottomNavigationProvider()),
          ChangeNotifierProvider(create: (_) => SmartRegionsProvider()),
          ChangeNotifierProvider(create: (_) => ProductDetailsProvider(productId: 'your_product_id')),
          ChangeNotifierProvider(create: (_) => MarketProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => FactureProvider()),
          ChangeNotifierProvider(create: (_) => SeeAllProductsProvider()),

        ],
        child: Builder(builder: (context) {
          return MaterialApp.router(
            title: "PIM",
            theme: ThemeData(
                colorScheme:
                    ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
            routerConfig: router,
          );
        }));
  }
}
