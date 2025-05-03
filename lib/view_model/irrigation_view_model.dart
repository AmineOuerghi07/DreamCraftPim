// view_model/irrigation_view_model.dart
import 'package:flutter/material.dart';
import 'package:pim_project/model/domain/irrigation_device.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/model/services/irrigation_service.dart';

class IrrigationViewModel with ChangeNotifier {
  final IrrigationService _irrigationService = IrrigationService();
  
  // Keep track of discovered devices
  List<IrrigationDevice> _discoveredDevices = [];
  IrrigationDevice? _selectedDevice;
  
  // System status
  Map<String, dynamic> _systemStatus = {};
  
  // Operating mode
  bool _isAutomaticMode = true;
  
  // Sensor states
  bool _isPumpOn = false;
  bool _isTemperatureSensorOn = false;
  bool _isVentilatorOn = false;
  bool _isLedOn = false;
  
  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<IrrigationDevice> get discoveredDevices => _discoveredDevices;
  IrrigationDevice? get selectedDevice => _selectedDevice;
  Map<String, dynamic> get systemStatus => _systemStatus;
  bool get isAutomaticMode => _isAutomaticMode;
  bool get isPumpOn => _isPumpOn;
  bool get isTemperatureSensorOn => _isTemperatureSensorOn;
  bool get isVentilatorOn => _isVentilatorOn;
  bool get isLedOn => _isLedOn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Completely reset the device connection state
  void resetDeviceConnection() {
    _selectedDevice = null;
    _discoveredDevices = [];
    _systemStatus = {};
    _isPumpOn = false;
    _isVentilatorOn = false;
    _isLedOn = false;
    notifyListeners();
  }
  
  // Discover devices
  Future<void> discoverDevices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _irrigationService.discoverDevices();
      if (response.status == Status.COMPLETED && response.data != null) {
        _discoveredDevices = response.data!;
      } else {
        _errorMessage = response.message ?? 'Failed to discover devices';
      }
    } catch (e) {
      _errorMessage = 'Error during device discovery: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Select a device by ID
  void selectDevice(String deviceId) {
    final device = _discoveredDevices.firstWhere(
      (device) => device.id == deviceId,
      orElse: () => throw Exception('Device not found'),
    );
    _selectedDevice = device;
    notifyListeners();
    
    // Fetch device status
    getDeviceStatus(deviceId);
  }
  
  // Select a device by IP
  Future<void> selectDeviceByIp(String ipAddress) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _irrigationService.findDeviceByIp(ipAddress);
      if (response.status == Status.COMPLETED && response.data != null) {
        _selectedDevice = response.data!;
        
        // Add to discovered devices if not already there
        if (!_discoveredDevices.any((d) => d.id == _selectedDevice!.id)) {
          _discoveredDevices.add(_selectedDevice!);
        }
        
        // Fetch device status
        await getDeviceStatus(_selectedDevice!.id);
      } else {
        _errorMessage = response.message ?? 'Failed to find device by IP';
      }
    } catch (e) {
      _errorMessage = 'Error finding device: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get system status
  Future<void> getSystemStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _irrigationService.getSystemStatus();
      if (response.status == Status.COMPLETED && response.data != null) {
        _systemStatus = response.data!;
        
        // Update state variables based on status
        _updateStateFromSystemStatus();
      } else {
        _errorMessage = response.message ?? 'Failed to get system status';
      }
    } catch (e) {
      _errorMessage = 'Error getting system status: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get device status
  Future<void> getDeviceStatus(String deviceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _irrigationService.getDeviceStatus(deviceId);
      if (response.status == Status.COMPLETED && response.data != null) {
        _systemStatus = response.data!;
        
        // Update state variables based on status
        _updateStateFromSystemStatus();
      } else {
        _errorMessage = response.message ?? 'Failed to get device status';
      }
    } catch (e) {
      _errorMessage = 'Error getting device status: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Helper to update state from system status
  void _updateStateFromSystemStatus() {
    if (_systemStatus.containsKey('mode')) {
      _isAutomaticMode = _systemStatus['mode'] == 'AUTOMATIC';
    }
    
    if (_systemStatus.containsKey('pump_state')) {
      _isPumpOn = _systemStatus['pump_state'] == true;
    }
    
    if (_systemStatus.containsKey('temperature_sensor')) {
      _isTemperatureSensorOn = _systemStatus['temperature_sensor'] == true;
    }
    
    if (_systemStatus.containsKey('ventilator_state')) {
      _isVentilatorOn = _systemStatus['ventilator_state'] == false;
    }
    
    if (_systemStatus.containsKey('led_state')) {
      _isLedOn = _systemStatus['led_state'] == true;
    }
  }
  
  // Set pump state
  Future<void> setPumpState(bool state) async {
    if (_isAutomaticMode) {
      // Can't change pump state in automatic mode
      return;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _irrigationService.setPumpState(state);
      if (response.status == Status.COMPLETED) {
        _isPumpOn = state;
      } else {
        _errorMessage = response.message ?? 'Failed to set pump state';
      }
    } catch (e) {
      _errorMessage = 'Error setting pump state: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Set operation mode
  Future<void> setOperationMode(bool automatic) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final mode = automatic ? 'AUTOMATIC' : 'MANUAL';
      final response = await _irrigationService.setOperationMode(mode);
      if (response.status == Status.COMPLETED) {
        _isAutomaticMode = automatic;
        
        // In manual mode, turn off everything by default
        if (!automatic) {
          await setPumpState(false);
          await setTemperatureSensor(false);
          await setVentilatorState(false);
          await setLedState(false);
        }
      } else {
        _errorMessage = response.message ?? 'Failed to set operation mode';
      }
    } catch (e) {
      _errorMessage = 'Error setting operation mode: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Set temperature sensor state
  Future<void> setTemperatureSensor(bool enabled) async {
    if (_isAutomaticMode) {
      // Can't change sensor state in automatic mode
      return;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _irrigationService.setTemperatureSensor(enabled);
      if (response.status == Status.COMPLETED) {
        _isTemperatureSensorOn = enabled;
      } else {
        _errorMessage = response.message ?? 'Failed to set temperature sensor';
      }
    } catch (e) {
      _errorMessage = 'Error setting temperature sensor: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Set ventilator state
  Future<void> setVentilatorState(bool enabled) async {
    if (_isAutomaticMode) {
      // Can't change ventilator state in automatic mode
      return;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Invert the value sent to the API to fix the on/off inversion
      final response = await _irrigationService.setVentilatorState(!enabled);
      if (response.status == Status.COMPLETED) {
        _isVentilatorOn = enabled;
      } else {
        _errorMessage = response.message ?? 'Failed to set ventilator state';
      }
    } catch (e) {
      _errorMessage = 'Error setting ventilator state: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Set LED state
  Future<void> setLedState(bool enabled) async {
    if (_isAutomaticMode) {
      // Can't change LED state in automatic mode
      return;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _irrigationService.setLedState(enabled);
      if (response.status == Status.COMPLETED) {
        _isLedOn = enabled;
      } else {
        _errorMessage = response.message ?? 'Failed to set LED state';
      }
    } catch (e) {
      _errorMessage = 'Error setting LED state: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update system configuration
  Future<void> updateSystemConfig(Map<String, dynamic> config) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _irrigationService.updateSystemConfig(config);
      if (response.status == Status.COMPLETED) {
        // Success, update system status to reflect changes
        await getSystemStatus();
      } else {
        _errorMessage = response.message ?? 'Failed to update system config';
      }
    } catch (e) {
      _errorMessage = 'Error updating system config: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Send command to a device
  Future<void> sendCommand(String deviceId, Map<String, dynamic> command) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _irrigationService.sendCommand(deviceId, command);
      if (response.status == Status.COMPLETED) {
        // Success, update device status to reflect changes
        await getDeviceStatus(deviceId);
      } else {
        _errorMessage = response.message ?? 'Failed to send command';
      }
    } catch (e) {
      _errorMessage = 'Error sending command: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 