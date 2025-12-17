import 'package:android/responses/user_response.dart';

class AppConfig{
  static final String baseUrl = 'http://10.0.2.2:8080/api/v1';
  static bool isLogin = false;
  static UserResponse? currentUser;
  static String accessToken = "";
}