import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pim_project/model/services/chat_service.dart';
import 'package:pim_project/view/screens/chat_screen.dart';

class ChatViewModel with ChangeNotifier {
  late final ChatService _chatService;
  List<Message> _messages = [];
  bool _isLoading = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatViewModel(String chatBaseUrl) {
    _chatService = ChatService(baseUrl: chatBaseUrl);
  }

  Future<void> sendMessage(String question, {String? detectedDisease}) async {
    _isLoading = true;
    notifyListeners();

    try {
     _messages.add(Message(text: question, isUser: true));

      final response = await _chatService.sendMessage(question, detectedDisease: detectedDisease);
      _messages.add(Message(text: response, isUser: false));
    } catch (e) {
      _messages.add(Message(text: e.toString(), isUser: true));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

   bool _isRecording = false;
  bool get isRecording => _isRecording;

Future<void> sendAudioFile(File audioFile, {required String detectedDisease}) async {
  _isLoading = true;
  notifyListeners();

  try {
    final response = await _chatService.sendAudioMessage(
      audioFile,
      detectedDisease: detectedDisease,
    );

    // Ensure response is a Map
    if (response is Map<String, dynamic>) {
      final question = response['question'] as String? ?? "No question recognized";
      final textResponse = response['text_response'] as String? ?? "No response";
      final audioBase64 = response['audio_base64'] as String?;

      // Add the recognized text as a user message
      _messages.add(Message(text: question, isUser: true));

      // Add the bot's text response
      _messages.add(Message(text: textResponse, isUser: false));

      if (audioBase64 != null) {
        // Decode the base64 audio and save it to a file
        final audioBytes = base64.decode(audioBase64);
        final directory = await getApplicationDocumentsDirectory();
        final audioPath = '${directory.path}/response.mp3';
        await File(audioPath).writeAsBytes(audioBytes);

        // Optional: Play the audio file (use an audio player package)
      }
    } else {
      throw Exception("Unexpected response format");
    }

  } catch (e) {
    _messages.add(Message(text: "Error: ${e.toString()}", isUser: false));
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  void startRecording() {
    _isRecording = true;
    notifyListeners();
  }

  void stopRecording() {
    _isRecording = false;
    notifyListeners();
  }
}