import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_config.dart';
import '../responses/notification_response.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationResponse> _notifications = [];
  bool _isLoading = true;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    if (AppConfig.isLogin) {
      _loadNotifications();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await _notificationService.getNotificationsByUserId();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải thông báo: $e')),
      );
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await _notificationService.markAsRead(id);
      _loadNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi đánh dấu đã đọc')),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    if (_notifications.where((n) => !n.is_read).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có thông báo chưa đọc')),
      );
      return;
    }

    try {
      await _notificationService.markAllAsRead();
      _loadNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đánh dấu tất cả là đã đọc')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi đánh dấu tất cả')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.isLogin) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(title: const Text('Thông báo')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 24),
                const Text('Bạn chưa đăng nhập', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A7C59))),
                const SizedBox(height: 12),
                const Text('Đăng nhập để xem thông báo về đơn hàng và ưu đãi', textAlign: TextAlign.center),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('Đăng nhập ngay', style: TextStyle(color: Color(0xFF4A7C59)),),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          if (_notifications.any((n) => !n.is_read))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Đánh dấu tất cả', style: TextStyle(color: Color(0xFF4A7C59))),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(child: Text('Không có thông báo nào'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length > 10 ? 10 : _notifications.length,
        itemBuilder: (context, index) {
          final noti = _notifications[index];
          return Card(
            color: noti.is_read ? Colors.white : Colors.green[50],
            child: ListTile(
              title: Text(noti.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(noti.content),
                  Text(DateFormat('dd/MM/yyyy HH:mm').format(noti.createdAt), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
              trailing: noti.is_read
                  ? const Text('Đã đọc', style: TextStyle(color: Colors.grey))
                  : TextButton(
                onPressed: () => _markAsRead(noti.notification_id),
                child: const Text('Đánh dấu đọc'),
              ),
            ),
          );
        },
      ),
    );
  }
}