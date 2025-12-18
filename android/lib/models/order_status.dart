import 'package:flutter/material.dart';

class OrderStatus {
  static const String all = 'Tất cả';
  static const String pending = 'Chưa xử lý';
  static const String processing = 'Đang xử lý';
  static const String shipping = 'Đang vận chuyển';
  static const String delivered = 'Giao hàng thành công';
  static const String cancelled = 'Đã hủy';

  static String getDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pending;
      case 'processing':
        return processing;
      case 'shipping':
        return shipping;
      case 'delivered':
        return delivered;
      case 'cancelled':
        return cancelled;
      default:
        return 'Không xác định';
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipping':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}