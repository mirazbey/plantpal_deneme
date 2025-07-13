// lib/pages/chatbot_page.dart (YAPAY ZEKA BAĞLANMIŞ HALİ)

import 'package:flutter/material.dart';
import 'package:plantpal/services/gemini_service.dart'; // Gemini servisimizi import ediyoruz

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addMessage("Merhaba! Ben PlantPal. Bitki bakımıyla ilgili her konuda sana yardımcı olabilirim. Ne öğrenmek istersin?", false);
  }

  void _addMessage(String text, bool isUser, {bool isLoading = false}) {
    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUser: isUser));
      _isLoading = isLoading;
    });
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();

    _addMessage(text, true, isLoading: true); // Mesajı ekle ve yükleme animasyonunu başlat

    // Gemini servisinden cevap al
    final response = await GeminiService.getChatbotResponse(_messages);

    // Gemini'den gelen cevabı ekle ve yükleme animasyonunu durdur
    _addMessage(response ?? "Üzgünüm, bir sorun oluştu.", false, isLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Botanik Uzmanı'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator(),
            ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.05),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Bir mesaj yazın...',
                ),
                onSubmitted: _isLoading ? null : _handleSubmitted, // Yüklenirken gönderimi engelle
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _isLoading ? null : () => _handleSubmitted(_textController.text), // Yüklenirken butonu pasif yap
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final bubbleAlignment = message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = message.isUser ? Theme.of(context).primaryColor : Theme.of(context).cardColor;
    final textColor = message.isUser
        ? Colors.white
        : Theme.of(context).textTheme.bodyMedium?.color;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: bubbleAlignment,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.text,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}