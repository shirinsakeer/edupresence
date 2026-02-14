import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatProvider with ChangeNotifier {
  final String _apiKey = "AIzaSyCdG3cI6gUvCWmVIehyI0WFpmjgV6so_h8";
  late GenerativeModel _model;
  late ChatSession _chat;

  List<Map<String, String>> _messages = [];
  List<Map<String, String>> get messages => _messages;

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  ChatProvider() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(
          "You are the EduPresence Assistant. You help teachers manage attendance and analyze data, and help students with their academic progress. Be concise, professional, and encouraging."),
    );
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
