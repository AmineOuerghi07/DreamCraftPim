// main.dart
import 'package:flutter/material.dart';
import 'package:pim_project/model/services/UserPreferences.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/model/repositories/user_repository.dart';
import 'package:pim_project/model/services/user_service.dart';
import 'package:pim_project/view_model/login_view_model.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:pim_project/ProviderClasses/SmartRegionsProvider.dart';
import 'package:pim_project/ProviderClasses/bottom_navigation_bar_provider_class.dart';
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
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pim_project/model/services/api_client.dart';

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    return;
  } catch (e) {
    Fluttertoast.showToast(
      msg: "Some features might be limited. Firebase services are not available.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
    // Return without throwing to allow app to continue
    return;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
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
      future: UserPreferences.getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          MyApp.userId = snapshot.data ?? "";

          return MultiProvider(
            providers: [
              // Core Services
              Provider(
                create: (context) => ApiClient(baseUrl: AppConstants.baseUrl),
              ),
              Provider(
                create: (context) => UserService(
                  apiClient: context.read<ApiClient>(),
                ),
              ),
              ChangeNotifierProvider(
                create: (context) => UserRepository(
                  userService: context.read<UserService>(),
                ),
              ),

              // View Models
              ChangeNotifierProvider(
                create: (context) => LoginViewModel(
                  userRepository: context.read<UserRepository>(),
                )..checkLoginStatus(),
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