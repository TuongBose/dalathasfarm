import 'package:android/responses/order_detail_response.dart';
import 'package:decimal/decimal.dart';

class OrderResponse{
  final int id;
  final String address;
  final int userId;
  final String note;
  final String email;
  final Decimal totalMoney;
  final String phoneNumber;
  final DateTime orderDate;
  final String fullName;
  final String status;
  final String paymentMethod;
  final String shippingMethod;
  final DateTime shippingDate;
  final bool isActive;
  final String coupon;
  final String vnpTxnRef;
  final String invoiceFile;
  final List<OrderDetailResponse> orderDetailResponses;

  OrderResponse({
    required this.id,
    required this.address,
    required this.userId,
    required this.note,
    required this.email,
    required this.totalMoney,
    required this.phoneNumber,
    required this.orderDate,
    required this.fullName,
    required this.status,
    required this.paymentMethod,
    required this.shippingMethod,
    required this.shippingDate,
    required this.isActive,
    required this.coupon,
    required this.vnpTxnRef,
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
      totalMoney: Decimal.parse(json['totalMoney'].toString()),
      phoneNumber: json['phoneNumber'],
      orderDate: DateTime.parse(json['orderDate']),
      fullName: json['fullName'],
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      shippingMethod: json['shippingMethod'],
      shippingDate: DateTime.parse(json['shippingDate']),
      isActive: json['isActive'],
      coupon: json['coupon'],
      vnpTxnRef: json['vnpTxnRef'],
      invoiceFile: json['invoiceFile'],
      orderDetailResponses: (json['orderDetailResponses'] as List)
          .map((item) => OrderDetailResponse.fromJson(item))
          .toList(),
    );
  }
}