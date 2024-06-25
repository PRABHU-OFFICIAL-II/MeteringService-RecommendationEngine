import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'chat_service.dart';
import 'message.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final ChatService chatService;

  const ChatScreen({super.key, required this.chatService});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  String _loadingMessage = '';

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    var userMessage = Message(_controller.text, isUserMessage: true);
    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _loadingMessage = '';
    });

    _controller.clear();

    var responseMessage =
        await widget.chatService.sendMessage(userMessage.text);

    setState(() {
      _isLoading = false;
    });

    _displayResponseCharacterByCharacter(responseMessage.text);
  }

  void _displayResponseCharacterByCharacter(String text) async {
    for (int i = 0; i < text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1));
      setState(() {
        _loadingMessage += text[i];
      });
    }

    setState(() {
      _messages.add(Message(_loadingMessage, isUserMessage: false));
      _loadingMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Data Integration Assistant is made to help you assist on your CDI and IICS works 😊",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount:
                  _messages.length + (_loadingMessage.isNotEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                if (_loadingMessage.isNotEmpty && index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 14),
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 10),
                      child: Text(
                        _loadingMessage,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }

                var message = _messages[index];
                bool isUserMessage = message.isUserMessage;

                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: isUserMessage
                        ? BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(10),
                          )
                        : null,
                    child: MarkdownBody(
                      data: message.text,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.blue,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
