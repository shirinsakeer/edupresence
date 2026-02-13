import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatProvider with ChangeNotifier {
  final String _apiKey = "YOUR_GEMINI_API_KEY";
  late GenerativeModel _model;
  late ChatSession _chat;

  List<Map<String, String>> _messages = [];
  List<Map<String, String>> get messages => _messages;

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  ChatProvider() {
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
    _chat = _model.startChat();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add({"role": "user", "text": text});
    _isTyping = true;
    notifyListeners();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      _messages.add({"role": "bot", "text": response.text ?? "No response"});
    } catch (e) {
      _messages.add({"role": "bot", "text": "Error: ${e.toString()}"});
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _chat = _model.startChat();
    notifyListeners();
  }
}
