import 'dart:convert';

import 'package:android/app_config.dart';
import 'package:android/responses/feedback_response.dart';
import 'package:http/http.dart' as http;

import '../dtos/feed_back_dto.dart';

class FeedbackService {
  Future<List<FeedbackResponse>> getFeedbacksByProductId(int productId) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/feedbacks').replace(
        queryParameters: {
          'product_id': productId.toString(),
        },
      );
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =jsonDecode(response.body);
        final List<dynamic> data = json['data'];
        return data.map((json)=>FeedbackResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load feedbacks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching feedbacks: $e');
    }
  }

  Future<void> createFeedback(FeedbackDto feedbackDto) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/feedbacks');

      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
      };

      if (AppConfig.currentUser != null && AppConfig.accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${AppConfig.accessToken}';
      }

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(feedbackDto.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to submit feedback: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting feedback: $e');
    }
  }
}