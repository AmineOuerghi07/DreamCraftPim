// model/services/land_service.dart
import 'dart:io';

import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/domain/plant-with-quantity.dart';

import 'api_client.dart';

class LandService {
  final ApiClient _apiClient = ApiClient(baseUrl: AppConstants.baseUrl);
  
  Future<ApiResponse<Land>> addLand({
    required Land land,
    required File image,
  }) async {
    // Prepare the fields map with all necessary data
    final fields = land.toMap();
    
    // Make sure owner phone is included if available
    if (land.ownerPhone.isNotEmpty) {
      fields['ownerPhone'] = land.ownerPhone;
      print('Including owner phone in request: ${land.ownerPhone}');
    }
    
    return await _apiClient.postMultipart(
      endpoint: 'lands',
      fields: fields,
      files: {'file': image},
      parser: (json) => Land.fromJson(json),
    );
  }
  
  Future<ApiResponse<List<Land>>> getLands() async {
    final response = await _apiClient.get(
      'lands/all',
      (json) => (json as List).map((landJson) => Land.fromJson(landJson)).toList(),
    );
    
    // Handle 404 "No lands found" case by returning an empty list instead of an error
    if (response.status == Status.ERROR && response.statusCode == 404) {
      print('No lands found (404): ${response.message}');
      return ApiResponse.completed(<Land>[]);
    }
    
    return response;
  }
  
  Future<ApiResponse<Land>> getLandById(String id) async {
    return await _apiClient.get(
      'lands/land/$id',
      (json) => Land.fromJson(json),
    );
  }
  
  Future<ApiResponse<void>> deleteLand(String id) async {
    return await _apiClient.delete('lands/land/$id');
  }
  
  Future<ApiResponse<Land>> updateLand(String id, Land land, {File? image}) async {
    if (image != null) {
      return await _apiClient.putMultipart(
        endpoint: 'lands/land/$id',
        fields: land.toMap(),
        files: {'file': image},
        parser: (json) => Land.fromJson(json),
      );
    } else {
      return await _apiClient.put(
        'lands/land/$id',
        land.toMap(),
        (json) => Land.fromJson(json),
      );
    }
  }
  
  Future<ApiResponse<List<Land>>> getLandsByUserId(String userId) async {
    print('Requesting lands for user ID: $userId');
    
    final response = await _apiClient.get(
      'lands/users/$userId',
      (json) => (json as List).map((landJson) => Land.fromJson(landJson)).toList(),
    );
    
    // Special handling for 404 "No lands found" case
    if (response.status == Status.ERROR && response.statusCode == 404) {
      print('No lands found for user (404): ${response.message}');
      // Return an empty list with completed status instead of an error
      return ApiResponse.completed(<Land>[]);
    }
    
    // Debug information
    print('Response status: ${response.status}, statusCode: ${response.statusCode}');
    print('Response message: ${response.message}');
    print('Response data: ${response.data?.length ?? 0} items');
    
    return response;
  }
  
  Future<ApiResponse<List<PlantWithQuantity>>> getPlantsByLandId(String landId) async {
    final response = await _apiClient.get(
      'lands/land/plants/$landId',
      (json) => (json as List)
          .map((plantJson) => PlantWithQuantity.fromJson(plantJson))
          .toList(),
    );
    
    // Handle 404 case for plants
    if (response.status == Status.ERROR && response.statusCode == 404) {
      print('No plants found for land (404): ${response.message}');
      return ApiResponse.completed(<PlantWithQuantity>[]);
    }
    
    return response;
  }
  
  Future<ApiResponse<List<Land>>> findLandsForRent() async {
    final response = await _apiClient.get(
      'lands/land/check/forRent',
      (json) => (json as List).map((l) => Land.fromJson(l)).toList(),
    );
    
    // Handle 404 case
    if (response.status == Status.ERROR && response.statusCode == 404) {
      print('No lands for rent found (404): ${response.message}');
      return ApiResponse.completed(<Land>[]);
    }
    
    return response;
  }
}