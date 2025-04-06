import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pim_project/model/services/chat_service.dart';
import 'package:pim_project/model/services/api_client.dart';

class Message {
  final String text;
  final bool isUser;

  Message({required this.text, required this.isUser});
}

class ChatViewModel with ChangeNotifier {
  late final ChatService _chatService;
  List<Message> _messages = [];
  bool _isLoading = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatViewModel(String chatBaseUrl) {
    _chatService = ChatService(baseUrl: chatBaseUrl);
  }

  Future<void> sendMessage(String question, {String? detectedDisease, File? imageFile}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _messages.add(Message(text: question, isUser: true));
      final response = await _chatService.sendMessage(
        question,
        detectedDisease: detectedDisease,
        imageFile: imageFile,
      );
      if (response.status == Status.COMPLETED) {
        _messages.add(Message(text: response.data!, isUser: false));
      } else {
        _messages.add(Message(text: "Error: ${response.message}", isUser: false));
      }
    } catch (e) {
      _messages.add(Message(text: "Error: $e", isUser: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendAudioMessage(File audioFile, {String? detectedDisease, File? imageFile}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _chatService.sendAudioMessage(
        audioFile,
        detectedDisease: detectedDisease,
        imageFile: imageFile,
      );

      if (response.status == Status.COMPLETED) {
        final question = response.data!['question'] as String? ?? "No question recognized";
        final textResponse = response.data!['text_response'] as String? ?? "No response";
        final audioBase64 = response.data!['audio_base64'] as String?;

        _messages.add(Message(text: question, isUser: true));
        _messages.add(Message(text: textResponse, isUser: false));

        if (audioBase64 != null) {
          final audioBytes = base64.decode(audioBase64);
          final directory = await getApplicationDocumentsDirectory();
          final audioPath = '${directory.path}/response.mp3';
          await File(audioPath).writeAsBytes(audioBytes);
          // Optionally play audio here with an audio player package
        }
      } else {
        _messages.add(Message(text: "Error: ${response.message}", isUser: false));
      }
    } catch (e) {
      _messages.add(Message(text: "Error: $e", isUser: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  void startRecording() {
    _isRecording = true;
    notifyListeners();
  }

  void stopRecording() {
    _isRecording = false;
    notifyListeners();
  }
}