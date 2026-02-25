import 'package:flutter/material.dart';
import 'package:edupresence/services/groq_service.dart';

class ChatProvider with ChangeNotifier {
  List<Map<String, String>> _messages = [];
  List<Map<String, String>> get messages => _messages;

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  ChatProvider() {
    // Initializing with an empty list or a welcome message
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add({"role": "user", "text": text});
    _isTyping = true;
    notifyListeners();

    try {
      // Prepare history for Groq
      final List<Map<String, String>> history = _messages
          .map((m) => {
                'role': m['role'] == 'bot' ? 'assistant' : 'user',
                'text': m['text'] ?? '',
              })
          .toList();

      // Add system instruction if needed as the first message
      history.insert(0, {
        'role': 'system',
        'text':
            "You are the EduPresence Assistant. You help teachers manage attendance and analyze data, and help students with their academic progress. Be concise, professional, and encouraging."
      });

      final responseText = await GroqService.getChatResponse(history);
      _messages.add({"role": "bot", "text": responseText});
    } catch (e) {
      _messages.add({"role": "bot", "text": "Error: ${e.toString()}"});
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
