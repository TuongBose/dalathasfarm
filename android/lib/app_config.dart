
import 'package:android/models/user.dart';

class AppConfig{
  static final String baseUrl = 'http://10.0.2.2:8080/api/v1';
  static bool isLogin = false;
  static User? currentUser;
  static String jwt = "";
}