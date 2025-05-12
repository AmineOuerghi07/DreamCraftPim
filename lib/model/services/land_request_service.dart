import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/domain/land_request.dart';
import 'package:pim_project/model/services/api_client.dart';

class LandRequestService {
  final ApiClient _apiClient = ApiClient(baseUrl: AppConstants.baseUrl);

  Future<ApiResponse<List<LandRequest>>> getLandRequests(String userId) async {
    final response = await _apiClient.get(
      'lands/request/user/$userId',
      (json) => (json as List)
          .map((landJson) => LandRequest.fromJson(landJson))
          .toList(),
    );

    if (response.status == Status.ERROR && response.statusCode == 404) {
      print('No land requests found (404): ${response.message}');
      return ApiResponse.completed(<LandRequest>[]);
    }

    return response;
  }

  Future<ApiResponse<LandRequest>> addLandRequest(
      Map<String, String> request) async {
    return await _apiClient.post(
      'lands/request',
      request,
      (json) => LandRequest.fromJson(json),
    );
  }

  Future<ApiResponse<LandRequest>> acceptLandRequest(String requestId) async {
    Map<String, String> request = {};
    return await _apiClient.post(
      'lands/request/accept/$requestId',
      request,
      (json) => LandRequest.fromJson(json),
    );
  }

  Future<ApiResponse<LandRequest>> rejectLandRequest(String requestId) async {
    Map<String, String> request = {};
    return await _apiClient.post(
      'lands/request/reject/$requestId',
      request,
      (json) => LandRequest.fromJson(json),
    );
  }
}
