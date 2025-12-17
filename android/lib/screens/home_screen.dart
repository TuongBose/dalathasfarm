import 'dart:async';

import 'package:android/app_config.dart';
import 'package:android/models/category.dart';
import 'package:android/models/product.dart';
import 'package:android/screens/cart_screen.dart';
import 'package:android/screens/categories_screen.dart';
import 'package:android/screens/product_detail_screen.dart';
import 'package:android/services/category_service.dart';
import 'package:android/services/occasion_service.dart';
import 'package:android/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../models/occasion.dart';
import '../providers/cart_provider.dart';
import 'category_screen.dart';
import 'occasion_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Category> _categories = [];
  List<Occasion> _occasions = [];
  List<Product> _featuredProducts = [];

  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;

  final PageController _pageController = PageController(viewportFraction: 0.95);
  Timer? _timer;
  int _currentBannerIndex = 0;
  final TextEditingController _searchController = TextEditingController();

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
        _featuredProducts.clear();
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      CategoryService categoryService = CategoryService();
      OccasionService occasionService = OccasionService();
      ProductService productService = ProductService();

      final results = await Future.wait([
        categoryService.getAllCategory(0, 20),
        occasionService.getTodayOccasions(),
        productService.getAllProduct('', 0, 0, apiPage, 10),
      ]);

      final productResult = results[2] as Map<String, dynamic>;

      setState(() {
        if (page == 1) {
          _categories = results[0] as List<Category>;
          _occasions = results[1] as List<Occasion>;
        }
        _featuredProducts = productResult['products'] as List<Product>;
        _totalPages = productResult['totalPages'] as int;
        _currentPage = page;

        _isLoading = false;
        _isLoadingMore = false;
      });

      if (_occasions.isNotEmpty && page == 1) _startAutoScroll();
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

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients) return;
      int nextPage = (_currentBannerIndex + 1) % _occasions.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String getImageUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty) {
      return 'https://via.placeholder.com/300';
    }
    return '${AppConfig.baseUrl}/products/images/$fileName';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // AppBar skeleton
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 150,
                              height: 40,
                              color: Colors.white,
                            ),
                          ),
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Banner skeleton
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 200,
                          height: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          itemBuilder:
                              (context, index) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.9,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Categories skeleton
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 150,
                          height: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: 6,
                          itemBuilder:
                              (context, index) => Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 80,
                                        height: 16,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Products title skeleton
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 250,
                      height: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Products grid skeleton
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Container(color: Colors.grey[400]),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 80,
                                    height: 20,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    childCount: 6, // hiển thị 6 ô giả
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'DalatHasfarm',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A7C59),
                            fontFamily: 'Cursive',
                          ),
                        ),
                        // Image.asset(
                        //   'assets/images/logo.png',
                        //   height: 80,
                        //   width: 200,
                        //   fit: BoxFit.fill,
                        // ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            size: 28,
                          ),
                          onPressed: () {},
                        ),
                        Consumer<CartProvider>(
                          builder: (context, cart, child) {
                            return Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const CartScreen(),
                                      ),
                                    );
                                  },
                                ),
                                if (cart.itemCount > 0)
                                  Positioned(
                                    right: 8,
                                    top: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${cart.itemCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search Bar
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm sản phẩm',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey[400],
                                ),
                                // suffixIcon: Icon(
                                //   Icons.mic_none,
                                //   color: Colors.grey[400],
                                // ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.tune,
                              color: Color(0xFF4A7C59),
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Banner sự kiện sắp tới
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child:
                        _occasions.isEmpty
                            ? const Center(child: Text('Không có ưu đãi'))
                            : PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentBannerIndex = index;
                                });
                              },
                              itemCount: _occasions.length,
                              itemBuilder: (context, index) {
                                final occasion = _occasions[index];
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OccasionScreen(occasionId: occasion.id),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          getImageUrl(occasion.bannerImage),
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.image,
                                                size: 50,
                                              ),
                                            );
                                          },
                                        ),
                                        Positioned(
                                          right: 20,
                                          top: 20,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                );
                              },
                            ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _occasions.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentBannerIndex == index
                                  ? const Color(0xFF4A7C59)
                                  : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Danh mục sản phẩm',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A7C59),
                          ),
                        ),
                        // TextButton(
                        //   onPressed: () {},
                        //   child: const Text(
                        //     'Xem thêm',
                        //     style: TextStyle(
                        //       color: Color(0xFF4A7C59),
                        //       fontSize: 16,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount:
                          _categories.length > 5 ? 6 : _categories.length,
                      itemBuilder: (context, index) {
                        if (index == 5) {
                          return GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF4A7C59),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon:const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => const CategoriesScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // const Text(
                                  //   'Xem thêm',
                                  //   textAlign: TextAlign.center,
                                  //   style: TextStyle(
                                  //     fontSize: 13,
                                  //     fontWeight: FontWeight.w600,
                                  //     color: Color(0xFF4A7C59),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          );
                        }

                        final category = _categories[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        CategoryScreen(categoryId: category.id),
                              ),
                            );
                          },
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      getImageUrl(category.thumbnail),
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Icon(
                                          Icons.local_florist,
                                          size: 40,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Trends & Popular
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Các sản phẩm nổi bật',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A7C59),
                      ),
                    ),
                    // TextButton(
                    //   onPressed: () {},
                    //   child: const Text(
                    //     'Xem thêm',
                    //     style: TextStyle(
                    //       color: Color(0xFF4A7C59),
                    //       fontSize: 16,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),

            // Products Grid
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
                  final product = _featuredProducts[index];
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
                }, childCount: _featuredProducts.length),
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
