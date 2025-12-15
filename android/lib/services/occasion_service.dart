import 'dart:convert';

import 'package:android/app_config.dart';
import 'package:http/http.dart' as http;

import 'package:android/models/occasion.dart';

class OccasionService {
  Future<List<Occasion>> getAllOccasion(int page, int limit) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/occasions').replace(
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
        return data.map((json)=>Occasion.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load occasions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching occasions: $e');
    }
  }

  Future<List<Occasion>> getTodayOccasions() async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/occasions/active/today');
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
        return data.map((json)=>Occasion.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load occasions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching occasions: $e');
    }
  }

  Future<Occasion> getOccasionById(int occasionId) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/occasions/$occasionId');
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
        return Occasion.fromJson(data);
      } else {
        throw Exception('Failed to load occasion: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching occasion: $e');
    }
  }
}