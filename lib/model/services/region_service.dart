import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/model/services/api_client.dart';

class RegionService {

  final ApiClient _apiClient = ApiClient(baseUrl: AppConstants.baseURL);

  Future<ApiResponse<Region>> addRegion(Region region) async {
        return _apiClient.post(
      'lands/region',
      region.toJson(),
      (json) => Region.fromJson(json),
    );
  }

  Future<ApiResponse<List<Region>>> getRegionsById(String regionId) async {
    return _apiClient.get(
      'land/region/$regionId',
      (json) => (json as List).map((r) => Region.fromJson(r)).toList(),
    );
  }

  Future<ApiResponse<Region>> updateRegion(Region region) async {
    return _apiClient.put(
      'land/region/${region.id}',
      region.toJson(),
      (json) => Region.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteRegion(String regionId) async {
    return _apiClient.delete('land/region/$regionId');
  }
}
