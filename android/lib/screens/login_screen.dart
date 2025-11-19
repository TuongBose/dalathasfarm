import 'package:android/app_config.dart';
import 'package:android/dtos/login_dto.dart';
import 'package:android/services/user_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isButtonEnabled = false;

  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _phoneNumberController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled =
          _phoneNumberController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final loginDto = LoginDto(
        phoneNumber: _phoneNumberController.text,
        password: _passwordController.text,
      );

      final user = await _userService.login(loginDto);

      if (mounted) {
        AppConfig.isLogin = true;
        AppConfig.currentUser = user;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đăng nhập thành công!')));

        // Điều hướng đến DefaultScreen và chọn tab "Tài khoản" (index 3)
        Navigator.pushReplacementNamed(context, '/default', arguments: 3);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi đăng nhập: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Quay lại',
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                // Thêm SingleChildScrollView
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Image.asset('assets/images/login_banner.png', height: 150),
                    const SizedBox(height: 12),
                    const Text(
                      'Đăng Nhập Với Tài Khoản Của Bạn',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              icon: Icons.person_outline,
                              hint: 'Số điện thoại',
                              controller: _phoneNumberController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập số điện thoại';
                                }
                                if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                                  return 'Số điện thoại phải có 10 chữ số';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              icon: Icons.lock_outline,
                              hint: 'Mật khẩu',
                              isPassword: true,
                              obscureText: _obscurePassword,
                              controller: _passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu';
                                }
                                if (value.length < 6) {
                                  return 'Mật khẩu phải có ít nhất 6 ký tự';
                                }
                                return null;
                              },
                              onEyeTap: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            // Align(
                            //   alignment: Alignment.centerRight,
                            //   child: TextButton(
                            //     onPressed: () {
                            //       Navigator.push(
                            //         context,
                            //         MaterialPageRoute(
                            //           builder:
                            //               (context) =>
                            //                   const QuenMatKhauScreen(),
                            //         ),
                            //       );
                            //     },
                            //     child: const Text(
                            //       'Quên mật khẩu?',
                            //       style: TextStyle(color: Colors.blue),
                            //     ),
                            //   ),
                            // ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed:
                                  _isButtonEnabled && !_isLoading
                                      ? _login
                                      : null,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                backgroundColor:
                                    _isButtonEnabled
                                        ? Colors.blue
                                        : Colors.grey[300],
                              ),
                              child: const Text('Đăng nhập'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 220,),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Người dùng mới!'),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/dangky');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text('Đăng ký'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool isPassword;
  final bool obscureText;
  final TextEditingController? controller;
  final VoidCallback? onEyeTap;
  final String? Function(String?)? validator;

  const CustomTextField({
    required this.icon,
    required this.hint,
    this.isPassword = false,
    this.obscureText = true,
    this.controller,
    this.onEyeTap,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: onEyeTap,
                )
                : null,
      ),
    );
  }
}
