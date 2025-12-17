import 'package:android/dtos/cart_item_dto.dart';
import 'package:decimal/decimal.dart';

class OrderDto {
  final int userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String note;
  final Decimal totalPrice;
  final String paymentMethod;
  final String shippingMethod;
  final DateTime shippingDate;
  final String status;
  final String platform;
  String? vnpTxnRef;
  String? couponCode;
  final List<CartItemDto> cartItems;

  OrderDto({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.note,
    required this.totalPrice,
    required this.paymentMethod,
    required this.shippingMethod,
    required this.shippingDate,
    required this.status,
    required this.platform,
    this.vnpTxnRef,
    this.couponCode,
    required this.cartItems,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'note': note,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'shippingMethod': shippingMethod,
      'shippingDate': shippingDate.toIso8601String(),
      'status': status,
      'platform': platform,
      'vnpTxnRef': vnpTxnRef,
      'couponCode': couponCode,
      'cartItems': cartItems.map((item) => item.toJson()).toList(),
    };
  }
}
