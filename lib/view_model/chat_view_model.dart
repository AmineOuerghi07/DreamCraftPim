import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pim_project/model/domain/chat_conversation.dart';
import 'package:pim_project/model/services/chat_service.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:flutter/foundation.dart';

class Message {
  final String text;
  final bool isUser;

  Message({required this.text, required this.isUser});
}

class ChatViewModel with ChangeNotifier {
  late final ChatService _chatService;
  List<Message> _messages = [];
  List<ChatConversation> _conversations = [];
  ChatConversation? _selectedConversation;
  bool _isLoading = false;

  List<Message> get messages => _messages;
  List<ChatConversation> get conversations => _conversations;
  ChatConversation? get selectedConversation => _selectedConversation;
  bool get isLoading => _isLoading;

  ChatViewModel(String chatBaseUrl) {
    _chatService = ChatService(baseUrl: chatBaseUrl);
    fetchConversations();
  }

  Future<void> sendMessage(String question, {String? detectedDisease, File? imageFile}) async {
    if (question.isEmpty) return;

    _isLoading = true;
    _selectedConversation = null;
    notifyListeners();
    debugPrint('Sending message: $question');

    try {
      _messages.add(Message(text: question, isUser: true));
      // Ensure minimum animation duration
      final responseFuture = _chatService.sendMessage(
        question,
        detectedDisease: detectedDisease,
        imageFile: imageFile,
      );
      await Future.wait([
        responseFuture,
        Future.delayed(const Duration(seconds: 2)), // Minimum 2 seconds for animation
      ]);
      final response = await responseFuture;
      if (response.status == Status.COMPLETED) {
        _messages.add(Message(text: response.data!, isUser: false));
        debugPrint('Message sent successfully, fetching conversations');
        await fetchConversations();
      } else {
        _messages.add(Message(text: "Error: ${response.message}", isUser: false));
        debugPrint('Failed to send message: ${response.message}');
      }
    } catch (e) {
      _messages.add(Message(text: "Error: $e", isUser: false));
      debugPrint('Error sending message: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('Finished sendMessage, isLoading: $_isLoading');
    }
  }

  Future<void> sendAudioMessage(File audioFile, {String? detectedDisease, File? imageFile}) async {
    _isLoading = true;
    _selectedConversation = null;
    notifyListeners();
    debugPrint('Sending audio message');

    try {
      // Ensure minimum animation duration
      final responseFuture = _chatService.sendAudioMessage(
        audioFile,
        detectedDisease: detectedDisease,
        imageFile: imageFile,
      );
      await Future.wait([
        responseFuture,
        Future.delayed(const Duration(seconds: 2)), // Minimum 2 seconds for animation
      ]);
      final response = await responseFuture;
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
        }
        debugPrint('Audio message sent successfully, fetching conversations');
        await fetchConversations();
      } else {
        _messages.add(Message(text: "Error: ${response.message}", isUser: false));
        debugPrint('Failed to send audio message: ${response.message}');
      }
    } catch (e) {
      _messages.add(Message(text: "Error: $e", isUser: false));
      debugPrint('Error sending audio message: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('Finished sendAudioMessage, isLoading: $_isLoading');
    }
  }

  Future<void> fetchConversations() async {
    _isLoading = true;
    notifyListeners();
    debugPrint('Fetching conversations');

    try {
      final response = await _chatService.getConversations();
      if (response.status == Status.COMPLETED) {
        _conversations = response.data as List<ChatConversation>;
        debugPrint('Stored ${_conversations.length} conversations: ${_conversations.map((c) => c.question).toList()}');
      } else {
        _messages.add(Message(text: "Error fetching conversations: ${response.message}", isUser: false));
        debugPrint('Error fetching conversations: ${response.message}');
      }
    } catch (e) {
      _messages.add(Message(text: "Error fetching conversations: $e", isUser: false));
      debugPrint('Error fetching conversations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('Finished fetching conversations, isLoading: $_isLoading');
    }
  }

  void selectConversation(ChatConversation conversation) {
    _selectedConversation = conversation;
    _messages = [
      Message(text: conversation.question, isUser: true),
      Message(text: conversation.response, isUser: false),
    ];
    notifyListeners();
    debugPrint('Selected conversation: ${conversation.question}');
  }

  void startNewConversation() {
    _selectedConversation = null;
    _messages = [];
    notifyListeners();
    debugPrint('Started new conversation');
  }

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  void startRecording() {
    _isRecording = true;
    notifyListeners();
    debugPrint('Started recording');
  }

  void stopRecording() {
    _isRecording = false;
    notifyListeners();
    debugPrint('Stopped recording');
  }
}