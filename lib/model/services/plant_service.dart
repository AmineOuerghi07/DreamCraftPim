import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/domain/plant.dart';
import 'package:pim_project/model/services/api_client.dart';

class PlantService {

  final ApiClient _apiClient = ApiClient(baseUrl: AppConstants.baseURL);

  Future<ApiResponse<Plant>> addPlant(Plant plant) async {
        return _apiClient.post(
      'lands/plant',
      plant.toJson(),
      (json) => Plant.fromJson(json),
    );
  }

  Future<ApiResponse<List<Plant>>> getPlantsById(String plantId) async {
    return _apiClient.get(
      'lands/plant/$plantId',
      (json) => (json as List).map((r) => Plant.fromJson(r)).toList(),
    );
  }
  Future<ApiResponse<List<Plant>>> getPlants() async {
    return _apiClient.get(
      'lands/plant',
      (json) => (json as List).map((r) => Plant.fromJson(r)).toList(),
    );
  }
  Future<ApiResponse<Plant>> updatePlant(Plant plant) async {
    return _apiClient.put(
      'lands/plant/${plant.id}',
      plant.toJson(),
      (json) => Plant.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deletePlant(String plantId) async {
    return _apiClient.delete('land/plant/$plantId');
  }
}
