import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String apiKey = "sk-proj-iKom5YVN6pfsfinRvYGoT3BlbkFJveoiE3P6OpHi6dni2UCO";

  Future<String> getResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'You are a helpful assistant.'},
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        final errorResponse = jsonDecode(response.body);
        if (errorResponse['error']['code'] == 'insufficient_quota') {
          return 'Sorry, I cannot respond at the moment. Please try again later.';
        } else {
          throw Exception('API Error: ${errorResponse['error']['message']}');
        }
      }
    } catch (e) {
      return 'Sorry, an unexpected error occurred. Please try again later.';
    }
  }
}
