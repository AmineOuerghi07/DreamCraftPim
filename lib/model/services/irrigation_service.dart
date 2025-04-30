// model/services/irrigation_service.dart
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/domain/irrigation_device.dart';
import 'package:pim_project/model/services/api_client.dart';

class IrrigationService {
  final ApiClient _apiClient = ApiClient(baseUrl: AppConstants.baseUrl);
  final String _baseUrl = 'irrigation'; // Base URL for irrigation endpoints

  // Discover available irrigation devices
  Future<ApiResponse<List<IrrigationDevice>>> discoverDevices() async {
    try {
      final response = await _apiClient.get('$_baseUrl/discover', 
        (data) {
          // Extract the "data" array from the response
          return ((data as Map<String, dynamic>)['data'] as List)
            .map((device) => IrrigationDevice.fromJson(device))
            .toList();
        });
      if (response.status == Status.COMPLETED && response.data != null) {
        return ApiResponse.completed(response.data!);
      } else {
        return ApiResponse.error(response.message ?? 'Failed to discover devices');
      }
    } catch (e) {
      return ApiResponse.error('An error occurred: ${e.toString()}');
    }
  }

  // Get status of the irrigation system
  Future<ApiResponse<Map<String, dynamic>>> getSystemStatus() async {
    try {
      final response = await _apiClient.get('$_baseUrl/status', 
        (data) => data as Map<String, dynamic>);
      if (response.status == Status.COMPLETED && response.data != null) {
        return ApiResponse.completed(response.data!);
      } else {
        return ApiResponse.error(response.message ?? 'Failed to get system status');
      }
    } catch (e) {
      return ApiResponse.error('An error occurred: ${e.toString()}');
    }
  }

  // Turn pump on/off
  Future<ApiResponse<Map<String, dynamic>>> setPumpState(bool state) async {
    try {
      final endpoint = state ? '$_baseUrl/pump/on' : '$_baseUrl/pump/off';
      final response = await _apiClient.post(endpoint, {}, 
        (data) => data as Map<String, dynamic>);
      if (response.status == Status.COMPLETED && response.data != null) {
        return ApiResponse.completed(response.data!);
      } else {
        return ApiResponse.error(response.message ?? 'Failed to set pump state');
      }
    } catch (e) {
      return ApiResponse.error('An error occurred: ${e.toString()}');
    }
  }

  // Set operation mode (AUTO/MANUAL)
  Future<ApiResponse<Map<String, dynamic>>> setOperationMode(String mode) async {
    try {
      final endpoint = mode == 'AUTOMATIC' 
          ? '$_baseUrl/mode/automatic' 
          : '$_baseUrl/mode/manual';
      final response = await _apiClient.post(endpoint, {}, 
        (data) => data as Map<String, dynamic>);
      if (response.status == Status.COMPLETED && response.data != null) {
        return ApiResponse.completed(response.data!);
      } else {
        return ApiResponse.error(response.message ?? 'Failed to set operation mode');
      }
    } catch (e) {
      return ApiResponse.error('An error occurred: ${e.toString()}');
    }
  }

  // Enable/disable temperature sensor
  Future<ApiResponse<Map<String, dynamic>>> setTemperatureSensor(bool enabled) async {
    try {
      final endpoint = enabled 
          ? '$_baseUrl/temperature/enable' 
          : '$_baseUrl/temperature/disable';
      final response = await _apiClient.post(endpoint, {}, 
        (data) => data as Map<String, dynamic>);
      if (response.status == Status.COMPLETED && response.data != null) {
        return ApiResponse.completed(response.data!);
      } else {
        return ApiResponse.error(response.message ?? 'Failed to set temperature sensor');
      }
    } catch (e) {
      return ApiResponse.error('An error occurred: ${e.toString()}');
    }
  }

  // Update system configuration
  Future<ApiResponse<Map<String, dynamic>>> updateSystemConfig(Map<String, dynamic> config) async {
    try {
      final response = await _apiClient.post('$_baseUrl/config', config, 
        (data) => data as Map<String, dynamic>);
      if (response.status == Status.COMPLETED && response.data != null) {
        return ApiResponse.completed(response.data!);
      } else {
        return ApiResponse.error(response.message ?? 'Failed to update system config');
      }
    } catch (e) {
      return ApiResponse.error('An error occurred: ${e.toString()}');
    }
  }

  // Send command to a specific device by ID
  Future<ApiResponse<Map<String, dynamic>>> sendCommand(
      String deviceId, Map<String, dynamic> command) async {
    try {
      final response = await _apiClient.post('$_baseUrl/$deviceId/command', command, 
        (data) => data as Map<String, dynamic>);
      if (response.status == Status.COMPLETED && response.data != null) {
        return ApiResponse.completed(response.data!);
      } else {
        return ApiResponse.error(response.message ?? 'Failed to send command');
      }
    } catch (e) {
      return ApiResponse.error('An error occurred: ${e.toString()}');
    }
  }

  // Get status of a specific device
  Future<ApiResponse<Map<String, dynamic>>> getDeviceStatus(String deviceId) async {
    try {
      final response = await _apiClient.get('$_baseUrl/$deviceId/status', 
        (data) => data as Map<String, dynamic>);
      if (response.status == Status.COMPLETED && response.data != null) {
        return ApiResponse.completed(response.data!);
      } else {
        return ApiResponse.error(response.message ?? 'Failed to get device status');
      }
    } catch (e) {
      return ApiResponse.error('An error occurred: ${e.toString()}');
    }
  }

  // Find device by IP address
  Future<ApiResponse<IrrigationDevice>> findDeviceByIp(String ipAddress) async {
    try {
      final response = await _apiClient.get('$_baseUrl/discover-by-ip/$ipAddress', 
        (data) => IrrigationDevice.fromJson(data));
      if (response.status == Status.COMPLETED && response.data != null) {
        return ApiResponse.completed(response.data!);
      } else {
        return ApiResponse.error(response.message ?? 'Failed to find device by IP');
      }
    } catch (e) {
      return ApiResponse.error('An error occurred: ${e.toString()}');
    }
  }

  // Send command to device by IP address
  Future<ApiResponse<Map<String, dynamic>>> sendCommandByIp(
      String ipAddress, Map<String, dynamic> command) async {
    try {
      final response = await _apiClient.post('$_baseUrl/ip/$ipAddress/command', command, 
        (data) => data as Map<String, dynamic>);
      if (response.status == Status.COMPLETED && response.data != null) {
        return ApiResponse.completed(response.data!);
      } else {
        return ApiResponse.error(response.message ?? 'Failed to send command by IP');
      }
    } catch (e) {
      return ApiResponse.error('An error occurred: ${e.toString()}');
    }
  }
} 