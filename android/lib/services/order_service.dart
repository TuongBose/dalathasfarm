import 'dart:convert';

import 'package:http/http.dart' as http;

import '../app_config.dart';
import '../dtos/order_dto.dart';
import '../responses/order_response.dart';

class OrderService{
  Future<void> placeOrder(OrderDto orderDto) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/orders');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(orderDto.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to place order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  Future<List<OrderResponse>> getOrderById(int orderId) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/orders/$orderId');
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
        return data.map((json)=>OrderResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load order detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching order detail: $e');
    }
  }

  Future<void> updateOrderStatus(String vnp_TxnRef,String status) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/orders/status').replace(
        queryParameters: {
          'status': status.toString(),
          'vnpTxnRef': vnp_TxnRef.toString(),
        },
      );
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update status order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update status order: $e');
    }
  }

  Future<List<OrderResponse>> getOrdersByUserId(int userId) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/orders/user/$userId');
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
        return data.map((json)=>OrderResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load order detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching order detail: $e');
    }
  }
}