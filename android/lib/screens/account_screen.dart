import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        title: const Text('Tài khoản',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 150,
            ),
            const SizedBox(height: 16),
            const Text(
              'Đăng Ký Thành Viên DalatHasfarm\nNhận Ngay Ưu Đãi!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Column(
                  children: [
                    Icon(Icons.stars, color: Colors.orange),
                    SizedBox(height: 4),
                    Text('Stars'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.card_giftcard, color: Colors.orange),
                    SizedBox(height: 4),
                    Text('Quà tặng'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.orange),
                    SizedBox(height: 4),
                    Text('Ưu đãi đặc biệt'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Đăng ký',style: TextStyle(color: Colors.white),),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    side: const BorderSide(color: Colors.orange),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(),
            Column(
              children: [
                infoRow("Gọi ĐƯỜNG DÂY NÓNG:", "1800 1143", isLink: true),
                infoRow("Email:", "hotro@dalathasfarm.com", isLink: true),
                infoRow("Thông Tin Công Ty", ""),
                infoRow("Điều Khoản Sử Dụng", ""),
                infoRow("Chính Sách Thanh Toán", ""),
                infoRow("Chính Sách Bảo Mật", ""),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String title, String value, {bool isLink = false}) {
    return ListTile(
      title: Text(title),
      subtitle: value.isNotEmpty
          ? Text(value, style: TextStyle(color: isLink ? Colors.blue : null))
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        if (title == "Gọi ĐƯỜNG DÂY NÓNG:" && value.isNotEmpty) {
          _makePhoneCall(value);
        } else if (title == "Email:" && value.isNotEmpty) {
          _launchEmail(value);
        }
        // Xử lý các trường hợp khác nếu cần
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Không thể thực hiện cuộc gọi $phoneNumber';
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Không thể mở ứng dụng email';
    }
  }
}