import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pim_project/view_model/chat_view_model.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _controller = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _currentAudioPath;
  bool _isRecording = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioRecorder.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<String> _getAudioPath() async {
    final directory = await getTemporaryDirectory();
    return '${directory.path}/audio.wav';
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _toggleRecording(ChatViewModel chatViewModel) async {
    try {
      if (_isRecording) {
        final path = await _audioRecorder.stop();
        setState(() => _isRecording = false);
        _animationController.stop();

        if (path != null && await File(path).exists()) {
          final audioFile = File(path);
          if (await audioFile.length() > 1024) {
            await chatViewModel.sendAudioFile(
              audioFile,
              detectedDisease: "Tomato Blight",
            );
            _scrollToBottom();
          }
        }
      } else {
        final status = await Permission.microphone.request();
        if (status.isGranted) {
          _currentAudioPath = await _getAudioPath();
          await _audioRecorder.start(
            const RecordConfig(
              encoder: AudioEncoder.wav,
              sampleRate: 16000,
              bitRate: 256000,
              numChannels: 1,
            ),
            path: _currentAudioPath!,
          );
          setState(() => _isRecording = true);
          _animationController.repeat(reverse: true);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatViewModel = Provider.of<ChatViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Disease Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: chatViewModel.messages.length,
              itemBuilder: (context, index) {
                final message = chatViewModel.messages[index];
                return Align(
                  alignment: message.isUser 
                      ? Alignment.centerRight 
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: message.isUser 
                          ? MainAxisAlignment.end 
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!message.isUser) ...[
                          const Icon(Icons.spa, color: Colors.green, size: 28),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: message.isUser 
                                  ? Colors.blue[600] 
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: message.isUser 
                                    ? const Radius.circular(20) 
                                    : const Radius.circular(4),
                                bottomRight: message.isUser 
                                    ? const Radius.circular(4) 
                                    : const Radius.circular(20),
                              ),
                            ),
                            child: Text(
                              message.text,
                              style: TextStyle(
                                color: message.isUser ? Colors.white : Colors.black,
                                fontSize: 16
                              ),
                            ),
                          ),
                        ),
                        if (message.isUser) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.person, color: Colors.blue[600], size: 28),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (chatViewModel.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isRecording
                        ? ScaleTransition(
                            scale: Tween(begin: 1.0, end: 1.5).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Curves.easeInOut,
                              ),
                            ),
                            child: const Icon(Icons.mic, color: Colors.red, key: ValueKey('rec')),
                          )
                        : const Icon(Icons.mic_none, key: ValueKey('idle')),
                  ),
                  onPressed: () => _toggleRecording(chatViewModel),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask a question...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final question = _controller.text.trim();
                    if (question.isNotEmpty) {
                      chatViewModel.sendMessage(
                        question,
                        detectedDisease: "Tomato Blight",
                      );
                      _controller.clear();
                      _scrollToBottom();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String text;
  final bool isUser;

  Message({required this.text, required this.isUser});
}