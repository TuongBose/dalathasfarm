import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // IconButton(
                        //   icon: const Icon(
                        //     Icons.arrow_back_ios,
                        //     color: Color(0xFF4A7C59),
                        //   ),
                        //   onPressed: () => Navigator.pop(context),
                        // ),
                        Text(
                          'Tin tức & Blog',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A7C59),
                            fontFamily: 'Cursive',
                          ),
                        ),
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
