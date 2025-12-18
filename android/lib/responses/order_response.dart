import 'package:android/responses/order_detail_response.dart';

class OrderResponse {
  final int id;
  final String address;
  final int userId;
  final String? note;
  final String? email;
  final double totalMoney;
  final String phoneNumber;
  final DateTime orderDate;
  final String fullName;
  final String status;
  final String paymentMethod;
  final String shippingMethod;
  final String platform;
  final DateTime shippingDate;
  final bool isActive;
  final String? vnpTxnRef;
  final String invoiceFile;
  final List<OrderDetailResponse> orderDetailResponses;

  OrderResponse({
    required this.id,
    required this.address,
    required this.userId,
    this.note,
    this.email,
    required this.totalMoney,
    required this.phoneNumber,
    required this.orderDate,
    required this.fullName,
    required this.status,
    required this.paymentMethod,
    required this.shippingMethod,
    required this.shippingDate,
    required this.isActive,
    required this.platform,
    this.vnpTxnRef,
    required this.invoiceFile,
    required this.orderDetailResponses,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      id: json['id'],
      address: json['address'],
      userId: json['userId'],
      note: json['note'],
      email: json['email'],
      totalMoney: (json['totalMoney'] as num).toDouble(),
      phoneNumber: json['phoneNumber'],
      orderDate: DateTime.parse(json['orderDate']),
      fullName: json['fullName'],
      status: json['status'],
      platform: json['platform'],
      paymentMethod: json['paymentMethod'],
      shippingMethod: json['shippingMethod'],
      shippingDate: DateTime.parse(json['shippingDate']),
      isActive: json['isActive'],
      vnpTxnRef: json['vnpTxnRef'],
      invoiceFile: json['invoiceFile'],
      orderDetailResponses:
          (json['orderDetailResponses'] as List)
              .map((item) => OrderDetailResponse.fromJson(item))
              .toList(),
    );
  }
}
