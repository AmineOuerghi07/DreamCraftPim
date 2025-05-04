import 'package:intl/intl.dart';

class ChatConversation {
  final String question;
  final String response;
  final DateTime timestamp;

  ChatConversation({
    required this.question,
    required this.response,
    required this.timestamp,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      question: json['question'] as String,
      response: json['response'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'response': response,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}