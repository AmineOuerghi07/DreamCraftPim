// ProviderClasses/SmartRegionsProvider.dart
import 'package:flutter/material.dart';
import 'package:pim_project/view_model/irrigation_view_model.dart';

class SmartRegionsProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _cardsData = [
    {
      "icon": Icons.lightbulb,
      "iconColor": Colors.yellow,
      "title": "Lighting",
      "subtitle": "12 watt",
    },
    {
      "icon": Icons.thermostat,
      "iconColor": Colors.red,
      "title": "Temperature",
      "subtitle": "40°C",
    },
    {
      "icon": Icons.water_drop,
      "iconColor": Colors.blue,
      "title": "Irrigation",
      "subtitle": "100m",
    },
    {
      "icon": Icons.landscape_rounded,
      "iconColor": const Color.fromARGB(255, 172, 109, 15),
      "title": "Soil",
      "subtitle": "Growth",
    },
  ];

  List<Map<String, dynamic>> get cardsData => _cardsData;

  // Default switches (all on)
  final List<bool> _switches = List.generate(4, (index) => true);
  
  List<bool> get switches => _switches;

  // Track automatic vs manual mode
  bool _isAutomaticMode = true;
  bool get isAutomaticMode => _isAutomaticMode;

  // Irrigation view model for system control
  late IrrigationViewModel _irrigationViewModel;

  // Set irrigation view model
  void setIrrigationViewModel(IrrigationViewModel viewModel) {
    _irrigationViewModel = viewModel;
    
    // Update mode
    _isAutomaticMode = _irrigationViewModel.isAutomaticMode;
    
    // Update switches based on current state
    updateSwitchesFromViewModel();
    
    notifyListeners();
  }

  // Update smart card switches based on irrigation view model state
  void updateSwitchesFromViewModel() {
    // Update irrigation pump switch (index 2)
    _switches[2] = _irrigationViewModel.isPumpOn;
    
    // Update temperature sensor switch (index 1)
    _switches[1] = _irrigationViewModel.isTemperatureSensorOn;
    
    notifyListeners();
  }

  // Toggle a switch and update corresponding functionality
  void toggleSwitch(int index, bool value) async {
    // If in automatic mode and trying to toggle irrigation controls, return
    if (_isAutomaticMode && (index == 1 || index == 2)) {
      return;
    }
    
    _switches[index] = value;
    notifyListeners();

    // Update system state based on which switch was toggled
    switch (index) {
      case 1: // Temperature sensor
        if (_irrigationViewModel != null) {
          await _irrigationViewModel.setTemperatureSensor(value);
        }
        break;
      case 2: // Irrigation pump
        if (_irrigationViewModel != null) {
          await _irrigationViewModel.setPumpState(value);
        }
        break;
    }
  }

  // Toggle between automatic and manual mode
  void setOperationMode(bool automatic) async {
    _isAutomaticMode = automatic;
    
    if (_irrigationViewModel != null) {
      await _irrigationViewModel.setOperationMode(automatic);
      
      // Update switches after mode change
      updateSwitchesFromViewModel();
    }
    
    notifyListeners();
  }
}
