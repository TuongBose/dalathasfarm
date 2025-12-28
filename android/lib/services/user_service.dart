import 'dart:convert';
import 'package:android/dtos/change_password_dto.dart';
import 'package:android/dtos/login_dto.dart';
import 'package:android/dtos/register_dto.dart';
import 'package:android/responses/login_response.dart';
import 'package:android/responses/user_response.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_config.dart';

class UserService {
  static const _userKey = 'user';
  static const _tokenKey = 'token';

  Future<void> createUser(RegisterDto registerDto) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/users/register');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(registerDto.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to register: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  Future<LoginResponse> login(LoginDto loginDto) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/users/login');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(loginDto.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final Map<String, dynamic> data = json['data'];
        return LoginResponse.fromJson(data);
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<UserResponse> getUserDetails(String token) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/users/details');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final Map<String, dynamic> data = json['data'];
        return UserResponse.fromJson(data);
      } else {
        throw Exception('Failed to get user details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get user details: $e');
    }
  }

  Future<void> uploadUserImage(int userId, XFile imageFile) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/api/v1/users/$userId/image');

      String? mimeType = lookupMimeType(imageFile.path);
      if (mimeType == null || !mimeType.startsWith('image/')) {
        throw Exception(
          'File không phải là hình ảnh hợp lệ. Vui lòng chọn file ảnh (jpg, png, v.v.).',
        );
      }
      print('Detected MIME type: $mimeType');

      var request = http.MultipartRequest('POST', url);
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('Upload successful: $responseBody');
      } else {
        throw Exception(
          'Upload failed: ${response.statusCode} - $responseBody',
        );
      }
    } catch (e) {
      throw Exception('Lỗi khi upload ảnh: $e');
    }
  }

  /// Lưu user
  static Future<void> saveUser({
    required UserResponse user,
    required String token,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final userJson = jsonEncode(user.toJson());

    if (rememberMe) {
      await prefs.setString(_userKey, userJson);
      await prefs.setString(_tokenKey, token);
    } else {
      AppConfig.currentUser = user;
      AppConfig.accessToken = token;
    }
  }

  static Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    final userJson = prefs.getString(_userKey);
    final token = prefs.getString(_tokenKey);

    if (userJson != null && token != null) {
      AppConfig.currentUser = UserResponse.fromJson(jsonDecode(userJson));
      AppConfig.accessToken = token;
      AppConfig.isLogin = true;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    AppConfig.currentUser = null;
    AppConfig.accessToken = '';
    AppConfig.isLogin = false;
  }

  Future<void> changePassword(ChangePasswordDto changePasswordDto) async {
    final userId = AppConfig.currentUser?.id;
    if (userId == null) {
      throw Exception('Không tìm thấy thông tin người dùng');
    }

    final url = Uri.parse('${AppConfig.baseUrl}/users/change-password/$userId');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${AppConfig.accessToken}',
      },
      body: jsonEncode(changePasswordDto.toJson()),
    );

    if (response.statusCode == 200) {
      return; // Thành công
    } else {
      final errorBody = jsonDecode(response.body);
      final message = errorBody['message'] ?? 'Đổi mật khẩu thất bại';
      throw Exception(message);
    }
  }
}
