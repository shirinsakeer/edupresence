import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  // Note: For a production app, this should be in an environment variable or fetched from a secure config.
  static const String _apiKey = '';

  static Future<String> getChatResponse(
      List<Map<String, String>> messages) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile', // Groq model
          'messages': messages
              .map((m) => {
                    'role': m['role'] == 'bot' ? 'assistant' : 'user',
                    'content': m['text'] ?? m['content'] ?? '',
                  })
              .toList(),
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
