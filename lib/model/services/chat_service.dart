import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:pim_project/model/services/api_client.dart';

class ChatService {
  final ApiClient _apiClient;

  ChatService({required String baseUrl}) : _apiClient = ApiClient(baseUrl: baseUrl);

  Future<ApiResponse<String>> sendMessage(String question, {String? detectedDisease, File? imageFile}) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${_apiClient.baseUrl}/api/v1/chat'),
      );

      request.fields['question'] = question;
      if (detectedDisease != null) {
        request.fields['detected_disease'] = detectedDisease;
      }
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'), // Adjust based on your image type
        ));
      }

      final response = await _apiClient.sendMultipart(request);

      if (response.status == Status.COMPLETED) {
        return ApiResponse.completed(response.data['response'] as String); // Markdown response
      } else {
        return ApiResponse.error('Failed to send message: ${response.message}');
      }
    } catch (e) {
      return ApiResponse.error('Error sending message: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> sendAudioMessage(File audioFile, {String? detectedDisease, File? imageFile}) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${_apiClient.baseUrl}/api/v1/chat/audio'),
      );

      request.files.add(await http.MultipartFile.fromPath(
        'audio_file',
        audioFile.path,
        contentType: MediaType('audio', 'wav'),
      ));

      if (detectedDisease != null) {
        request.fields['detected_disease'] = detectedDisease;
      }
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      final response = await _apiClient.sendMultipart(request);

      if (response.status == Status.COMPLETED) {
        return ApiResponse.completed(response.data);
      } else {
        return ApiResponse.error('Failed to send audio message: ${response.message}');
      }
    } catch (e) {
      return ApiResponse.error('Error sending audio message: $e');
    }
  }
}