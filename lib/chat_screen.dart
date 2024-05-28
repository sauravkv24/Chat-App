import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_service.dart';

class ChatScreenUi extends StatefulWidget {
  final String agentName;
  final String agentPersona;

  const ChatScreenUi({
    super.key,
    required this.agentName,
    required this.agentPersona,
  });

  @override
  State<ChatScreenUi> createState() => _ChatScreenUiState();
}

class _ChatScreenUiState extends State<ChatScreenUi> {
  List<Map<String, dynamic>> _messages = [];
  TextEditingController _controller = TextEditingController();
  late SharedPreferences _sharedPreferences;
  late ChatService _chatService;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    _scrollController = ScrollController();
    _loadMessages();
    _scrollToBottom();
  }

  Future<void> _loadMessages() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    List<String>? messageData = _sharedPreferences.getStringList('${widget.agentName}_messages');
    if (messageData != null) {
      setState(() {
        _messages = messageData.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
      });
      Future.delayed(const Duration(milliseconds: 100), () => _scrollToBottom());
    }
  }

  Future<void> sendMessage(String text, bool isMe) async {
    Map<String, dynamic> message = {'text': text, 'isMe': isMe};
    setState(() {
      _messages.add(message);
    });

    List<String> messageData = _messages.map((e) => jsonEncode(e)).toList();
    await _sharedPreferences.setStringList('${widget.agentName}_messages', messageData);

    if (isMe) {
      String response = await _chatService.getResponse('${widget.agentPersona}: $text');
      sendMessage(response.trim(), false);
    }
    _scrollToBottom();
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.agentName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatTab(
                  isMe: _messages[index]['isMe'],
                  text: _messages[index]['text'],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    String text = _controller.text;
                    _controller.clear();
                    await sendMessage(text, true);
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




class ChatTab extends StatelessWidget {
  final bool isMe;
  final String text;

  const ChatTab({super.key, required this.isMe, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isMe ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.circular(8)
        ),
        child: Text(text),
      ),
    );
  }
}
