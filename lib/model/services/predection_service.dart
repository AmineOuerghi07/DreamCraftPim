import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pim_project/model/services/api_client.dart';

class PredictionService {
  final ApiClient _apiClient = ApiClient(baseUrl: 'http://192.168.43.232:8000');

  Future<ApiResponse<String>> predictImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${_apiClient.baseUrl}/api/v1/disease/predict'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // Matches FastAPI endpoint parameter
          imageFile.path,
        ),
      );

      final response = await _apiClient.sendMultipart(request);

      if (response.status == Status.COMPLETED) {
        return ApiResponse.completed(response.data['predicted_class'] as String);
      } else {
        return ApiResponse.error('Failed to predict image: ${response.message}');
      }
    } catch (e) {
      print("Error in predictImage: $e");
      return ApiResponse.error('Error predicting image: $e');
    }
  }
}