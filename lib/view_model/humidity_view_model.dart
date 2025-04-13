import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pim_project/model/services/humidity_service.dart';

class HumidityViewModel with ChangeNotifier {
  Map<String, dynamic>? _humidityData;
  bool _isLoading = false;
  String? _error;
  final HumidityService _humidityService = HumidityService();

  HumidityViewModel(); 

  // Getters for UI
  Map<String, dynamic>? get humidityData => _humidityData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Method to fetch humidity data
  Future<void> fetchHumidityData(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _humidityData = await _humidityService.getHumidityDetails(city);
      if (_humidityData == null) {
        _error = 'Aucune donnée d\'humidité disponible';
      }
    } catch (e) {
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