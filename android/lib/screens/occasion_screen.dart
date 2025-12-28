import 'dart:async';

import 'package:android/app_config.dart';
import 'package:android/models/category.dart';
import 'package:android/models/product.dart';
import 'package:android/screens/cart_screen.dart';
import 'package:android/screens/product_detail_screen.dart';
import 'package:android/screens/product_screen.dart';
import 'package:android/services/category_service.dart';
import 'package:android/services/occasion_service.dart';
import 'package:android/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/occasion.dart';
import '../providers/cart_provider.dart';

class OccasionScreen extends StatefulWidget {
  final int occasionId;

  const OccasionScreen({super.key, required this.occasionId});

  @override
  State<OccasionScreen> createState() => OccasionScreenState();
}

class OccasionScreenState extends State<OccasionScreen> {
  Occasion? _occasion;
  List<Product> _products = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;

  late final PageController _pageController;
  int _currentBannerIndex = 0;

  final TextEditingController _searchController = TextEditingController();

  String _currentKeyword = '';
  int _currentCategoryId = 0;
  int _currentOccasionId = 0;

  int get _activeFilterCount {
    int count = 0;
    if (_currentCategoryId != 0) count++;
    if (_currentOccasionId != 0) count++;
    return count;
  }

  void _performSearch() {
    final keyword = _searchController.text.trim();
    final hasFilter = keyword.isNotEmpty || _activeFilterCount > 0;

    if (hasFilter) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductScreen(
            keyword: keyword,
            categoryId: _currentCategoryId,
            occasionId: _currentOccasionId,
          ),
        ),
      );
    }
  }

  Future<void> _showFilterBottomSheet() async {
    final CategoryService categoryService = CategoryService();
    final OccasionService occasionService = OccasionService();

    List<Category> categories = [];
    List<Occasion> occasions = [];

    bool isLoading = true;
    String? error;

    try {
      final results = await Future.wait([
        categoryService.getAllCategory(0, 50),
        occasionService.getAllOccasion(0, 50),
      ]);
      categories = results[0] as List<Category>;
      occasions = results[1] as List<Occasion>;
      isLoading = false;
    } catch (e) {
      error = 'Không thể tải bộ lọc';
      isLoading = false;
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
        builder:
            (context, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder:
              (context, scrollController) => Container(
            padding: const EdgeInsets.all(20),
            child:
            isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : error != null
                ? Center(
              child: Text(
                error,
                style: const TextStyle(color: Colors.red),
              ),
            )
                : Column(
              children: [
                // Tiêu đề
                Row(
                  children: [
                    const Text(
                      'Lọc sản phẩm',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A7C59),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed:
                          () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 30),

                // Danh mục
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      const Text(
                        'Danh mục',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children:
                        categories
                            .map(
                              (cat) => FilterChip(
                            label: Text(cat.name),
                            selected:
                            _currentCategoryId ==
                                cat.id,
                            onSelected: (selected) {
                              setSheetState(() {
                                _currentCategoryId =
                                selected
                                    ? cat.id
                                    : 0;
                              });
                              setSheetState(() {});
                              // Navigator.pop(context);
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder:
                              //         (_) => ProductScreen(
                              //           keyword: _searchController.text.trim(),
                              //           categoryId: _currentCategoryId,
                              //           occasionId: _currentOccasionId,
                              //         ),
                              //   ),
                              // );
                            },
                            backgroundColor:
                            Colors.grey[100],
                            selectedColor:
                            const Color(
                              0xFF4A7C59,
                            ),
                            labelStyle: TextStyle(
                              color:
                              _currentCategoryId ==
                                  cat.id
                                  ? Colors.white
                                  : Colors
                                  .black87,
                            ),
                            checkmarkColor:
                            Colors.white,
                          ),
                        )
                            .toList(),
                      ),
                      const SizedBox(height: 24),

                      // Dịp lễ
                      const Text(
                        'Dịp lễ / Sự kiện',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children:
                        occasions
                            .map(
                              (occ) => FilterChip(
                            label: Text(occ.name),
                            selected:
                            _currentOccasionId ==
                                occ.id,
                            onSelected: (selected) {
                              setSheetState(() {
                                _currentOccasionId =
                                selected
                                    ? occ.id
                                    : 0;
                              });
                              setSheetState(() {});
                              // Navigator.pop(context);
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder:
                              //         (_) => ProductScreen(
                              //           keyword: _searchController.text.trim(),
                              //           categoryId: _currentCategoryId,
                              //           occasionId: _currentOccasionId,
                              //         ),
                              //   ),
                              // );
                            },
                            backgroundColor:
                            Colors.grey[100],
                            selectedColor:
                            const Color(
                              0xFF4A7C59,
                            ),
                            labelStyle: TextStyle(
                              color:
                              _currentOccasionId ==
                                  occ.id
                                  ? Colors.white
                                  : Colors
                                  .black87,
                            ),
                            checkmarkColor:
                            Colors.white,
                          ),
                        )
                            .toList(),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
                // Nút Áp dụng (cố định dưới cùng)
                // Container(
                //   width: double.infinity,
                //   height: 56,
                //   decoration: BoxDecoration(
                //     color: const Color(0xFF4A7C59),
                //     borderRadius: BorderRadius.circular(30),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black.withOpacity(
                //           0.1,
                //         ),
                //         blurRadius: 10,
                //       ),
                //     ],
                //   ),
                //   child: ElevatedButton(
                //     onPressed: () {
                //       // Cập nhật giá trị chính thức
                //       setState(() {
                //         _currentCategoryId = tempCategoryId;
                //         _currentOccasionId = tempOccasionId;
                //       });
                //       Navigator.pop(context);
                //
                //       // Chỉ chuyển trang nếu có ít nhất 1 filter (hoặc có keyword)
                //       final hasFilter =
                //           _currentCategoryId != 0 ||
                //           _currentOccasionId != 0 ||
                //           _searchController.text
                //               .trim()
                //               .isNotEmpty;
                //       if (hasFilter) {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder:
                //                 (_) => ProductScreen(
                //                   keyword:
                //                       _searchController.text
                //                           .trim(),
                //                   categoryId:
                //                       _currentCategoryId,
                //                   occasionId:
                //                       _currentOccasionId,
                //                 ),
                //           ),
                //         );
                //       }
                //     },
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.transparent,
                //       shadowColor: Colors.transparent,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(
                //           30,
                //         ),
                //       ),
                //     ),
                //     child: const Text(
                //       'Áp dụng bộ lọc',
                //       style: TextStyle(
                //         fontSize: 18,
                //         fontWeight: FontWeight.bold,
                //         color: Colors.white,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadData(page: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
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
      OccasionService occasionService = OccasionService();
      ProductService productService = ProductService();

      final results = await Future.wait([
        occasionService.getOccasionById(widget.occasionId),
        productService.getAllProduct('', 0, widget.occasionId, apiPage, 10),
      ]);

      final occasion = results[0] as Occasion;
      final productResult = results[1] as Map<String, dynamic>;

      setState(() {
        _occasion = occasion;
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

    if (_occasion == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Không tìm thấy danh mục')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xFF4A7C59),
                          ),
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/default',
                                  (route) => false,
                              arguments: 0,
                            );
                          },
                        ),
                        const Spacer(),
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
                              textInputAction: TextInputAction.search,
                              onSubmitted: (value) {
                                final keyword = value.trim();
                                if (keyword.isNotEmpty ||
                                    _activeFilterCount > 0) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => ProductScreen(
                                        keyword: keyword,
                                        categoryId: _currentCategoryId,
                                        occasionId: _currentOccasionId,
                                      ),
                                    ),
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm sản phẩm',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: IconButton(
                                  icon: Icon(Icons.search,color: Colors.grey[400],),
                                  onPressed: _performSearch,
                                ),
                                // suffixIcon: Icon(
                                //   Icons.mic_none,
                                //   color: Colors.grey[400],
                                // ),
                                suffixIcon:
                                _searchController.text.isNotEmpty
                                    ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              onChanged: (value) => setState(() {}),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Stack(
                          children: [
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
                                onPressed: _showFilterBottomSheet,
                              ),
                            ),
                            if (_activeFilterCount > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$_activeFilterCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

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
                    child: SizedBox(
                      height: 200,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentBannerIndex = index;
                          });
                        },
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    getImageUrl(_occasion!.bannerImage),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image,
                                          size: 50,
                                        ),
                                      );
                                    },
                                  ),

                                  // Positioned(
                                  //   left: 12,
                                  //   top: 12,
                                  //   child: InkWell(
                                  //     onTap: () {
                                  //       Navigator.pop(context);
                                  //     },
                                  //     borderRadius: BorderRadius.circular(24),
                                  //     child: Container(
                                  //       padding: const EdgeInsets.all(8),
                                  //       decoration: BoxDecoration(
                                  //         color: Colors.black54,
                                  //         borderRadius: BorderRadius.circular(24),
                                  //       ),
                                  //       child: const Icon(
                                  //         Icons.arrow_back,
                                  //         color: Colors.white,
                                  //         size: 22,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),

                                  // Positioned(
                                  //   right: 20,
                                  //   top: 20,
                                  //   child: Container(
                                  //     padding: const EdgeInsets.symmetric(
                                  //       horizontal: 12,
                                  //       vertical: 6,
                                  //     ),
                                  //     decoration: BoxDecoration(
                                  //       color: Colors.black54,
                                  //       borderRadius: BorderRadius.circular(20),
                                  //     ),
                                  //     child: Text(
                                  //       _occasion!.name,
                                  //       style: const TextStyle(
                                  //         color: Colors.white,
                                  //         fontWeight: FontWeight.bold,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF4A7C59),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
