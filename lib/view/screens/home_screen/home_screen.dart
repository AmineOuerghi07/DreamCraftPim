import 'package:flutter/material.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/view/screens/home_screen/components/field_management_grid.dart';
import 'package:pim_project/view/screens/home_screen/components/weather_card.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/view/screens/Components/header.dart';
import 'package:pim_project/view/screens/Components/search_bar.dart' as custom;
import 'package:pim_project/view_model/home_view_model.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pim_project/constants/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  String? _error;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      print('📍 [HomeScreen] Début de la récupération de la position');
      
      // Vérifier si le service de localisation est activé
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _error = 'Le service de localisation est désactivé');
        return;
      }

      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _error = 'Les permissions de localisation sont refusées');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() => _error = 'Les permissions de localisation sont définitivement refusées');
        return;
      }

      // Obtenir la position actuelle
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      print('📍 [HomeScreen] Position obtenue: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');
      
      // Charger les données météo avec les coordonnées
      if (_currentPosition != null) {
        final viewModel = Provider.of<HomeViewModel>(context, listen: false);
        await viewModel.fetchWeatherByCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }
    } catch (e) {
      print('❌ [HomeScreen] Erreur lors de la récupération de la position: $e');
      setState(() => _error = 'Erreur lors de la récupération de la position');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/account/get-account/${widget.userId}');
      final response = await http.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _username = data['fullname'] ?? 'Utilisateur';
          });
        }
      }
    } catch (e) {
      print('❌ [HomeScreen] Erreur lors de la récupération des données utilisateur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    print('🏠 [HomeScreen] Construction de l\'écran d\'accueil');
    print('👤 [HomeScreen] ID utilisateur: ${widget.userId}');

    final TextEditingController searchController = TextEditingController();
    final FocusNode searchFocusNode = FocusNode();

    // Fetch rented lands and connected regions when screen loads
    Future.delayed(Duration.zero, () {
      print('🔄 [HomeScreen] Début du chargement des données');
      Provider.of<HomeViewModel>(context, listen: false).fetchRentedLands(widget.userId);
      Provider.of<HomeViewModel>(context, listen: false).fetchConnectedRegions(widget.userId);
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Header(
                greetingText: l10n.hello,
                username: _username,
                userId: widget.userId,
              ),
            
              // Search Bar
              const SizedBox(height: 16),
              
              // Weather Card
              Consumer<HomeViewModel>(
                builder: (context, viewModel, child) {
                  if (_error != null) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.location_off,
                            color: Colors.red[800],
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: TextStyle(
                              color: Colors.red[800],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _getCurrentLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.refresh),
                            label: Text(l10n.tryAgain),
                          ),
                        ],
                      ),
                    );
                  }

                  if (viewModel.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.green),
                            SizedBox(height: 16),
                            Text(
                              'Chargement des données météo...',
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (viewModel.error.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[800],
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            viewModel.error,
                            style: TextStyle(
                              color: Colors.red[800],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_currentPosition != null) {
                                viewModel.fetchWeatherByCoordinates(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.refresh),
                            label: Text(l10n.tryAgain),
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: WeatherCard(
                      temperature: viewModel.weatherData?['temperature'] ?? 'N/A',
                      condition: viewModel.weatherData?['weather'] ?? 'N/A',
                      humidity: viewModel.weatherData?['humidity'] ?? 'N/A',
                      advice: viewModel.weatherData?['advice'] ?? l10n.noAdviceAvailable,
                      precipitation: viewModel.weatherData?['precipitation'] ?? '0%',
                      soilCondition: viewModel.weatherData?['soilCondition'] ?? 'N/A',
                      city: viewModel.weatherData?['city'] ?? l10n.unknownCity,
                      latitude: _currentPosition?.latitude ?? 0.0,
                      longitude: _currentPosition?.longitude ?? 0.0,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Field Management Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  l10n.fieldManagement,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Field Management Grid Component
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: FieldManagementGrid(
                  onFeatureSelected: (feature) {
                    print('🎯 [HomeScreen] Fonctionnalité sélectionnée: $feature');
                    switch (feature) {
                      case 'regions':
                        print('🌍 [HomeScreen] Navigation vers la page des régions');
                        break;
                      case 'lands':
                        print('🏞️ [HomeScreen] Navigation vers la page des terres');
                        break;
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
              // Help Card
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //   child: Container(
              //     padding: const EdgeInsets.all(16),
              //     decoration: BoxDecoration(
              //       color: Colors.green.withOpacity(0.1),
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     child: Row(
              //       children: [
              //         Expanded(
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               const Text(
              //                 "Need Our Help?",
              //                 style: TextStyle(
              //                   fontSize: 16,
              //                   fontWeight: FontWeight.bold,
              //                 ),
              //               ),
              //               const SizedBox(height: 8),
              //               const Text("Feel free to contact our support for any troubles"),
              //               const SizedBox(height: 8),
              //               ElevatedButton(
              //                 onPressed: () {
              //                   print("Call Now button tapped!");
              //                 },
              //                 style: ElevatedButton.styleFrom(
              //                   backgroundColor: Colors.green,
              //                   shape: RoundedRectangleBorder(
              //                     borderRadius: BorderRadius.circular(4),
              //                   ),
              //                 ),
              //                 child: const Text(
              //                   "Call Now",
              //                   style: TextStyle(
              //                     fontSize: 12,
              //                     color: Colors.white,
              //                   ),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //         const SizedBox(width: 16),

              //         Image.asset("assets/images/help.png", fit: BoxFit.cover),
              //       ],
              //     ),
              //   ),
              // ),
         