// view_model/home_view_model.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/services/weather_service.dart';
import 'package:pim_project/model/services/api_client.dart';


class HomeViewModel with ChangeNotifier {
  List<Land> _rentedLands = [];
   List<Region> _connectedRegions = [];
Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  String _error = '';


  List<Land> get rentedLands => _rentedLands;
  List<Region> get connectedRegions => _connectedRegions;
  final apiClient = ApiClient(baseUrl: AppConstants.baseUrl);

  Map<String, dynamic>? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String get error => _error;


  final weatherService = WeatherApiService();

  Future<void> fetchRentedLands(String userId) async {
  print('📤 Sending request with userId: $userId');

  final String url = '${AppConstants.baseUrl}/lands/users/$userId';
  final response = await http.get(Uri.parse(url));

  print('📜 Response Status: ${response.statusCode}');
  print('📜 Response Body: ${response.body}');

  if (response.statusCode == 200 || response.statusCode == 201) {
     final dynamic data = jsonDecode(response.body);

      // Check if the response is a list
      if (data is List) {
        _rentedLands = data.map((json) => Land.fromJson(json)).toList();
      } else {
        throw Exception("Unexpected response format: ${response.body}");
      }

      notifyListeners();
    } else {
      throw Exception("Failed to load lands: ${response.statusCode}");
    }
  
  }
////////////////////////////
Future<void> fetchConnectedRegions(String userId) async {
  print('📤 Sending request with userId: $userId');

  final String url = '${AppConstants.baseUrl}/lands/region/users/$userId';
  final response = await http.get(Uri.parse(url));

  print('📜 Response Status: ${response.statusCode}');
  print('📜 Response Body: ${response.body}');

  if (response.statusCode == 200 || response.statusCode == 201) {
    List<dynamic> data = jsonDecode(response.body);
    _connectedRegions = data.map((json) => Region.fromJson(json)).toList();
    notifyListeners();
  } else {
    print('🔴 Error: Status Code ${response.statusCode}');
    throw Exception('Failed to load regions');
  }
}

Future<void> fetchWeather(String city) async {
    print('🌤️ [HomeViewModel] Début de la récupération de la météo pour la ville: $city');
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final weatherData = await weatherService.getWeather(city);
      
      if (weatherData != null) {
        _weatherData = weatherData;
        print('✅ [HomeViewModel] Données météo mises à jour: $_weatherData');
      } else {
        _error = 'No weather data available';
        print('⚠️ [HomeViewModel] Aucune donnée météo disponible');
      }
    } catch (e) {
      _error = e.toString();
      print('❌ [HomeViewModel] Erreur lors de la récupération de la météo: $e');
      print('🔍 [HomeViewModel] Stack trace: ${StackTrace.current}');
      
      // Gestion spécifique des erreurs
      if (e.toString().contains('Server error')) {
        _error = 'Server is temporarily unavailable. Please try again later.';
      } else if (e.toString().contains('Invalid JSON')) {
        _error = 'Invalid data received from server. Please try again.';
      } else if (e.toString().contains('Connection refused')) {
        _error = 'Cannot connect to server. Please check your internet connection.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🏁 [HomeViewModel] Fin de la récupération de la météo');
    }
  }
/*
  Future<void> fetchWeatherByCoordinates(double latitude, double longitude) async {
    print('🌤️ [HomeViewModel] Début de la récupération de la météo pour les coordonnées: $latitude, $longitude');
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final weatherData = await weatherService.getWeatherByCoordinates(latitude, longitude);
      
      if (weatherData != null) {
        _weatherData = weatherData;
        print('✅ [HomeViewModel] Données météo mises à jour: $_weatherData');
      } else {
        _error = 'Aucune donnée météo disponible';
        print('⚠️ [HomeViewModel] Aucune donnée météo disponible');
      }
    } catch (e) {
      _error = 'Erreur lors de la récupération des données météo: $e';
      print('❌ [HomeViewModel] Erreur lors de la récupération des données météo: $e');
      print('🔍 [HomeViewModel] Stack trace: ${StackTrace.current}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  */
}
