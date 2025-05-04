import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:pim_project/main.dart';
import 'package:pim_project/model/domain/chat_conversation.dart';
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
      request.fields['user_id'] = MyApp.userId ;
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
       request.fields['user_id'] = MyApp.userId  ;
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

  Future<ApiResponse<List<ChatConversation>>> getConversations() async {
    try {
      final userId = MyApp.userId ?? 'default_user';
      final response = await _apiClient.get(
        'api/v1/conversations/$userId',
        (json) => (json as List<dynamic>).map((item) => ChatConversation.fromJson(item as Map<String, dynamic>)).toList(),
      );

      if (response.status == Status.COMPLETED) {
        return ApiResponse.completed(response.data as List<ChatConversation>);
      } else {
        return ApiResponse.error('Failed to fetch conversations: ${response.message}');
      }
    } catch (e) {
      return ApiResponse.error('Error fetching conversations: $e');
    }
  }

}