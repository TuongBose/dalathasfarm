class NotificationResponse {
  final int notification_id;
  final int user_id;
  final String title;
  final String content;
  final String type;
  final bool is_read;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationResponse({
    required this.notification_id,
    required this.user_id,
    required this.title,
    required this.content,
    required this.type,
    required this.is_read,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      notification_id: json['notification_id'],
      user_id: json['user_id'],
      title: json['title'],
      content: json['content'],
      type: json['type'],
      is_read: json['is_read'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
