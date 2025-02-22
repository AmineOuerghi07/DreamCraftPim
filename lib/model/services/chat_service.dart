import 'dart:convert';
import 'api_client.dart'; 

class ChatService {
  final ApiClient _apiClient;

  ChatService({required String baseUrl}) : _apiClient = ApiClient(baseUrl: baseUrl);

  Future<String> sendMessage(String question, {String? detectedDisease}) async {
    final body = {
      'question': question,
      'detected_disease': detectedDisease,
    };

    final response = await _apiClient.post(
      'chat', // Endpoint
      body,
      (data) => data['response'] as String, // Parse the response
    );

    if (response.status == Status.COMPLETED) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }
}