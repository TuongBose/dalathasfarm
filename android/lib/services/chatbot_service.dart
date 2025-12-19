import 'dart:convert';

import 'package:http/http.dart' as http;

import '../app_config.dart';

class ChatbotService {
  Future<String> askQuestion(String message) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/chatbot');

      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
      };

      final body = jsonEncode({
        'message': message,
      });

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =jsonDecode(response.body);
        return json['response'];
      }else{
        throw Exception('Failed to send message chatbot: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send message chatbot: $e');
    }
  }
}