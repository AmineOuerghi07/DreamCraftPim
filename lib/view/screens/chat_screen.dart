import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pim_project/view_model/chat_view_model.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const ChatScreen({super.key, this.initialData});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin { // Changed to TickerProviderStateMixin
  late AnimationController _animationController;
  final TextEditingController _controller = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _currentAudioPath;
  bool _isRecording = false;
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      if (widget.initialData != null) {
        final image = widget.initialData!['image'] as File?;
        final prediction = widget.initialData!['prediction'] as String?;
        if (image != null && prediction != null) {
          setState(() => _selectedImage = image);
          _controller.text = "How do I treat $prediction?";
          _sendInitialMessage();
        }
      }
    });
  }

  void _sendInitialMessage() {
    final chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    chatViewModel.sendMessage(
      _controller.text,
      imageFile: _selectedImage,
      detectedDisease: widget.initialData!['prediction'] as String?,
    );
    _controller.clear();
    setState(() => _selectedImage = null);
    _scrollToBottom();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _loadingController.dispose();
    _audioRecorder.dispose();
    _scrollController.dispose();
    _controller.dispose();
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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
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
            await chatViewModel.sendAudioMessage(
              audioFile,
              imageFile: _selectedImage,
            );
            _scrollToBottom();
            setState(() => _selectedImage = null);
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
                  alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                              color: message.isUser ? Colors.blue[600] : Colors.grey[300],
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: message.isUser ? const Radius.circular(20) : const Radius.circular(4),
                                bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(20),
                              ),
                            ),
                            child: MarkdownBody(
                              data: message.text,
                              styleSheet: MarkdownStyleSheet(
                                h2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: message.isUser ? Colors.white : Colors.green),
                                h3: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: message.isUser ? Colors.white : Colors.blue),
                                strong: TextStyle(fontWeight: FontWeight.bold, color: message.isUser ? Colors.white : Colors.black),
                                p: TextStyle(fontSize: 16, color: message.isUser ? Colors.white : Colors.black),
                                listBullet: TextStyle(fontSize: 16, color: message.isUser ? Colors.white : Colors.black),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: AnimatedBuilder(
                      animation: _loadingController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: GrowingPlantPainter(_loadingController.value),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.eco, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Aam Hssan is writing a message',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
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
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final question = _controller.text.trim();
                    if (question.isNotEmpty) {
                      chatViewModel.sendMessage(
                        question,
                        imageFile: _selectedImage,
                      );
                      _controller.clear();
                      _scrollToBottom();
                      setState(() => _selectedImage = null);
                    }
                  },
                ),
              ],
            ),
          ),
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(_selectedImage!, height: 100),
            ),
        ],
      ),
    );
  }
}

class GrowingPlantPainter extends CustomPainter {
  final double progress;

  GrowingPlantPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw stem
    final stemHeight = size.height * progress;
    canvas.drawLine(
      Offset(size.width / 2, size.height),
      Offset(size.width / 2, size.height - stemHeight),
      paint,
    );

    // Draw leaves
    if (progress > 0.3) {
      final leafProgress = (progress - 0.3) / 0.7;
      final leafSize = size.width * 0.4 * leafProgress;
      final leafY = size.height - stemHeight * 0.5;

      // Left leaf
      final leftLeafPath = Path()
        ..moveTo(size.width / 2, leafY)
        ..quadraticBezierTo(
          size.width / 2 - leafSize, leafY - leafSize * 0.5,
          size.width / 2 - leafSize * 0.8, leafY + leafSize * 0.2,
        );
      canvas.drawPath(leftLeafPath, paint);

      // Right leaf
      final rightLeafPath = Path()
        ..moveTo(size.width / 2, leafY)
        ..quadraticBezierTo(
          size.width / 2 + leafSize, leafY - leafSize * 0.5,
          size.width / 2 + leafSize * 0.8, leafY + leafSize * 0.2,
        );
      canvas.drawPath(rightLeafPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}