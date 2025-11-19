import 'package:android/screens/default_screen.dart';
import 'package:android/screens/login_screen.dart';
import 'package:android/screens/register_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/default',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/default':
            final int initialIndex = settings.arguments as int? ?? 0;
            return MaterialPageRoute(
              builder: (context) => DefaultScreen(initialIndex: initialIndex),
            );
          case '/dangnhap':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          case '/dangky':
            return MaterialPageRoute(builder: (context) => const RegisterScreen());
          default:
            return MaterialPageRoute(builder: (context) => const DefaultScreen());
        }
      },
    );
  }
}
