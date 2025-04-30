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
  List<Land> _rentedLands = [];
  List<Region> _connectedRegions = [];
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  String _error = '';

  final WeatherApiService _weatherService = WeatherApiService();
  final ApiClient _apiClient = ApiClient(baseUrl: AppConstants.baseUrl);

  List<Land> get rentedLands => _rentedLands;
  List<Region> get connectedRegions => _connectedRegions;
  Map<String, dynamic>? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchRentedLands(String userId) async {
    print('📤 [HomeViewModel] Récupération des terres louées pour userId: $userId');

    try {
      final String url = '${AppConstants.baseUrl}/lands/users/$userId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          _rentedLands = data.map((json) => Land.fromJson(json)).toList();
          notifyListeners();
        } else {
          throw Exception("Format de réponse inattendu");
        }
      } else {
        throw Exception("Échec du chargement des terres: ${response.statusCode}");
      }
    } catch (e) {
      print('❌ [HomeViewModel] Erreur lors de la récupération des terres: $e');
      _error = 'Erreur lors de la récupération des terres';
      notifyListeners();
    }
  }

  Future<void> fetchConnectedRegions(String userId) async {
    try {
      final String url = '${AppConstants.baseUrl}/lands/region/users/$userId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> data = jsonDecode(response.body);
        _connectedRegions = data.map((json) => Region.fromJson(json)).toList();
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

  Future<void> fetchWeatherByCoordinates(double latitude, double longitude) async {
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