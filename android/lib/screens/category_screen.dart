import 'dart:async';

import 'package:android/app_config.dart';
import 'package:android/models/category.dart';
import 'package:android/models/product.dart';
import 'package:android/screens/cart_screen.dart';
import 'package:android/screens/product_detail_screen.dart';
import 'package:android/services/category_service.dart';
import 'package:android/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CategoryScreen extends StatefulWidget {
  final int categoryId;

  const CategoryScreen({super.key, required this.categoryId});

  @override
  State<CategoryScreen> createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> {
  Category? _category;
  List<Product> _products = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadData(page: 1);
  }

  Future<void> _loadData({required int page}) async {
    final int apiPage = page - 1;
    if (page == 1) {
      setState(() {
        _isLoading = true;
        _products.clear();
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      CategoryService categoryService = CategoryService();
      ProductService productService = ProductService();

      final results = await Future.wait([
        categoryService.getCategoryById(widget.categoryId),
        productService.getAllProduct('', widget.categoryId, 0, apiPage, 10),
      ]);

      final category = results[0] as Category;
      final productResult = results[1] as Map<String, dynamic>;

      setState(() {
        _category = category;
        _products = productResult['products'] as List<Product>;
        _totalPages = productResult['totalPages'] as int;
        _currentPage = page;

        _isLoading = false;
        _isLoadingMore = false;
      });

    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
      }
    }
  }

  void _goToPrevious() {
    if (_currentPage > 1) {
      _loadData(page: _currentPage - 1);
    }
  }

  void _goToNext() {
    if (_currentPage < _totalPages) {
      _loadData(page: _currentPage + 1);
    }
  }

  String getImageUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty)
      return 'https://via.placeholder.com/600';
    return '${AppConfig.baseUrl}/products/images/$fileName';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_category == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Không tìm thấy danh mục')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(child:  CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    getImageUrl(_category!.thumbnail),
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(color: Colors.grey[300]),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _category!.name,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 10),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _category!.description,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading:  IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                ),
                onPressed: () {},
              ),
              Consumer<CartProvider>(
                builder:
                    (context, cart, child) => Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                          ),
                          onPressed:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CartScreen(),
                                ),
                              ),
                        ),
                        if (cart.itemCount > 0)
                          Positioned(
                            right: 8,
                            top: 2,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.red,
                              child: Text(
                                '${cart.itemCount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
              ),
            ],
          ),

          // Tiêu đề + danh sách sản phẩm
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Danh sách sản phẩm',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A7C59),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = _products[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to product detail
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ProductDetailScreen(productId: product.id),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              getImageUrl(product.thumbnail),
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.local_florist,
                                    size: 50,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                NumberFormat.currency(
                                  locale: 'vi_VN',
                                  symbol: 'đ',
                                  decimalDigits: 0,
                                ).format(product.price),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A7C59),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: _products.length),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nút Trước
                  ElevatedButton.icon(
                    onPressed: _currentPage <= 1 ? null : _goToPrevious,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4A7C59),
                      elevation: 2,
                      disabledBackgroundColor: Colors.grey[200],
                    ),
                    icon: const Icon(Icons.chevron_left, size: 20),
                    label: const Text('Trước'),
                  ),

                  const SizedBox(width: 20),

                  // Hiển thị trang hiện tại
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A7C59),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Trang $_currentPage / $_totalPages',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Nút Sau
                  ElevatedButton.icon(
                    onPressed: _currentPage >= _totalPages ? null : _goToNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4A7C59),
                      elevation: 2,
                      disabledBackgroundColor: Colors.grey[200],
                    ),
                    label: const Text('Sau'),
                    icon: const Icon(Icons.chevron_right, size: 20),
                  ),
                ],
              ),
            ),
          ),

          // Loading khi chuyển trang
          if (_isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF4A7C59)),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}
