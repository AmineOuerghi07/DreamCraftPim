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
  return await _apiClient.postMultipart(
    endpoint: 'lands',
    fields: land.toMap(),
    files: {'file': image},
    parser: (json) => Land.fromJson(json),
  );
}

 
  Future<ApiResponse<List<Land>>> getLands() async {
    return await _apiClient.get(
      'lands/all',
     (json) => (json as List).map((landJson) => Land.fromJson(landJson)).toList(),
    );
  }
  Future<ApiResponse<Land>> getLandById(String id) async {
    return await _apiClient.get(
      'lands/land/$id',
      (json) => Land.fromJson(json),
    );
}
Future<ApiResponse<void>> deleteLand(String id) async {  // Changed return type
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
  return await _apiClient.get(
    'lands/users/$userId',
    (json) => (json as List).map((landJson) => Land.fromJson(landJson)).toList(),
  );
}



Future<ApiResponse<List<PlantWithQuantity>>> getPlantsByLandId(String landId) async {
    return await _apiClient.get(
      'lands/land/plants/$landId',
      (json) => (json as List)
          .map((plantJson) => PlantWithQuantity.fromJson(plantJson))
          .toList(),
    );
  }
}