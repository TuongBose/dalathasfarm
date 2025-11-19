import 'dart:io';

import 'package:android/app_config.dart';
import 'package:android/models/user.dart';
import 'package:android/services/user_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  User? _user;
  int? _totalSpending;
  bool _isLoading = true;
  bool _isUploading = false;
  String? _errorMessage;
  int _selectedTab = 0;
  XFile? _selectedImage;
  String _cacheKey = DateTime.now().millisecondsSinceEpoch.toString();

  final UserService _userService = UserService();
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  final dateFormatter = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');
  final monthYearFormatter = DateFormat('MMMM, yyyy', 'vi_VN');
  final double maxSpendingForProgressBar = 4000000;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final user = AppConfig.currentUser;
      if (user == null) {
        throw Exception(
          'Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      // Xóa cache ảnh
      if (_user?.id != null) {
        final imageUrl = '${AppConfig.baseUrl}/users/${_user!.id}/image';
        await DefaultCacheManager().removeFile(imageUrl);
        print('Cleared image cache for URL: $imageUrl');
      }

      setState(() {
        _user = null;
        _selectedImage = null;
        _isLoading = true;
        AppConfig.isLogin = false;
        AppConfig.currentUser = null;
      });
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/default',
              (route) => false,
          arguments: 0,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi đăng xuất: $e')));
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedImage = image;
                    });
                    await _uploadImage();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedImage = image;
                    });
                    await _uploadImage();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null || _user == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      await _userService.uploadUserImage(_user!.id!, _selectedImage!);

      // Tạo tên file mới với timestamp để đảm bảo cập nhật
      final newImageName =
          'user_${_user!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final updatedUser = User(
        id: _user!.id,
        fullName: _user!.fullName,
        email: _user!.email,
        phoneNumber: _user!.phoneNumber,
        address: _user!.address,
        dateOfBirth: _user!.dateOfBirth,
        active: _user!.active,
        roleName: _user!.roleName,
        profileImage: newImageName,
      );
      AppConfig.currentUser = updatedUser;

      // Xóa cache ảnh sau khi upload
      final imageUrl = '${AppConfig.baseUrl}/users/${_user!.id}/image';
      await DefaultCacheManager().removeFile(imageUrl);

      // Cập nhật cache key để buộc image widget tải lại ảnh
      setState(() {
        _cacheKey = DateTime.now().millisecondsSinceEpoch.toString();
        _user = updatedUser;
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tải ảnh lên thành công!')),
        );
      }
    } catch (e) {
      String errorMessage = 'Lỗi khi tải ảnh lên. Vui lòng thử lại.';
      if (e.toString().contains('Upload failed')) {
        errorMessage = 'Không thể tải ảnh lên server. Kiểm tra kết nối mạng.';
      } else if (e.toString().contains('Permission')) {
        errorMessage =
        'Không có quyền truy cập. Vui lòng cấp quyền cho ứng dụng.';
      }

      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tài khoản',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          )
              : RefreshIndicator(
            onRefresh: _fetchUser,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: _buildUserInfoSection()),
                  const Divider(height: 10, thickness: 1),
                  _buildTabs(),
                  const Divider(height: 10, thickness: 1),
                  _buildSelectedTabContent(),
                ],
              ),
            ),
          ),
          if (_isUploading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    String? imageUrl;
    if (_user?.profileImage != null && _user!.profileImage!.isNotEmpty) {
      imageUrl =
      '${AppConfig.baseUrl}/api/v1/users/${_user!.id}/image?v=$_cacheKey';
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                // Hiển thị ảnh mới chọn nếu có
                backgroundImage:
                _selectedImage != null
                    ? FileImage(File(_selectedImage!.path))
                // Nếu không, hiển thị ảnh từ network hoặc placeholder
                    : (imageUrl != null
                    ? NetworkImage(
                  imageUrl,
                  headers: {'Cache-Control': 'no-cache'},
                )
                    : const AssetImage(
                  'assets/images/profile_placeholder.png',
                ) // Placeholder mặc định
                )
                as ImageProvider<Object>?,
                // Ép kiểu ImageProvider
                onBackgroundImageError: (exception, stackTrace) {
                  // Xử lý lỗi tải NetworkImage nếu cần
                  print("Lỗi tải ảnh đại diện: $exception");
                },
                // Hiển thị icon người dùng nếu không có ảnh nào cả
                child:
                (_selectedImage == null && imageUrl == null)
                    ? Icon(Icons.person, size: 40, color: Colors.grey[400])
                    : null,
              ),

              // --- Nút Icon Camera được định vị ---
              Positioned(
                bottom: 0, // Ghim xuống dưới
                right: 0, // Ghim sang phải
                child: Material(
                  // Thêm nền trắng và hiệu ứng nhấn (tùy chọn)
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 1.0, // Đổ bóng nhẹ
                  child: InkWell(
                    // Để có hiệu ứng ripple
                    onTap: _isUploading ? null : _pickImage,
                    // Logic nhấn nút giữ nguyên
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      // Padding nhỏ quanh icon
                      child: Icon(
                        Icons.camera_alt,
                        size: 18, // Kích thước icon camera
                        color: Colors.blueAccent, // Màu icon
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // --- Tên User ---
          Text(
            _user?.fullName ?? 'Unknown User',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTab(Icons.person_outline, 'Thông tin', 0),
          _buildTab(Icons.receipt_long_outlined, 'Giao dịch', 1),
          _buildTab(Icons.notifications_none_outlined, 'Thông báo', 2),
        ],
      ),
    );
  }

  Widget _buildTab(IconData icon, String title, int index) {
    bool isSelected = _selectedTab == index;
    Color color = isSelected ? Colors.orange[700]! : Colors.grey[600]!;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 2.5,
            width: 60,
            color: isSelected ? Colors.orange[700] : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildInfoTabContent();
      case 1:
        return _buildNotificationsTabContent();
      default:
        return Container();
    }
  }

  Widget _buildInfoTabContent() {
    int currentYear = DateTime.now().year;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Tổng chi tiêu $currentYear',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 18),
                ],
              ),
              Text(
                currencyFormatter.format(_totalSpending ?? 0),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildProgressBar(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOptionButton(icon: Icons.star_border, label: 'Đổi Quà'),
              _buildOptionButton(
                icon: Icons.card_giftcard,
                label: 'My Rewards',
              ),
              _buildOptionButton(
                icon: Icons.diamond_outlined,
                label: 'Gói Hội Viên',
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildListTile(
            title: 'Gọi ĐƯỜNG DÂY NÓNG: 19002224',
            icon: Icons.phone_outlined,
            onTap: () {},
          ),
          _buildListTile(
            title: 'Email: huit@gmail.com',
            icon: Icons.email_outlined,
            onTap: () {},
          ),
          _buildListTile(
            title: 'Thông Tin Công Ty',
            icon: Icons.business_center_outlined,
            onTap: () {},
          ),
          _buildListTile(
            title: 'Điều Khoản Sử Dụng',
            icon: Icons.description_outlined,
            onTap: () {},
          ),
          _buildListTile(
            title: 'Chính Sách Thanh Toán',
            icon: Icons.description_outlined,
            onTap: () {},
          ),
          _buildListTile(
            title: 'Chính Sách Bảo Mật',
            icon: Icons.description_outlined,
            onTap: () {},
          ),
          _buildListTile(
            title: 'FAQ',
            icon: Icons.whatshot_outlined,
            onTap: () {},
          ),
          const SizedBox(height: 25),
          Center(
            child: OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange[700],
                side: BorderSide(color: Colors.orange[700]!),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNotificationsTabContent() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          'Chưa có thông báo nào.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    double progress = 0.0;
    if (_totalSpending != null && _totalSpending! > 0) {
      progress = (_totalSpending! / maxSpendingForProgressBar).clamp(0.0, 1.0);
    }
    double screenWidth = MediaQuery.of(context).size.width - 32;

    return SizedBox(
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          Container(
            height: 8,
            width: screenWidth,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            height: 8,
            width: screenWidth * progress,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[300]!, Colors.blue[600]!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          _buildProgressMarker(0.0, screenWidth, isActive: true),
          _buildProgressMarker(0.5, screenWidth, isActive: progress >= 0.5),
          _buildProgressMarker(1.0, screenWidth, isActive: progress >= 1.0),
          Positioned(
            left: 0,
            top: 15,
            child: const Text(
              '0đ',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Positioned(
            left: screenWidth * 0.5 - 35,
            top: 15,
            child: const Text(
              '2,000,000đ',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Positioned(
            right: 0,
            top: 15,
            child: const Text(
              '4,000,000đ',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressMarker(
      double positionPercent,
      double totalWidth, {
        required bool isActive,
      }) {
    return Positioned(
      left: totalWidth * positionPercent - 6,
      top: -5,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? Colors.blue[600]! : Colors.grey[300]!,
            width: 2.5,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({required IconData icon, required String label}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue[50],
          child: Icon(icon, size: 28, color: Colors.blue[700]),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required String title,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.grey[600], size: 22),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
