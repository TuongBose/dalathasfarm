import 'dart:convert';

import 'package:android/dtos/payment_dto.dart';
import 'package:http/http.dart' as http;

import '../app_config.dart';

class PaymentService{
  Future<String> createPaymentUrl(PaymentDto paymentDto) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/payments/create-payment-url');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
          'User-Agent':'mobile',
        },
        body:jsonEncode(paymentDto.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =jsonDecode(response.body);
        final data = json['data'];
        return data;
      } else {
        throw Exception('Failed to create payment url: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error create payment url: $e');
    }
  }
}