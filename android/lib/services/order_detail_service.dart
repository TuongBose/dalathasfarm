import 'dart:convert';

import 'package:android/responses/order_detail_response.dart';
import 'package:http/http.dart' as http;

import '../app_config.dart';

class OrderDetailService{
  Future<List<OrderDetailResponse>> getOrderDetailsByOrderId(int orderId) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/order-details/order/$orderId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =jsonDecode(response.body);
        final List<dynamic> data = json['data'];
        return data.map((json)=>OrderDetailResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load order detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching order detail: $e');
    }
  }
}