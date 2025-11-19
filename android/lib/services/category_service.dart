import 'dart:convert';

import 'package:android/app_config.dart';
import 'package:http/http.dart' as http;

import 'package:android/models/category.dart';

class CategoryService {
  Future<List<Category>> getAllCategory(int page, int limit) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/categories').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
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
        final List<dynamic> data = json['data'];
        return data.map((json)=>Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<Category> getCategoryById(int categoryId) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/categories/$categoryId');
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
        return Category.fromJson(data);
      } else {
        throw Exception('Failed to load category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching category: $e');
    }
  }
}