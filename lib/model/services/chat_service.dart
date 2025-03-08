import 'dart:io';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart'; 
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

Future<Map<String, dynamic>> sendAudioMessage(File audioFile, {required String detectedDisease}) async {
  final request = MultipartRequest(
    'POST',
    Uri.parse('${_apiClient.baseUrl}/chat/audio'),
  );

  // Use WAV MIME type
  request.files.add(await MultipartFile.fromPath(
    'audio_file',
    audioFile.path,
    contentType: MediaType('audio', 'wav'), // Correct MIME type
  ));

  request.fields['detected_disease'] = detectedDisease;

  final response = await _apiClient.sendMultipart(request);

  if (response.status == Status.COMPLETED) {
    return response.data; // No need to decode again
  } else {
    throw Exception(response.message);
  }
}


}