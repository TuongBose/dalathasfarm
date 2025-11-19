import 'dart:convert';

import 'package:android/app_config.dart';
import 'package:android/models/product.dart';
import 'package:http/http.dart' as http;

class ProductService {
  Future<List<Product>> getAllProduct(
    String keyword,
    int categoryId,
    int occasionId,
    int page,
    int limit,
  ) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/products').replace(
        queryParameters: {
          'keyword':keyword.toString(),
          'categoryId':categoryId.toString(),
          'occasionId':occasionId.toString(),
          'page': page.toString(),
          'limit': limit.toString()
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
        final Map<String, dynamic> json =jsonDecode(response.body);
        final List<dynamic> data = json['data']['productResponses'];
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<Product> getProductById(int productId) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/products/$productId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final data = json['data'];
        return Product.fromJson(data);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }
}
