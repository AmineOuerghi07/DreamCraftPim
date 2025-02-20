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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }
  @override
  void dispose() {
    _animationController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }
Future<String> _getAudioPath() async {
  final directory = await getTemporaryDirectory();
  return '${directory.path}/audio.wav';  // Use WAV extension
}

Future<void> _toggleRecording(ChatViewModel chatViewModel) async {
  try {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      _animationController.stop();

      if (path != null && await File(path).exists()) {
        // Add validation before sending
        final audioFile = File(path);
        if (await audioFile.length() > 1024) { // At least 1KB
          await chatViewModel.sendAudioFile(
            audioFile,
            detectedDisease: "Tomato Blight",
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recording too short')),
          );
        }
      }
    } else {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        _currentAudioPath = await _getAudioPath();
        // Record in WAV format with proper configuration
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav, // Use WAV encoder
            sampleRate: 16000, // 16kHz sample rate
            bitRate: 256000,   // 256kbps bitrate
            numChannels: 1,    // Mono channel
          ),
          path: _currentAudioPath!,
        );
        setState(() => _isRecording = true);
        _animationController.repeat(reverse: true);
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recording error: ${e.toString()}')),
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
              itemCount: chatViewModel.messages.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(chatViewModel.messages[index]),
              ),
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