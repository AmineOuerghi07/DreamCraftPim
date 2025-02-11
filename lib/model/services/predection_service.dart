import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dart:io';

import 'package:pim_project/model/services/api_client.dart';

class PredictionService {
  final ApiClient _apiClient = ApiClient(baseUrl: 'http://127.0.0.1:8000');

  Future<ApiResponse<String>> predictImage(File imageFile) async {
    try {
      // Create a multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${_apiClient.baseUrl}/predict/'),
      );

      // Add the image file to the request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      // Send the request
      var streamedResponse = await request.send();

      // Get the response
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Parse the JSON response
        var jsonResponse = jsonDecode(response.body);
        String predictedClass = jsonResponse['predicted_class'];
        return ApiResponse.completed(predictedClass);
      } else {
        return ApiResponse.error('Failed to predict image: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Error predicting image: $e');
    }
  }
}