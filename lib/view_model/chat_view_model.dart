import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pim_project/model/services/chat_service.dart';

class ChatViewModel with ChangeNotifier {
  late final ChatService _chatService;
  List<String> _messages = [];
  bool _isLoading = false;

  List<String> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatViewModel(String chatBaseUrl) {
    _chatService = ChatService(baseUrl: chatBaseUrl);
  }

  Future<void> sendMessage(String question, {String? detectedDisease}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _chatService.sendMessage(question, detectedDisease: detectedDisease);
      _messages.add('You: $question');
      _messages.add('Assistant: $response');
    } catch (e) {
      _messages.add('Error: $e');
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
      _messages.add('Audio sent: $response');
    } catch (e) {
      _messages.add('Audio error: $e');
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