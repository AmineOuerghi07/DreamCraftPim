import 'package:flutter/material.dart';
import 'package:pim_project/model/services/UserPreferences%20.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/model/repositories/user_repository.dart';
import 'package:pim_project/model/services/user_service.dart';
import 'package:pim_project/view_model/login_view_model.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:pim_project/ProviderClasses/SmartRegionsProvider.dart';
import 'package:pim_project/ProviderClasses/bottom_navigation_bar_provider_class.dart';
import 'package:pim_project/ProviderClasses/camera_provider.dart';
import 'package:pim_project/ProviderClasses/market_provider.dart';
import 'package:pim_project/ProviderClasses/quantity_provider.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/repositories/prediction_repository.dart';
import 'package:pim_project/model/services/predection_service.dart';
import 'package:pim_project/view_model/chat_view_model.dart';
import 'package:pim_project/view_model/forget_password_view_model.dart';
import 'package:pim_project/view_model/home_view_model.dart';
import 'package:pim_project/view_model/land_details_view_model.dart';
import 'package:pim_project/view_model/market_view_model.dart';
import 'package:pim_project/view_model/prediction_view_model.dart';
import 'package:pim_project/view_model/product_details_view_model.dart';
import 'package:pim_project/view_model/profile_view_model.dart';
import 'package:pim_project/view_model/region_details_view_model.dart';
import 'package:pim_project/view_model/reset_password_view_model.dart';
import 'package:pim_project/view_model/signup_view_model.dart';
import 'package:pim_project/view_model/welcome_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) async {

    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  static String userId = "";

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: UserPreferences.getUserId(), // Retrieve userId from SharedPreferences
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the userId
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          // Set the userId once it's retrieved
          MyApp.userId = snapshot.data ?? "";

          return MultiProvider(
            providers: [
              // Add UserService and UserRepository providers
              Provider(create: (context) => UserService(apiClient: context)),
              Provider(
                create: (context) => UserRepository(
                  userService: context.read<UserService>(), // Pass UserService to UserRepository
                ),
              ),

              // View Models
              ChangeNotifierProvider(
                create: (context) => LoginViewModel(
                  userRepository: context.read<UserRepository>(), // Pass UserRepository to LoginViewModel
                ),
              ),
              ChangeNotifierProvider(create: (context) => ForgetPasswordViewModel()),
              ChangeNotifierProvider(create: (context) => HomeViewModel()),
              ChangeNotifierProvider(create: (context) => LandDetailsViewModel()),
              ChangeNotifierProvider(create: (context) => MarketViewModel()),
              ChangeNotifierProvider(create: (context) => ProductDetailsViewModel()),
              ChangeNotifierProvider(create: (context) => ProfileViewModel()),
              ChangeNotifierProvider(create: (context) => RegionDetailsViewModel()),
              ChangeNotifierProvider(create: (context) => ResetPasswordViewModel()),
              ChangeNotifierProvider(create: (context) => WelcomeViewModel()),
              ChangeNotifierProvider(create: (context) => ChatViewModel(AppConstants.chatBaseUrl)),
              ChangeNotifierProvider(
                create: (context) => SignupViewModel(
                  userRepository: context.read<UserRepository>(),
                ),
              ),

              // Dependency Injection Fix: Inject `PredictionService` into `PredictionRepository`
              Provider(create: (context) => PredictionService()),
              ChangeNotifierProvider<PredictionViewModel>(
                create: (context) => PredictionViewModel(
                  predictionRepository: PredictionRepository(
                    predictionService: context.read<PredictionService>(),
                  ),
                ),
              ),

              // Other Providers
              ChangeNotifierProvider(create: (context) => BottomNavigationProvider()),
              ChangeNotifierProvider(create: (_) => SmartRegionsProvider()),
              ChangeNotifierProvider(create: (_) => QuantityProvider()),
              ChangeNotifierProvider(create: (_) => MarketProvider()),
            ],
            child: MaterialApp.router(
              title: "PIM",
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              ),
              routerConfig: router,
            ),
          );
        }
      },
    );
  }
}