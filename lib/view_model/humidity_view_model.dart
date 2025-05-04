import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pim_project/model/services/humidity_service.dart';

class HumidityViewModel with ChangeNotifier {
  final HumidityService _humidityService = HumidityService();
  Map<String, dynamic>? _humidityData;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get humidityData => _humidityData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchHumidityDataByCoordinates(double latitude, double longitude) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🌡️ [HumidityViewModel] Récupération des données d\'humidité pour les coordonnées: $latitude, $longitude');
      _humidityData = await _humidityService.getHumidityByCoordinates(latitude, longitude);
      print('✅ [HumidityViewModel] Données d\'humidité récupérées avec succès');
    } catch (e) {
      print('❌ [HumidityViewModel] Erreur: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 