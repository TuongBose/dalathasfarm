import 'package:android/responses/user_response.dart';

class FeedbackResponse {
  final int id;
  final UserResponse userResponse;
  final String content;
  final int star;
  final int productId;
  final DateTime createdAt;
  final double average;

  FeedbackResponse({
    required this.id,
    required this.userResponse,
    required this.content,
    required this.star,
    required this.productId,
    required this.createdAt,
    required this.average,
  });

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackResponse(
      id: json['id'],
      userResponse: UserResponse.fromJson(json['userResponse']),
      content: json['content'],
      star: json['star'],
      productId: json['productId'],
      createdAt: DateTime.parse(json['createdAt']),
      average: (json['average'] as num).toDouble(),
    );
  }
}