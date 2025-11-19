import 'package:android/dtos/register_dto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/user_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  bool _obscurePassword = true; // Trạng thái ẩn/hiện mật khẩu cho "Mật khẩu"
  bool _obscureConfirmPassword = true; // Trạng thái ẩn/hiện mật khẩu cho "Xác nhận mật khẩu"

  final UserService _userService = UserService();

  // Hàm kiểm tra tất cả các trường không được bỏ trống
  bool _validateAllFields() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập họ và tên')),
      );
      return false;
    }
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email')),
      );
      return false;
    }
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số điện thoại')),
      );
      return false;
    }
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mật khẩu')),
      );
      return false;
    }
    if (_confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng xác nhận mật khẩu')),
      );
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu xác nhận không khớp')),
      );
      return false;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày sinh')),
      );
      return false;
    }
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn giới tính')),
      );
      return false;
    }

    return true;
  }

  // Hàm chọn ngày sinh
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Hàm gửi mã OTP với kiểm tra backend
  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đồng ý với điều khoản dịch vụ')),
      );
      return;
    }

    // Kiểm tra tất cả các trường không được bỏ trống
    if (!_validateAllFields()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String phoneNumberRequest = _phoneController.text;
    String phoneNumber = _phoneController.text;
    if (!phoneNumber.startsWith('+84')) {
      phoneNumber = '+84${phoneNumber.substring(1)}'; // Định dạng số điện thoại quốc tế
    }

    // try {
    //   // Kiểm tra số điện thoại đã tồn tại chưa
    //   bool exists = await _userService.checkExistingPhoneNumber(phoneNumberRequest);
    //   if (exists) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Số điện thoại đã được đăng ký')),
    //     );
    //     return;
    //   }
    //
    //   await _auth.verifyPhoneNumber(
    //     phoneNumber: phoneNumber,
    //     verificationCompleted: (PhoneAuthCredential credential) async {
    //       await _auth.signInWithCredential(credential);
    //       _navigateToOTPScreen(credential.verificationId!);
    //     },
    //     verificationFailed: (FirebaseAuthException e) {
    //       setState(() {
    //         _isLoading = false;
    //       });
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text('Lỗi gửi OTP: ${e.message}')),
    //       );
    //     },
    //     codeSent: (String verificationId, int? resendToken) {
    //       setState(() {
    //         _isLoading = false;
    //       });
    //       _navigateToOTPScreen(verificationId);
    //     },
    //     codeAutoRetrievalTimeout: (String verificationId) {
    //       _navigateToOTPScreen(verificationId);
    //     },
    //   );
    // } catch (e) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Lỗi gửi OTP: $e')),
    //   );
    // }
  }

  // Chuyển hướng sang OTPScreen
  void _navigateToOTPScreen(String verificationId) {
    final registerDto = RegisterDto(
      fullName: _nameController.text,
      password: _passwordController.text,
      retypePassword: _confirmPasswordController.text,
      phoneNumber: _phoneController.text,
    );

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ConfirmOTPScreen(
    //       verificationId: verificationId,
    //       userDTO: userDTO,
    //       phoneNumber: _phoneController.text,
    //     ),
    //   ),
    // );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Quay lại',
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset('assets/images/logo-bear.png', height: 100),
              const SizedBox(height: 12),
              const Text(
                'Đăng Ký Thành Viên Star',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  IconWithText(icon: Icons.card_giftcard, label: 'Stars'),
                  IconWithText(icon: Icons.card_membership, label: 'Quà tặng'),
                  IconWithText(
                    icon: Icons.emoji_events,
                    label: 'Ưu đãi đặc biệt',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomTextField(
                icon: Icons.person,
                hint: 'Họ và tên',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              CustomTextField(
                icon: Icons.email,
                hint: 'Email',
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              CustomTextField(
                icon: Icons.phone,
                hint: 'Số điện thoại',
                controller: _phoneController,
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
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Giới tính (Tuỳ chọn)'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GenderRadio(
                    label: 'Nam',
                    value: 'Nam',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  GenderRadio(
                    label: 'Nữ',
                    value: 'Nữ',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  GenderRadio(
                    label: 'Chưa Xác Định',
                    value: 'Chưa Xác Định',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CustomTextField(
                icon: Icons.calendar_today,
                hint: _selectedDate == null
                    ? 'Ngày sinh (Tuỳ chọn)'
                    : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                isDate: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 18),
              CustomTextField(
                icon: Icons.lock,
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
              const SizedBox(height: 18),
              CustomTextField(
                icon: Icons.lock,
                hint: 'Xác nhận mật khẩu',
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                controller: _confirmPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu';
                  }
                  if (value != _passwordController.text) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
                onEyeTap: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (val) {
                      setState(() {
                        _agreeToTerms = val ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Bằng việc đăng ký tài khoản, tôi đồng ý với ',
                        children: [
                          TextSpan(
                            text: 'điều khoản dịch vụ',
                            style: TextStyle(color: Colors.blue),
                          ),
                          TextSpan(text: ' và '),
                          TextSpan(
                            text: 'chính sách bảo mật',
                            style: TextStyle(color: Colors.blue),
                          ),
                          TextSpan(text: ' của Galaxy Cinema.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _agreeToTerms ? _sendOTP : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: _agreeToTerms ? Colors.blue : Colors.grey,
                ),
                child: const Text('Hoàn tất'),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tài khoản đã được đăng ký!'),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Đăng nhập'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IconWithText extends StatelessWidget {
  final IconData icon;
  final String label;

  const IconWithText({required this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Icon(icon, size: 30), const SizedBox(height: 4), Text(label)],
    );
  }
}

class GenderRadio extends StatelessWidget {
  final String label;
  final String value;
  final String? groupValue;
  final ValueChanged<String?>? onChanged;

  const GenderRadio({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        Text(label),
      ],
    );
  }
}

class CustomTextField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool isPassword;
  final bool isDate;
  final bool obscureText; // Thêm obscureText để truyền từ ngoài vào
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final VoidCallback? onEyeTap; // Callback khi nhấn vào biểu tượng con mắt
  final String? Function(String?)? validator;

  const CustomTextField({
    required this.icon,
    required this.hint,
    this.isPassword = false,
    this.isDate = false,
    this.obscureText = true, // Mặc định ẩn mật khẩu
    this.controller,
    this.onTap,
    this.onEyeTap,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscureText : false, // Dùng obscureText từ tham số
      readOnly: isDate,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onEyeTap, // Gọi callback khi nhấn vào con mắt
        )
            : null,
      ),
      onTap: onTap,
    );
  }
}