import 'package:decimal/decimal.dart';

class OrderDetailDto {
  final int orderId;
  final int productId;
  final int quantity;
  final Decimal price;
  final Decimal totalPrice;

  OrderDetailDto({
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'productId': productId,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
    };
  }
}
