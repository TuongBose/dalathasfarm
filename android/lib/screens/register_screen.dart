// import 'package:android/dtos/register_dto.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../services/user_service.dart';
//
// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});
//
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   DateTime? _selectedDate;
//   String? _selectedGender;
//   bool _agreeToTerms = false;
//   bool _isLoading = false;
//   bool _obscurePassword = true; // Trạng thái ẩn/hiện mật khẩu cho "Mật khẩu"
//   bool _obscureConfirmPassword = true; // Trạng thái ẩn/hiện mật khẩu cho "Xác nhận mật khẩu"
//
//   final UserService _userService = UserService();
//
//   // Hàm kiểm tra tất cả các trường không được bỏ trống
//   bool _validateAllFields() {
//     if (_nameController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Vui lòng nhập họ và tên')),
//       );
//       return false;
//     }
//     if (_emailController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Vui lòng nhập email')),
//       );
//       return false;
//     }
//     if (_phoneController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Vui lòng nhập số điện thoại')),
//       );
//       return false;
//     }
//     if (_passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Vui lòng nhập mật khẩu')),
//       );
//       return false;
//     }
//     if (_confirmPasswordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Vui lòng xác nhận mật khẩu')),
//       );
//       return false;
//     }
//     if (_passwordController.text != _confirmPasswordController.text) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Mật khẩu xác nhận không khớp')),
//       );
//       return false;
//     }
//     if (_selectedDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Vui lòng chọn ngày sinh')),
//       );
//       return false;
//     }
//     if (_selectedGender == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Vui lòng chọn giới tính')),
//       );
//       return false;
//     }
//
//     return true;
//   }
//
//   // Hàm chọn ngày sinh
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }
//
//   // Hàm gửi mã OTP với kiểm tra backend
//   Future<void> _sendOTP() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (!_agreeToTerms) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Vui lòng đồng ý với điều khoản dịch vụ')),
//       );
//       return;
//     }
//
//     // Kiểm tra tất cả các trường không được bỏ trống
//     if (!_validateAllFields()) {
//       setState(() {
//         _isLoading = false;
//       });
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     String phoneNumberRequest = _phoneController.text;
//     String phoneNumber = _phoneController.text;
//     if (!phoneNumber.startsWith('+84')) {
//       phoneNumber = '+84${phoneNumber.substring(1)}'; // Định dạng số điện thoại quốc tế
//     }
//
//     // try {
//     //   // Kiểm tra số điện thoại đã tồn tại chưa
//     //   bool exists = await _userService.checkExistingPhoneNumber(phoneNumberRequest);
//     //   if (exists) {
//     //     setState(() {
//     //       _isLoading = false;
//     //     });
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       const SnackBar(content: Text('Số điện thoại đã được đăng ký')),
//     //     );
//     //     return;
//     //   }
//     //
//     //   await _auth.verifyPhoneNumber(
//     //     phoneNumber: phoneNumber,
//     //     verificationCompleted: (PhoneAuthCredential credential) async {
//     //       await _auth.signInWithCredential(credential);
//     //       _navigateToOTPScreen(credential.verificationId!);
//     //     },
//     //     verificationFailed: (FirebaseAuthException e) {
//     //       setState(() {
//     //         _isLoading = false;
//     //       });
//     //       ScaffoldMessenger.of(context).showSnackBar(
//     //         SnackBar(content: Text('Lỗi gửi OTP: ${e.message}')),
//     //       );
//     //     },
//     //     codeSent: (String verificationId, int? resendToken) {
//     //       setState(() {
//     //         _isLoading = false;
//     //       });
//     //       _navigateToOTPScreen(verificationId);
//     //     },
//     //     codeAutoRetrievalTimeout: (String verificationId) {
//     //       _navigateToOTPScreen(verificationId);
//     //     },
//     //   );
//     // } catch (e) {
//     //   setState(() {
//     //     _isLoading = false;
//     //   });
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     SnackBar(content: Text('Lỗi gửi OTP: $e')),
//     //   );
//     // }
//   }
//
//   // Chuyển hướng sang OTPScreen
//   void _navigateToOTPScreen(String verificationId) {
//     final registerDto = RegisterDto(
//       fullName: _nameController.text,
//       password: _passwordController.text,
//       retypePassword: _confirmPasswordController.text,
//       phoneNumber: _phoneController.text,
//     );
//
//     // Navigator.push(
//     //   context,
//     //   MaterialPageRoute(
//     //     builder: (context) => ConfirmOTPScreen(
//     //       verificationId: verificationId,
//     //       userDTO: userDTO,
//     //       phoneNumber: _phoneController.text,
//     //     ),
//     //   ),
//     // );
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.blue),
//           onPressed: () => Navigator.of(context).pop(),
//           tooltip: 'Quay lại',
//         ),
//         elevation: 0,
//         backgroundColor: Colors.white,
//       ),
//       backgroundColor: Colors.white,
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               Image.asset('assets/images/logo-bear.png', height: 100),
//               const SizedBox(height: 12),
//               const Text(
//                 'Đăng Ký Thành Viên Star',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: const [
//                   IconWithText(icon: Icons.card_giftcard, label: 'Stars'),
//                   IconWithText(icon: Icons.card_membership, label: 'Quà tặng'),
//                   IconWithText(
//                     icon: Icons.emoji_events,
//                     label: 'Ưu đãi đặc biệt',
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               CustomTextField(
//                 icon: Icons.person,
//                 hint: 'Họ và tên',
//                 controller: _nameController,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Vui lòng nhập họ và tên';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 18),
//               CustomTextField(
//                 icon: Icons.email,
//                 hint: 'Email',
//                 controller: _emailController,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Vui lòng nhập email';
//                   }
//                   if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                     return 'Email không hợp lệ';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 18),
//               CustomTextField(
//                 icon: Icons.phone,
//                 hint: 'Số điện thoại',
//                 controller: _phoneController,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Vui lòng nhập số điện thoại';
//                   }
//                   if (!RegExp(r'^\d{10}$').hasMatch(value)) {
//                     return 'Số điện thoại phải có 10 chữ số';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 10),
//               const Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text('Giới tính (Tuỳ chọn)'),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   GenderRadio(
//                     label: 'Nam',
//                     value: 'Nam',
//                     groupValue: _selectedGender,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedGender = value;
//                       });
//                     },
//                   ),
//                   GenderRadio(
//                     label: 'Nữ',
//                     value: 'Nữ',
//                     groupValue: _selectedGender,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedGender = value;
//                       });
//                     },
//                   ),
//                   GenderRadio(
//                     label: 'Chưa Xác Định',
//                     value: 'Chưa Xác Định',
//                     groupValue: _selectedGender,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedGender = value;
//                       });
//                     },
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               CustomTextField(
//                 icon: Icons.calendar_today,
//                 hint: _selectedDate == null
//                     ? 'Ngày sinh (Tuỳ chọn)'
//                     : DateFormat('dd/MM/yyyy').format(_selectedDate!),
//                 isDate: true,
//                 onTap: () => _selectDate(context),
//               ),
//               const SizedBox(height: 18),
//               CustomTextField(
//                 icon: Icons.lock,
//                 hint: 'Mật khẩu',
//                 isPassword: true,
//                 obscureText: _obscurePassword,
//                 controller: _passwordController,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Vui lòng nhập mật khẩu';
//                   }
//                   if (value.length < 6) {
//                     return 'Mật khẩu phải có ít nhất 6 ký tự';
//                   }
//                   return null;
//                 },
//                 onEyeTap: () {
//                   setState(() {
//                     _obscurePassword = !_obscurePassword;
//                   });
//                 },
//               ),
//               const SizedBox(height: 18),
//               CustomTextField(
//                 icon: Icons.lock,
//                 hint: 'Xác nhận mật khẩu',
//                 isPassword: true,
//                 obscureText: _obscureConfirmPassword,
//                 controller: _confirmPasswordController,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Vui lòng xác nhận mật khẩu';
//                   }
//                   if (value != _passwordController.text) {
//                     return 'Mật khẩu xác nhận không khớp';
//                   }
//                   return null;
//                 },
//                 onEyeTap: () {
//                   setState(() {
//                     _obscureConfirmPassword = !_obscureConfirmPassword;
//                   });
//                 },
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   Checkbox(
//                     value: _agreeToTerms,
//                     onChanged: (val) {
//                       setState(() {
//                         _agreeToTerms = val ?? false;
//                       });
//                     },
//                   ),
//                   const Expanded(
//                     child: Text.rich(
//                       TextSpan(
//                         text: 'Bằng việc đăng ký tài khoản, tôi đồng ý với ',
//                         children: [
//                           TextSpan(
//                             text: 'điều khoản dịch vụ',
//                             style: TextStyle(color: Colors.blue),
//                           ),
//                           TextSpan(text: ' và '),
//                           TextSpan(
//                             text: 'chính sách bảo mật',
//                             style: TextStyle(color: Colors.blue),
//                           ),
//                           TextSpan(text: ' của Galaxy Cinema.'),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               ElevatedButton(
//                 onPressed: _agreeToTerms ? _sendOTP : null,
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size.fromHeight(50),
//                   backgroundColor: _agreeToTerms ? Colors.blue : Colors.grey,
//                 ),
//                 child: const Text('Hoàn tất'),
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text('Tài khoản đã được đăng ký!'),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: const Text('Đăng nhập'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class IconWithText extends StatelessWidget {
//   final IconData icon;
//   final String label;
//
//   const IconWithText({required this.icon, required this.label, super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [Icon(icon, size: 30), const SizedBox(height: 4), Text(label)],
//     );
//   }
// }
//
// class GenderRadio extends StatelessWidget {
//   final String label;
//   final String value;
//   final String? groupValue;
//   final ValueChanged<String?>? onChanged;
//
//   const GenderRadio({
//     required this.label,
//     required this.value,
//     required this.groupValue,
//     required this.onChanged,
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Radio<String>(
//           value: value,
//           groupValue: groupValue,
//           onChanged: onChanged,
//         ),
//         Text(label),
//       ],
//     );
//   }
// }
//
// class CustomTextField extends StatelessWidget {
//   final IconData icon;
//   final String hint;
//   final bool isPassword;
//   final bool isDate;
//   final bool obscureText; // Thêm obscureText để truyền từ ngoài vào
//   final TextEditingController? controller;
//   final VoidCallback? onTap;
//   final VoidCallback? onEyeTap; // Callback khi nhấn vào biểu tượng con mắt
//   final String? Function(String?)? validator;
//
//   const CustomTextField({
//     required this.icon,
//     required this.hint,
//     this.isPassword = false,
//     this.isDate = false,
//     this.obscureText = true, // Mặc định ẩn mật khẩu
//     this.controller,
//     this.onTap,
//     this.onEyeTap,
//     this.validator,
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       obscureText: isPassword ? obscureText : false, // Dùng obscureText từ tham số
//       readOnly: isDate,
//       decoration: InputDecoration(
//         prefixIcon: Icon(icon),
//         hintText: hint,
//         border: const OutlineInputBorder(),
//         contentPadding: const EdgeInsets.symmetric(vertical: 10),
//         suffixIcon: isPassword
//             ? IconButton(
//           icon: Icon(
//             obscureText ? Icons.visibility_off : Icons.visibility,
//             color: Colors.grey,
//           ),
//           onPressed: onEyeTap, // Gọi callback khi nhấn vào con mắt
//         )
//             : null,
//       ),
//       onTap: onTap,
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../dtos/register_dto.dart';
import '../services/user_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final UserService _userService = UserService();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final fullName = '${_lastNameController.text
          .trim()} ${_firstNameController.text.trim()}'.trim();
      final phoneNumber = _phoneController.text.trim();
      final password = _passwordController.text;

      // 1. Đăng ký
      final registerDto = RegisterDto(
        fullName: fullName,
        phoneNumber: phoneNumber,
        password: password,
        retypePassword: _confirmPasswordController.text,
      );

      await _userService.createUser(registerDto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký tài khoản thành công! Chào mừng bạn!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/default',
              (route) => false,
          arguments: 4,
        );
      }
    }catch (e) {
      if (mounted) {
        String errorMsg = e.toString().replaceFirst('Exception: ', '');
        if (errorMsg.contains('Failed to register')) {
          errorMsg = 'Số điện thoại đã được sử dụng';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE8F5E9),
              const Color(0xFFC8E6C9),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Register Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Đăng ký',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A7C59),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // First Name
                          TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              hintText: 'Tên *',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tên';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Last Name
                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              hintText: 'Họ *',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập họ';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // SDT
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              hintText: 'Số điện thoại *',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
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
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Mật khẩu *',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              if (value.length < 6) {
                                return 'Mật khẩu phải có ít nhất 6 ký tự';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              hintText: 'Nhập lại mật khẩu *',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng xác nhận mật khẩu';
                              }
                              if (value != _passwordController.text) {
                                return 'Mật khẩu không khớp';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A7C59),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                                  : const Text(
                                'Đăng ký',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Continue with
                          const Center(
                            child: Text(
                              'Tiếp tục với',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Social Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SocialButton(icon: Icons.g_mobiledata, onTap: () {}),
                              const SizedBox(width: 24),
                              _SocialButton(icon: Icons.apple, onTap: () {}),
                              const SizedBox(width: 24),
                              _SocialButton(icon: Icons.facebook, onTap: () {}),
                            ],
                          ),
                          const SizedBox(height: 24),

                          const Center(
                            child: Text(
                              'HOẶC',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Guest Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/default',
                                      (route) => false,
                                  arguments: 4,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF4A7C59),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text(
                                'Tiếp tục với tư cách khách',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4A7C59),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Login link
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Đã có ',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const Text(
                                  'tài khoản',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const Text(' ? '),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Đăng nhập',
                                    style: TextStyle(
                                      color: Color(0xFF4A7C59),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Icon(
          icon,
          size: 32,
          color: Colors.black87,
        ),
      ),
    );
  }
}