import 'package:android/screens/cart_screen.dart';
import 'package:android/screens/news_screen.dart';
import 'package:flutter/material.dart';
import 'package:android/app_config.dart';
import 'package:android/screens/home_screen.dart';
import 'package:android/screens/user_screen.dart';
import 'package:android/screens/account_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

class DefaultScreen extends StatelessWidget {
  final int initialIndex;

  const DefaultScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return MyDefaultScreen(initialIndex: initialIndex);
  }
}

class MyDefaultScreen extends StatefulWidget {
  final int initialIndex;

  const MyDefaultScreen({super.key, this.initialIndex = 0});

  @override
  State<MyDefaultScreen> createState() => MyDefaultScreenState();
}

class MyDefaultScreenState extends State<MyDefaultScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi_VN', null).then((_) {
      setState(() {});
    });

    // Đặt _selectedIndex ban đầu từ initialIndex
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const HomeScreen(),
      NewsScreen(),
      const Center(child: Text('Đơn hàng')),
      const Center(child: Text('Chatbot AI')),
      AppConfig.isLogin ? const UserScreen() : const AccountScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF4A7C59),
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Trang chủ'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: 'Tin tức',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'Chatbot AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Tài khoản',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orangeAccent[100],
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
      ),
    );
  }
}
