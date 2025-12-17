import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String _tokenKey = 'access_token';
  static String? _memoryToken;

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return _memoryToken ?? prefs.getString(_tokenKey);
  }

  static Future<void> setToken(String token, {
    bool rememberMe = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (rememberMe) {
      await prefs.setString(_tokenKey, token);
      _memoryToken = null;
    } else {
      _memoryToken = token;
    }
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _memoryToken = null;
  }

  static Future<int> getUserId() async {
    final token = await getToken();
    if (token == null) return 0;

    final decoded = JwtDecoder.decode(token);

    if (!decoded.containsKey('userId')) return 0;

    return int.tryParse(decoded['userId'].toString()) ?? 0;
  }

  static Future<bool> isTokenExpired() async {
    final token = await getToken();
    if (token == null) return true;

    return JwtDecoder.isExpired(token);
  }
}
