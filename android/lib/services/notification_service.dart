import 'dart:convert';

import 'package:http/http.dart' as http;

import '../app_config.dart';
import '../responses/notification_response.dart';

class NotificationService {
  final String _baseUrl = '${AppConfig.baseUrl}/notifications';

  Future<List<NotificationResponse>> getNotificationsByUserId() async {
    final url = Uri.parse(_baseUrl);
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${AppConfig.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> data = json['data'];
      return data.map((e) => NotificationResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<List<NotificationResponse>> getUnreadNotifications() async {
    final url = Uri.parse('$_baseUrl/unread');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${AppConfig.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> data = json['data'];
      return data.map((e) => NotificationResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load unread notifications');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final url = Uri.parse('$_baseUrl/mark-as-read/$notificationId');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${AppConfig.accessToken}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark as read');
    }
  }

  Future<void> markAllAsRead() async {
    final url = Uri.parse('$_baseUrl/mark-all-as-read');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${AppConfig.accessToken}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark all as read');
    }
  }
}