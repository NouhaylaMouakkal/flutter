import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late GenerativeModel _model;
  late var _chat;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  void _initializeModel() {
    const apiKey = 'AIzaSyCO1FrXpKcd5-ZWW_EJ9D5sLHfo67Djvz8';

    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
      generationConfig: GenerationConfig(maxOutputTokens: 100),
    );
    _chat = _model.startChat();
  }

  void _sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "message": message});
    });

    try {
      final content = Content.text(message);
      final response = await _chat.sendMessage(content);

      setState(() {
        _messages.add({"sender": "bot", "message": response.text});
      });
    } catch (e) {
      setState(() {
        _messages.add({"sender": "error", "message": e.toString()});
      });
    }
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    bool isUser = msg['sender'] == 'user';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            const CircleAvatar(
              backgroundColor: Colors.purple,
              child: Icon(
                Icons.android,
                color: Colors.white,
              ),
            ),
          if (!isUser) const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUser ? Colors.grey.shade300 : Colors.purple.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                msg['message'],
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (isUser)
            const SizedBox(width: 10),
          if (isUser)
            const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatBot'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Enter your message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onSubmitted: (text) {
                      _sendMessage(text);
                      _controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _sendMessage(_controller.text);
                    _controller.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}