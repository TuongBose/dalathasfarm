import 'package:android/models/product.dart';
import 'package:decimal/decimal.dart';

class OrderDetailResponse{

  final int orderId;
  final Product productResponse;
  final int quantity;
  final Decimal price;
  final Decimal totalMoney;

  OrderDetailResponse({
    required this.orderId,
    required this.productResponse,
    required this.quantity,
    required this.price,
    required this.totalMoney,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      orderId: json['orderId'],
      productResponse: Product.fromJson(json['productResponse']),
      quantity: json['quantity'],
      price: Decimal.parse(json['price'].toString()),
      totalMoney: Decimal.parse(json['totalMoney'].toString()),
    );
  }
}