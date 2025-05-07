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
      "icon": Icons.air,
      "iconColor": Colors.lightBlue,
      "title": "Ventilator",
      "subtitle": "Fresh Air",
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
    
    // Update ventilator switch (index 3)
    _switches[3] = _irrigationViewModel.isVentilatorOn;
    
    // Update lighting switch (index 0) based on LED state
    _switches[0] = _irrigationViewModel.isLedOn;
    
    notifyListeners();
  }

  // Toggle a switch and update corresponding functionality
  void toggleSwitch(int index, bool value) async {
    // If in automatic mode and trying to toggle automated controls, return
    if (_isAutomaticMode && (index == 1 || index == 2 || index == 3)) {
      return;
    }
    
    _switches[index] = value;
    notifyListeners();

    // Update system state based on which switch was toggled
    switch (index) {
      case 0: // Lighting (LED)
        await _irrigationViewModel.setLedState(value);
              break;
      case 1: // Temperature sensor
        await _irrigationViewModel.setTemperatureSensor(value);
              break;
      case 2: // Irrigation pump
        await _irrigationViewModel.setPumpState(value);
              break;
      case 3: // Ventilator
        await _irrigationViewModel.setVentilatorState(value);
              break;
    }
  }

  // Toggle between automatic and manual mode
  void setOperationMode(bool automatic) async {
    _isAutomaticMode = automatic;
    
    // First update the UI state immediately
    notifyListeners();
    
    // Then send the change to the backend
    await _irrigationViewModel.setOperationMode(automatic);
    
    // Force refresh the system status to ensure all states are synchronized
    await _irrigationViewModel.getSystemStatus();
    
    // Update switches after mode change and system status refresh
    updateSwitchesFromViewModel();
      
    notifyListeners();
  }
  
  // Get a map between system controls and their titles
  Map<int, String> get controlTitlesMap => {
    0: "Lighting",
    1: "Temperature",
    2: "Irrigation",
    3: "Ventilator",
  };
}
