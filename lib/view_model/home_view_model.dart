// view_model/home_view_model.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/model/services/weather_service.dart';

class HomeViewModel with ChangeNotifier {
  List _rentedLands = [];
  List _connectedRegions = [];
  Map? _weatherData;
  bool _isLoading = false;
  String _error = '';
  
  // Added status variables to track different states
  bool _noRegionsFound = false;
  bool _noLandsFound = false;

  final WeatherApiService _weatherService = WeatherApiService();
  final ApiClient _apiClient = ApiClient(baseUrl: AppConstants.baseUrl);

  List get rentedLands => _rentedLands;
  List get connectedRegions => _connectedRegions;
  Map? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String get error => _error;
  
  // Getters for the new status variables
  bool get noRegionsFound => _noRegionsFound;
  bool get noLandsFound => _noLandsFound;

  Future fetchRentedLands(String userId) async {
    print('📤 [HomeViewModel] Récupération des terres louées pour userId: $userId');
    
    // Reset state before fetching
    _noLandsFound = false;
    
    try {
      final String url = '${AppConstants.baseUrl}/lands/users/$userId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🔄 [HomeViewModel] Response Status Code: ${response.statusCode}');
      print('🔄 [HomeViewModel] Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          _rentedLands = data.map((json) => Land.fromJson(json)).toList();
          
          // Check if the list is empty
          if (_rentedLands.isEmpty) {
            _noLandsFound = true;
          }
          
          notifyListeners();
        } else {
          throw Exception("Format de réponse inattendu");
        }
      } else if (response.statusCode == 404) {
        // Handle 404 - No lands found for user
        print('📝 [HomeViewModel] No lands found for user');
        _rentedLands = [];
        _noLandsFound = true;
        notifyListeners();
      } else {
        throw Exception("Échec du chargement des terres: ${response.statusCode}");
      }
    } catch (e) {
      print('❌ [HomeViewModel] Erreur lors de la récupération des terres: $e');
      _error = 'Erreur lors de la récupération des terres';
      notifyListeners();
    }
  }

  Future fetchConnectedRegions(String userId) async {
    // Reset state before fetching
    _noRegionsFound = false;
    
    try {
      final String url = '${AppConstants.baseUrl}/lands/region/users/$userId';
      final response = await http.get(Uri.parse(url));
      
      print('🔄 [HomeViewModel] Regions Response Status Code: ${response.statusCode}');
      print('🔄 [HomeViewModel] Regions Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        List data = jsonDecode(response.body);
        _connectedRegions = data.map((json) => Region.fromJson(json)).toList();
        
        // Check if the list is empty
        if (_connectedRegions.isEmpty) {
          _noRegionsFound = true;
        }
        
        notifyListeners();
      } else if (response.statusCode == 404) {
        // Handle 404 specifically - No regions connected to user
        print('📝 [HomeViewModel] No regions connected to user');
        _connectedRegions = [];
        _noRegionsFound = true;
        notifyListeners();
      } else {
        throw Exception('Échec du chargement des régions');
      }
    } catch (e) {
      print('❌ [HomeViewModel] Erreur lors de la récupération des régions: $e');
      _error = 'Erreur lors de la récupération des régions';
      notifyListeners();
    }
  }

  Future fetchWeatherByCoordinates(double latitude, double longitude) async {
    print('🌤️ [HomeViewModel] Récupération de la météo pour: $latitude, $longitude');
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      final data = await _weatherService.getWeatherByCoordinates(latitude, longitude);
      if (data != null) {
        _weatherData = data;
        print('✅ [HomeViewModel] Données météo mises à jour');
      } else {
        _error = 'Aucune donnée météo disponible';
      }
    } catch (e) {
      _error = e.toString();
      print('❌ [HomeViewModel] Erreur: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}