import 'dart:convert';
import 'package:android/dtos/login_dto.dart';
import 'package:android/dtos/register_dto.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import '../app_config.dart';
import '../models/user.dart';

class UserService {
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

      if (response.statusCode == 200) {
        return;
      } else {
        // Đọc thông báo lỗi từ body của response
        final errorData = jsonDecode(response.body);
        String errorMessage;

        if (errorData is List) {
          // Nếu body trả về là danh sách lỗi (như ["So dien thoai khong duoc bo trong"])
          errorMessage = errorData.isNotEmpty ? errorData[0] : 'Unknown error';
        } else if (errorData is Map && errorData.containsKey('message')) {
          // Nếu body trả về là JSON với trường "message"
          errorMessage = errorData['message'];
        } else {
          errorMessage = 'Failed to create user: ${response.statusCode}';
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      throw ('Tạo tài khoản không thành công: $e');
    }
  }

  Future<User> login(LoginDto loginDto) async {
    String error = '';
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/users/login');
      final response = await http.post(
        // Sửa thành http.post
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(loginDto.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Kiểm tra dữ liệu trả về có phải là một đối tượng JSON không
        if (data is Map<String, dynamic>) {
          return User.fromJson(data); // Chuyển đổi trực tiếp thành User
        } else {
          throw Exception(
            'Invalid response format: Expected a single user object',
          );
        }
      } else {
        error = response.body;
        throw Exception('');
      }
    } catch (e) {
      throw error;
    }
  }

  Future<void> uploadUserImage(int userId, XFile imageFile) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/users/$userId/image');

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

  Future<bool> checkExistingPhoneNumber(String phoneNumber) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/users/checkexistphonenumber/$phoneNumber');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'exists';
      } else {
        throw Exception('Lỗi kiểm tra số điện thoại: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi kiểm tra số điện thoại: $e');
    }
  }

  Future<bool> checkDoesNotExistingPhoneNumber(String phoneNumber) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/users/checkdoesnotexistphonenumber/$phoneNumber');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'exists';
      } else {
        throw Exception('Lỗi kiểm tra số điện thoại: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi kiểm tra số điện thoại: $e');
    }
  }

  Future<void> resetPassword(LoginDto loginDto) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/users/resetpassword');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(loginDto.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Lỗi reset mật khẩu: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi khi reset mật khẩu: $e');
    }
  }
}
