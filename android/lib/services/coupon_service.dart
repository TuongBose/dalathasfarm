import 'dart:convert';

import 'package:http/http.dart' as http;

import '../app_config.dart';

class CouponService {
  Future<double> calculateCouponValue(String couponCode, double totalAmount) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/coupons/calculate').replace(
        queryParameters: {
          'couponCode': couponCode.toString(),
          'totalAmount': totalAmount.toString(),
        },
      );
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final dynamic data = json['data']['result'];
        return data;
      } else {
        throw Exception('Failed to get discount value: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get discount value: $e');
    }
  }
}