import 'package:android/models/order.dart';
import 'package:android/models/product.dart';
import 'package:decimal/decimal.dart';

class OrderDetail {
    final int id;
    final Order order;
    final Product product;
    final Decimal price;
    final String quantity;
    final Decimal totalPrice;

    OrderDetail({
        required this.id,
        required this.order,
        required this.product,
        required this.price,
        required this.quantity,
        required this.totalPrice,
    });

    factory OrderDetail.fromJson(Map<String, dynamic> json) {
        return OrderDetail(
            id: json['id'],
            order: Order.fromJson(json['order']),
            product: Product.fromJson(json['product']),
            price: json['price'],
            quantity: json['quantity'],
            totalPrice: json['totalPrice'],
        );
    }
}