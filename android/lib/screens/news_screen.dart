import 'package:android/screens/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/occasion.dart';
import '../providers/cart_provider.dart';
import '../services/category_service.dart';
import '../services/occasion_service.dart';
import 'cart_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => NewsScreenState();
}

class NewsScreenState extends State<NewsScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Dữ liệu tin tức fix cứng
  final List<Map<String, String>> news = const [
    {
      'title': 'Top 5 loài hoa đẹp nhất mùa Giáng Sinh 2025',
      'description':
          'Giáng Sinh đang đến gần, hãy cùng Dalat Hasfarm khám phá những loài hoa rực rỡ nhất để trang trí nhà cửa và làm quà tặng ý nghĩa cho người thân yêu.',
      'date': '2025-12-15',
      'image':
          'https://images.unsplash.com/photo-1604085572504-a392ddf0d86a?w=800&q=80',
      // Hoa đỏ Giáng Sinh
    },
    {
      'title': 'Cách giữ hoa tươi lâu trong dịp Tết Nguyên Đán',
      'description':
          'Mẹo nhỏ từ Dalat Hasfarm giúp bó hoa của bạn tươi mới suốt tuần Tết: cắt gốc chéo, thay nước hàng ngày và thêm chút đường vào bình...',
      'date': '2025-12-10',
      'image':
          'https://truyenhinhnghean.vn/file/4028eaa46735a26101673a4df345003c/012023/hoa1_20230120084426.jpg',
      // Hoa Tết
    },
    {
      'title': 'Khuyến mãi đặc biệt: Mua 2 tặng 1 nhân ngày Phụ nữ Việt Nam',
      'description':
          'Từ nay đến 20/10, khi mua 2 bó hoa bất kỳ, bạn sẽ được tặng thêm 1 bó hoa mini xinh xắn. Số lượng có hạn!',
      'date': '2025-10-15',
      'image':
          'https://cdn.tgdd.vn/Files/2021/01/19/1321035/hieu-ro-y-nghia-hoa-hong-giup-ban-chinh-phuc-nang-.jpg',
      // Hoa hồng tặng phụ nữ
    },
    {
      'title': 'Hoa cưới 2025: Xu hướng màu pastel dịu dàng đang lên ngôi',
      'description':
          'Các cô dâu tương lai đang mê mẩn những bó hoa cưới tone pastel nhẹ nhàng kết hợp với hoa baby và lá bạc. Xem ngay bộ sưu tập mới nhất từ Dalat Hasfarm.',
      'date': '2025-09-28',
      'image':
          'https://hoatuoihoamy.com/wp-content/uploads/2022/10/Hinh-49-1.jpg',
      // Hoa cưới pastel
    },
    {
      'title': 'Bí quyết chọn hoa tặng sinh nhật theo cung hoàng đạo',
      'description':
          'Bạn đang bối rối không biết tặng hoa gì cho người ấy? Hãy để cung hoàng đạo gợi ý: Bạch Dương hợp hoa đỏ rực rỡ, Song Ngư thích hoa tím mộng mơ...',
      'date': '2025-08-20',
      'image':
          'https://storage.googleapis.com/cdn_dlhf_vn/blog/2023/09/293234213_5081830885249512_7387616144629855805_n.jpg',
      // Hoa sinh nhật đa màu
    },
  ];

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = news[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        // Sau này có thể mở chi tiết bài viết
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Bài viết: ${item['title']}')),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ảnh bài viết
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              item['image']!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ngày đăng
                                Text(
                                  DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(DateTime.parse(item['date']!)),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Tiêu đề
                                Text(
                                  item['title']!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Mô tả
                                Text(
                                  item['description']!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    height: 1.5,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 12),

                                // Nút đọc thêm
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Đang mở: ${item['title']}',
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Đọc thêm',
                                          style: TextStyle(
                                            color: Color(0xFF4A7C59),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                          color: Color(0xFF4A7C59),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: news.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
