import 'dart:io';

import 'package:flutter/material.dart';
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
      _messages.add(Message(text: response, isUser: false));
    } catch (e) {
      _messages.add(Message(text: e.toString(), isUser: false));
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