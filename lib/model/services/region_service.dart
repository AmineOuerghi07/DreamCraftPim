// model/services/region_service.dart
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/model/services/api_client.dart';

class RegionService {

  final ApiClient _apiClient = ApiClient(baseUrl: AppConstants.baseUrl);

  Future<ApiResponse<Region>> addRegion(Region region) async {
    return _apiClient.post(
      'lands/region',
      region.toJson(),
      (json) => Region.fromJson(json),
    );
  }

  Future<ApiResponse<List<Region>>> getRegions() async {
    return _apiClient.get(
      'lands/region',
      (json) => (json as List).map((r) => Region.fromJson(r)).toList(),
    );
  }

  Future<ApiResponse<Region>> getRegionsById(String regionId) async {
    return _apiClient.get(
      'lands/region/$regionId',
      (json) => Region.fromJson(json),
    );
  }

  Future<ApiResponse<Region>> updateRegion(Region region) async {
    return _apiClient.put(
      'lands/region/${region.id}',
      region.toJson(),
      (json) => Region.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteRegion(String regionId) async {
    return _apiClient.delete('lands/region/$regionId');
  }

  Future<ApiResponse<Region>> addPlantToRegion(String regionId, String plantId, int quantity) async {
    final payload = {
      "regionId": regionId,
      "plantId": plantId,
      "quantity": quantity,
    };
    return _apiClient.post(
      'lands/region/addPlant',
      payload,
      (json) => Region.fromJson(json),
    );
  }

  Future<ApiResponse<List<Region>>> findConnectedRegions(String userId) async {
    return _apiClient.get(
      'lands/region/connectedRegions/$userId',
      (json) => (json as List).map((r) => Region.fromJson(r)).toList(),
    );
  }
}
