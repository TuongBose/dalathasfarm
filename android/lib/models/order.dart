import 'package:decimal/decimal.dart';

class Order {
    final int id;
    final int userId;
    final String fullName;
    final String email;
    final String phoneNumber;
    final String address;
    final String note;
    final Decimal totalPrice;
    final String paymentMethod;

    Order({
        required this.id,
        required this.userId,
        required this.fullName,
        required this.email,
        required this.phoneNumber,
        required this.address,
        required this.note,
        required this.totalPrice,
        required this.paymentMethod,
    });

    factory Order.fromJson(Map<String, dynamic> json) {
        return Order(
            id: json['id'],
            userId: json['userId'],
            fullName: json['fullName'],
            email: json['email'],
            phoneNumber: json['phoneNumber'],
            address: json['address'],
            note: json['note'],
            totalPrice: json['totalPrice'],
            paymentMethod: json['paymentMethod'],
        );
    }
}