// view_model/sensor_data_view_model.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pim_project/constants/constants.dart';

class SensorData {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  SensorData({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });
}

class SensorDataViewModel extends ChangeNotifier {
  // Map of sensor data by sensor type (key is sensor title)
  final Map<String, SensorData> _sensorDataMap = {};
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _lastUpdateMessage;
  Timer? _refreshTimer;
  
  // Base API URL - replace with your actual API base URL
  final String _baseApiUrl = AppConstants.baseUrl;

  // Initial data
  SensorDataViewModel() {
    _initializeDefaultData();
    // Start automatic refresh immediately
    startAutoRefresh();
  }

  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
  String? get lastUpdateMessage => _lastUpdateMessage;

  // Get formatted last updated time
  String get lastUpdatedFormatted {
    if (_lastUpdated == null) return "Never updated";
    
    final now = DateTime.now();
    final difference = now.difference(_lastUpdated!);
    
    if (difference.inSeconds < 60) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return "$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago";
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return "$hours ${hours == 1 ? 'hour' : 'hours'} ago";
    } else {
      final days = difference.inDays;
      return "$days ${days == 1 ? 'day' : 'days'} ago";
    }
  }

  // Get list of all sensor data
  List<SensorData> get allSensorData => _sensorDataMap.values.toList();

  // Get a specific sensor by title
  SensorData? getSensorByTitle(String title) {
    return _sensorDataMap[title];
  }

  // Initialize with default data (will be replaced with API data soon)
  void _initializeDefaultData() {
    _sensorDataMap.clear();
    
    _sensorDataMap["Lighting"] = SensorData(
      title: "Lighting",
      value: "-- watt",
      icon: Icons.lightbulb,
      iconColor: Colors.yellow,
    );
    
    _sensorDataMap["Temperature"] = SensorData(
      title: "Temperature",
      value: "--°C",
      icon: Icons.thermostat,
      iconColor: Colors.red,
    );
    
    _sensorDataMap["Irrigation"] = SensorData(
      title: "Irrigation",
      value: "--m",
      icon: Icons.water_drop,
      iconColor: Colors.blue,
    );
    
    _sensorDataMap["Ventilator"] = SensorData(
      title: "Ventilator",
      value: "Off",
      icon: Icons.air,
      iconColor: Colors.lightBlue,
    );
    
    // Add Humidity sensor
    _sensorDataMap["Humidity"] = SensorData(
      title: "Humidity",
      value: "--%",
      icon: Icons.water_outlined,
      iconColor: Colors.blueAccent,
    );
    
    // Add Soil sensor
    _sensorDataMap["Soil"] = SensorData(
      title: "Soil",
      value: "--",
      icon: Icons.grass,
      iconColor: Colors.green,
    );
  }

  // Update a single sensor's value
  void updateSensorValue(String sensorTitle, String newValue) {
    if (_sensorDataMap.containsKey(sensorTitle)) {
      final currentData = _sensorDataMap[sensorTitle]!;
      _sensorDataMap[sensorTitle] = SensorData(
        title: currentData.title,
        value: newValue,
        icon: currentData.icon,
        iconColor: currentData.iconColor,
      );
      notifyListeners();
    }
  }

  // Start timer for automatic refresh every 20 seconds
  void startAutoRefresh() {
    // Cancel any existing timer
    stopAutoRefresh();
    
    // Create a new timer that fires every 20 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      refreshSensorData();
    });
    
    // Initial fetch immediately
    refreshSensorData();
  }
  
  // Stop automatic refresh
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // Refresh all sensor data from API
  Future<void> refreshSensorData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Make API call to get all sensor data
      final response = await http.get(
        Uri.parse('$_baseApiUrl/irrigation/sensors/all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Update Temperature
        if (data['dht'] != null && data['dht']['temperature'] != null) {
          updateSensorValue("Temperature", "${data['dht']['temperature']}°C");
        }
        
        // Update Humidity
        if (data['dht'] != null && data['dht']['humidity'] != null) {
          updateSensorValue("Humidity", "${data['dht']['humidity']}%");
        }
        
        // Update Soil status
        if (data['soil'] != null) {
          final soilStatus = data['soil']['is_dry'] ? "Dry" : "Moist";
          updateSensorValue("Soil", soilStatus);
        }
        
        // Update Irrigation/Pump status
        if (data['pump'] != null) {
          final pumpStatus = data['pump']['active'] ? "Active" : "Inactive";
          final pumpMode = data['pump']['mode'];
          updateSensorValue("Irrigation", "$pumpStatus ($pumpMode)");
        }
        
        // Update Ventilator status
        if (data['ventilator'] != null) {
          final ventStatus = data['ventilator']['active'] ? "Active" : "Inactive";
          final autoMode = data['ventilator']['auto_mode'] ? "Auto" : "Manual";
          updateSensorValue("Ventilator", "$ventStatus ($autoMode)");
        }
        
        // Update Lighting status
        if (data['light'] != null) {
          final lightDetected = data['light']['detected'] ? "Detected" : "Not detected";
          final ledActive = data['light']['led_active'] ? "On" : "Off";
          updateSensorValue("Lighting", "$lightDetected (LED: $ledActive)");
        }
        
        _lastUpdated = DateTime.now();
        _lastUpdateMessage = "Sensor data updated successfully";
      } else {
        _lastUpdateMessage = "Error: Server returned status ${response.statusCode}";
        print("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      _lastUpdateMessage = "Error refreshing sensor data: $e";
      print("Error refreshing sensor data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}