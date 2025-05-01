import 'package:flutter/material.dart';

import 'package:pim_project/view/screens/home_screen/components/field_management_grid.dart';
import 'package:pim_project/view/screens/home_screen/components/weather_card.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/view/screens/Components/header.dart';

import 'package:pim_project/view_model/home_view_model.dart';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pim_project/constants/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  //  final l10n = AppLocalizations.of(context)!;
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

    // Get screen size
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.shortestSide >= 600;

    // Define responsive padding based on device size
    final EdgeInsets horizontalPadding = EdgeInsets.symmetric(
      horizontal: isTablet ? screenSize.width * 0.05 : 16.0,
    );

    // Fetch rented lands and connected regions when screen loads
    Future.delayed(Duration.zero, () {
      print('🔄 [HomeScreen] Début du chargement des données');
      Provider.of<HomeViewModel>(context, listen: false).fetchRentedLands(widget.userId);
      Provider.of<HomeViewModel>(context, listen: false).fetchConnectedRegions(widget.userId);
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header - Always full width
                  Header(
                    greetingText: l10n.hello,
                    username: _username,
                    userId: widget.userId,
                  ),
                
                  // Spacing - Responsive height
                  SizedBox(height: isTablet ? 24.0 : 16.0),
                  
                  // Weather Card - Responsive width with adaptive padding
                  Consumer<HomeViewModel>(
                    builder: (context, viewModel, child) {
                      if (_error != null) {
                        return Padding(
                          padding: horizontalPadding,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isTablet ? 500 : double.infinity,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    color: Colors.red[800],
                                    size: isTablet ? 64 : 48,
                                  ),
                                  SizedBox(height: isTablet ? 24 : 16),
                                  Text(
                                    _error!,
                                    style: TextStyle(
                                      color: Colors.red[800],
                                      fontSize: isTablet ? 18 : 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: isTablet ? 24 : 16),
                                  ElevatedButton.icon(
                                    onPressed: _getCurrentLocation,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isTablet ? 32 : 24,
                                        vertical: isTablet ? 16 : 12,
                                      ),
                                    ),
                                    icon: const Icon(Icons.refresh),
                                    label: Text(l10n.tryAgain),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      if (viewModel.isLoading) {
                        return Center(
                          child: Padding(
                            padding: horizontalPadding,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(color: Colors.green),
                                SizedBox(height: isTablet ? 24 : 16),
                                Text(
                                  'Chargement des données météo...',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: isTablet ? 18 : 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (viewModel.error.isNotEmpty) {
                        return Padding(
                          padding: horizontalPadding,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isTablet ? 500 : double.infinity,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red[800],
                                    size: isTablet ? 64 : 48,
                                  ),
                                  SizedBox(height: isTablet ? 24 : 16),
                                  Text(
                                    viewModel.error,
                                    style: TextStyle(
                                      color: Colors.red[800],
                                      fontSize: isTablet ? 18 : 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: isTablet ? 24 : 16),
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
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isTablet ? 32 : 24,
                                        vertical: isTablet ? 16 : 12,
                                      ),
                                    ),
                                    icon: const Icon(Icons.refresh),
                                    label: Text(l10n.tryAgain),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: horizontalPadding,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isTablet ? 600 : double.infinity,
                            ),
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
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: isTablet ? 30 : 20),

                  // Field Management Title - Adaptive font size
                  Padding(
                    padding: horizontalPadding,
                    child: Text(
                      l10n.fieldManagement,
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 24 : 16),

                  // Field Management Grid - Already responsive as mentioned
                  Padding(
                    padding: horizontalPadding,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isTablet ? 800 : double.infinity,
                        ),
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
                    ),
                  ),
                  // Add bottom padding for scrolling comfort
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}