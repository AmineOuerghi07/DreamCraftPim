// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pim_project/ProviderClasses/SeeAllProductsProvider.dart';
import 'package:pim_project/model/services/UserPreferences.dart';
import 'package:pim_project/model/services/language_service.dart';
import 'package:pim_project/view/screens/components/app_progress_indicator.dart';
import 'package:pim_project/view_model/connected_region_view_model.dart';
import 'package:pim_project/view_model/humidity_view_model.dart';
import 'package:pim_project/view_model/irrigation_view_model.dart';
import 'package:pim_project/view_model/land_for_rent_view_model.dart';
import 'package:pim_project/view_model/land_view_model.dart';
import 'package:pim_project/view_model/sensor_data_view_model.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/model/repositories/user_repository.dart';
import 'package:pim_project/model/services/user_service.dart';
import 'package:pim_project/view_model/login_view_model.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:flutter/services.dart';
import 'package:pim_project/ProviderClasses/SmartRegionsProvider.dart';
import 'package:pim_project/ProviderClasses/bottom_navigation_bar_provider_class.dart';
import 'package:pim_project/ProviderClasses/cartProvider.dart';
import 'package:pim_project/ProviderClasses/factureProvider.dart';
import 'package:pim_project/ProviderClasses/market_provider.dart';
import 'package:pim_project/ProviderClasses/product_details_provider.dart';
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
import 'package:pim_project/model/services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurer l'orientation de l'application
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static String userId = "";

  const MyApp({super.key});

  Future<String> _getInitialRoute() async {
    final rememberMe = await UserPreferences.getRememberMe();
    final userId = await UserPreferences.getUserId();
    final token = await UserPreferences.getToken();


    if (rememberMe && userId != null && userId.isNotEmpty && token != null && token.isNotEmpty) {
      MyApp.userId = userId;
      return RouteNames.home;
    } else {
      // S'assurer que toutes les données de session sont effacées
      await UserPreferences.clear();
      return RouteNames.login;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LanguageService(),
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return FutureBuilder<String?>(
            future: _getInitialRoute(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return MaterialApp(
                  home: Scaffold(
                    body: Center(
                      child: AppProgressIndicator(
  loadingText: 'Growing data...',
  primaryColor: const Color(0xFF4CAF50), // Green
  secondaryColor: const Color(0xFF8BC34A), // Light Green
  size: 150, // Controls the overall size
),
                    ),
                  ),
                );
              }

              
              return MultiProvider(
                providers: [
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
                  ChangeNotifierProvider(
                    create: (context) => LoginViewModel(
                      userRepository: context.read<UserRepository>(),
                    ),
                  ),
                  ChangeNotifierProvider(create: (context) => ForgetPasswordViewModel()),
                  ChangeNotifierProvider(create: (context) => HomeViewModel()),
                  ChangeNotifierProvider(create: (context) => ConnectedRegionViewModel()),
                  ChangeNotifierProvider(create: (_) => LandForRentViewModel()),
                  ChangeNotifierProvider(create: (context) => LandViewModel()),
                  ChangeNotifierProvider(create: (context) => LandDetailsViewModel("")), 
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
                  ChangeNotifierProvider(create: (context) => HumidityViewModel()),
                  ChangeNotifierProvider(create: (context) => IrrigationViewModel()),
                  ChangeNotifierProvider(create: (context) => SensorDataViewModel()),
                  Provider(create: (context) => PredictionService()),
                  ChangeNotifierProvider<PredictionViewModel>(
                    create: (context) => PredictionViewModel(
                      predictionRepository: PredictionRepository(
                        predictionService: context.read<PredictionService>(),
                      ),
                    ),
                  ),
                  ChangeNotifierProvider(create: (context) => BottomNavigationProvider()),
                  ChangeNotifierProvider(create: (_) => SmartRegionsProvider()),
                  ChangeNotifierProvider(create: (_) => MarketProvider()),
                  ChangeNotifierProvider(create: (_) => ProductDetailsProvider(productId: 'your_product_id')),
                  ChangeNotifierProvider(create: (_) => CartProvider()),
                  ChangeNotifierProvider(create: (_) => FactureProvider()),
                  ChangeNotifierProvider(create: (_) => SeeAllProductsProvider()),
                ],
                child: MaterialApp.router(
                  title: 'DreamCraft PIM',
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                    colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor),
                    useMaterial3: true,
                  ),
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('en'),
                    Locale('fr'),
                    Locale('ar'),
                  ],
                  locale: languageService.locale,
                  routerConfig: router,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
