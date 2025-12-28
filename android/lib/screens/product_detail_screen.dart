import 'package:android/app_config.dart';
import 'package:android/dtos/feed_back_dto.dart';
import 'package:android/models/product.dart';
import 'package:android/responses/feedback_response.dart';
import 'package:android/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../services/feedback_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  List<FeedbackResponse> _feedbacks = [];
  bool _isLoading = true;
  // bool _isFavorite = false; // Thêm sản phẩm yêu thích, thay thế vào thêm vào giỏ hàng giống như 1 sản phẩm yêu thích
  int _quantity = 1;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  int _selectedStars = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmittingFeedback = false;

  void _showFeedbackDialog() {
    if (!AppConfig.isLogin || AppConfig.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để viết đánh giá'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Viết đánh giá của bạn',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A7C59)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Bạn đánh giá sản phẩm này bao nhiêu sao?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() => _selectedStars = index + 1);
                      Navigator.pop(ctx); // Đóng dialog cũ
                      _showFeedbackDialog(); // Mở lại để cập nhật sao
                    },
                    icon: Icon(
                      Icons.star,
                      color: index < _selectedStars ? Colors.amber : Colors.grey[300],
                      size: 36,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _feedbackController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Chia sẻ trải nghiệm của bạn...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF4A7C59)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: _isSubmittingFeedback
                ? null
                : () async {
              if (_selectedStars == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng chọn số sao')),
                );
                return;
              }
              if (_feedbackController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập nội dung đánh giá')),
                );
                return;
              }

              setState(() => _isSubmittingFeedback = true);

              try {
                final feedbackDto = FeedbackDto(
                  userId: AppConfig.currentUser!.id,
                  content: _feedbackController.text.trim(),
                  star: _selectedStars,
                  productId: widget.productId,
                );

                await FeedbackService().createFeedback(feedbackDto);

                _feedbackController.clear();
                setState(() => _selectedStars = 0);

                Navigator.pop(ctx); // Đóng dialog

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gửi đánh giá thành công! Cảm ơn bạn'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Reload lại đánh giá
                _loadProductDetail();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gửi thất bại: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                if (mounted) setState(() => _isSubmittingFeedback = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A7C59)),
            child: _isSubmittingFeedback
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : const Text('Gửi đánh giá', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProductDetail();
  }

  Future<void> _loadProductDetail() async {
    setState(() => _isLoading = true);
    try {
      final productService = ProductService();
      final feedbackService = FeedbackService();
      final results = await Future.wait([
        productService.getProductById(widget.productId),
        feedbackService.getFeedbacksByProductId(widget.productId),
      ]);
      final product = results[0] as Product;
      final feedbacks = results[1] as List<FeedbackResponse>;
      setState(() {
        _product = product;
        _feedbacks = feedbacks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải sản phẩm: $e')));
      }
    }
  }

  void _addToCart() {
    if (_product == null) return;
    final cart = Provider.of<CartProvider>(context, listen: false);
    final currentQuantityInCart = cart.getQuantity(widget.productId);
    final totalQuantity = currentQuantityInCart + _quantity;

    if (totalQuantity > _product!.stockQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể thêm! Sản phẩm "${_product!.name}" không đủ hàng trong kho (Còn ${_product!.stockQuantity} sản phẩm). '
                'Hiện tại bạn đã có $currentQuantityInCart trong giỏ.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    cart.addItem(widget.productId, quantity: _quantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm $_quantity sản phẩm vào giỏ hàng'),
        backgroundColor: const Color(0xFF4A7C59),
      ),
    );

    setState(() => _quantity = 1);
  }

  void _incrementQuantity() {
    if (_product == null) return;

    final cart = Provider.of<CartProvider>(context, listen: false);
    final currentInCart = cart.getQuantity(widget.productId);
    final totalAfterIncrease = currentInCart + _quantity + 1;

    if (totalAfterIncrease <= _product!.stockQuantity) {
      setState(() => _quantity++);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể tăng thêm! Tổng số lượng sẽ vượt quá tồn kho (${_product!.stockQuantity} sản phẩm).',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  Widget _buildCouponItem(String code, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 17, color: Colors.black87, height: 1.5),
          children: [
            TextSpan(
              text: '• $code: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 18,
              ),
            ),
            TextSpan(text: description),
          ],
        ),
      ),
    );
  }

  String getImageUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty) {
      return 'https://via.placeholder.com/400';
    }
    return '${AppConfig.baseUrl}/products/images/$fileName';
  }

  List<String> _getProductImages() {
    if (_product == null) return [];

    List<String> images = [_product!.thumbnail];

    if (_product!.productImages != null &&
        _product!.productImages!.isNotEmpty) {
      images.addAll(
        _product!.productImages!
            .map((img) => img.name)
            .where((name) => name != 'notfound.jpg'),
      );
    }

    return images;
  }

  // void _incrementQuantity() {
  //   if (_product != null && _quantity < _product!.stockQuantity) {
  //     setState(() => _quantity++);
  //   }
  // }
  //
  // void _decrementQuantity() {
  //   if (_quantity > 1) {
  //     setState(() => _quantity--);
  //   }
  // }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Không tìm thấy sản phẩm')),
      );
    }

    final images = _getProductImages();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and notification
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
                  ),
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
                      //   'assets/logo.png', // Your flower logo
                      //   height: 30,
                      //   errorBuilder: (context, error, stackTrace) {
                      //     return const Icon(Icons.local_florist, size: 30);
                      //   },
                      // ),
                      // const SizedBox(width: 8),
                      // const Text(
                      //   'FLOWER',
                      //   style: TextStyle(
                      //     fontSize: 20,
                      //     fontWeight: FontWeight.w600,
                      //     letterSpacing: 2,
                      //   ),
                      // ),
                      // const Text(
                      //   'shop',
                      //   style: TextStyle(
                      //     fontSize: 16,
                      //     fontStyle: FontStyle.italic,
                      //     color: Colors.grey,
                      //   ),
                      // ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Product images carousel
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 400,
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() => _currentImageIndex = index);
                            },
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                child: Image.network(
                                  getImageUrl(images[index]),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.local_florist,
                                        size: 80,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        // Positioned(
                        //   right: 16,
                        //   bottom: 16,
                        //   child: GestureDetector(
                        //     onTap: () {
                        //       setState(() => _isFavorite = !_isFavorite);
                        //     },
                        //     child: Container(
                        //       padding: const EdgeInsets.all(12),
                        //       decoration: BoxDecoration(
                        //         color: Colors.white,
                        //         shape: BoxShape.circle,
                        //         boxShadow: [
                        //           BoxShadow(
                        //             color: Colors.black.withOpacity(0.1),
                        //             blurRadius: 8,
                        //             offset: const Offset(0, 2),
                        //           ),
                        //         ],
                        //       ),
                        //       child: Icon(
                        //         _isFavorite ? Icons.favorite : Icons.favorite_border,
                        //         color: const Color(0xFF4A7C59),
                        //         size: 28,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),

                    // Image indicators
                    if (images.length > 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            images.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _currentImageIndex == index
                                        ? const Color(0xFF4A7C59)
                                        : Colors.grey[300],
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Product details card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product name
                            Text(
                              _product!.name,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A7C59),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Rating
                            Row(
                              children: [
                                Row(
                                  children: List.generate(5, (index) {
                                    double avg =
                                        _feedbacks.isEmpty
                                            ? 0
                                            : _feedbacks[0].average;
                                    return Icon(
                                      index < avg.round()
                                          ? Icons.star
                                          : Icons.star_border,
                                      // hoặc index < avg để làm tròn tự nhiên hơn
                                      color: Colors.amber,
                                      size: 20,
                                    );
                                  }),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _feedbacks.isEmpty
                                      ? 'Chưa có đánh giá'
                                      : '${_feedbacks[0].average.toStringAsFixed(1)} (${_feedbacks.length} đánh giá)',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            //
                            // const SizedBox(height: 16),
                            // // Composition
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Column(
                            //       crossAxisAlignment: CrossAxisAlignment.start,
                            //       children: [
                            //         const Text(
                            //           'Composition:',
                            //           style: TextStyle(
                            //             fontSize: 18,
                            //             fontWeight: FontWeight.w600,
                            //             color: Colors.black87,
                            //           ),
                            //         ),
                            //         const SizedBox(height: 4),
                            //         Text(
                            //           '5 white flowers, 1 blue flower',
                            //           style: TextStyle(
                            //             fontSize: 14,
                            //             color: Colors.grey[600],
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //     // Quantity selector
                            //     Row(
                            //       children: [
                            //         IconButton(
                            //           onPressed: _decrementQuantity,
                            //           icon: const Icon(
                            //             Icons.remove_circle_outline,
                            //           ),
                            //           color: const Color(0xFF4A7C59),
                            //           iconSize: 32,
                            //         ),
                            //         Padding(
                            //           padding: const EdgeInsets.symmetric(
                            //             horizontal: 12,
                            //           ),
                            //           child: Text(
                            //             '$_quantity',
                            //             style: const TextStyle(
                            //               fontSize: 24,
                            //               fontWeight: FontWeight.bold,
                            //             ),
                            //           ),
                            //         ),
                            //         IconButton(
                            //           onPressed: _incrementQuantity,
                            //           icon: const Icon(
                            //             Icons.add_circle_outline,
                            //           ),
                            //           color: const Color(0xFF4A7C59),
                            //           iconSize: 32,
                            //         ),
                            //       ],
                            //     ),
                            //   ],
                            // ),
                            const SizedBox(height: 24),

                            // Price
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  NumberFormat.currency(
                                    locale: 'vi_VN',
                                    symbol: 'đ',
                                    decimalDigits: 0,
                                  ).format(_product!.price),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4A7C59),
                                  ),
                                ),

                                // Composition
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: _decrementQuantity,
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      color: const Color(0xFF4A7C59),
                                      iconSize: 32,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        '$_quantity',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _incrementQuantity,
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      color: const Color(0xFF4A7C59),
                                      iconSize: 32,
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.inventory_2_outlined,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Kho: ${_product!.stockQuantity} sản phẩm',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        _product!.stockQuantity > 0
                                            ? Colors.green[700]
                                            : Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_product!.stockQuantity == 0)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 12),
                                    child: Text(
                                      'Hết hàng',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            // Text(
                            //   '${_product!.price.toStringAsFixed(0)} \$',
                            //   style: const TextStyle(
                            //     fontSize: 36,
                            //     fontWeight: FontWeight.bold,
                            //     color: Color(0xFF4A7C59),
                            //   ),
                            // ),
                            const SizedBox(height: 24),

                            // Add to cart button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed:
                                    _product!.stockQuantity == 0
                                        ? null // Disable nếu hết hàng
                                    :_addToCart,
                                        // : () {
                                        //   if (_product == null) return;
                                        //   // Add to cart logic
                                        //     cart.addItem(
                                        //       widget.productId,
                                        //       quantity: _quantity,
                                        //     );
                                        //   ScaffoldMessenger.of(
                                        //     context,
                                        //   ).showSnackBar(
                                        //     SnackBar(
                                        //       content: Text(
                                        //         'Đã thêm $_quantity sản phẩm vào giỏ hàng',
                                        //       ),
                                        //       backgroundColor: const Color(
                                        //         0xFF4A7C59,
                                        //       ),
                                        //     ),
                                        //   );
                                        //   setState(() => _quantity = 1);
                                        // },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _product!.stockQuantity == 0
                                          ? Colors.grey
                                          : const Color(0xFF3D5C47),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  _product!.stockQuantity == 0
                                      ? 'Hết hàng'
                                      : 'Thêm vào giỏ hàng',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            const Text(
                              'Chi tiết sản phẩm',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A7C59),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Html(
                              data:
                                  _product!.components ??
                                  'Không có thông tin chi tiết',
                              style: {
                                "body": Style(
                                  fontSize: FontSize(16),
                                  lineHeight: LineHeight(1.6),
                                  color: Colors.black87,
                                ),
                                "br": Style(margin: Margins.zero),
                                // Đảm bảo xuống dòng đúng
                                "strong": Style(fontWeight: FontWeight.bold),
                                "p": Style(
                                  margin: Margins(
                                    top: Margin(8),
                                    bottom: Margin(8),
                                  ),
                                ),
                                "ul": Style(
                                  padding: HtmlPaddings(left: HtmlPadding(20)),
                                ),
                                "li": Style(margin: Margins(bottom: Margin(4))),
                              },
                            ),
                            const SizedBox(height: 32),

                            // === PHẦN KHUYẾN MÃI MỚI ===
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              margin: const EdgeInsets.symmetric(horizontal: 0),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Nhập mã để nhận khuyến mãi:',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      fontFamily: 'Sainte Colombe', // Nếu bạn có font này trong pubspec.yaml
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildCouponItem('BLACKFRIDAY20OFF', 'Giảm 20% Black Friday'),
                                  _buildCouponItem('CHRISTMAS30OFF', 'Giảm 30% mùa lễ Giáng sinh'),
                                  _buildCouponItem('NEWYEAR10OFF', 'Giảm 10% chúc mừng năm mới'),
                                  _buildCouponItem('HAS10OFF', 'Giảm 10% cho đơn hàng từ 500.000đ trở lên'),
                                  _buildCouponItem('1000SALE200', 'Giảm 200.000đ cho đơn hàng từ 1.000.000đ trở lên'),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),
                            const Text(
                              'Thư viện hình ảnh sản phẩm',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A7C59),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Grid ảnh (2 cột hoặc 3 cột tùy màn hình)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 1,
                                  ),
                              itemCount: images.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    getImageUrl(images[index]),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 32),
                            // Danh sách đánh giá
                            const Text(
                              'Đánh giá từ khách hàng',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _showFeedbackDialog,
                                icon: const Icon(Icons.rate_review_outlined, color: Color(0xFF4A7C59)),
                                label: const Text(
                                  'Viết đánh giá',
                                  style: TextStyle(color: Color(0xFF4A7C59), fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),

                            const Divider(height: 32),

                            if (_feedbacks.isEmpty)
                              const Text(
                                'Chưa có đánh giá nào',
                                style: TextStyle(color: Colors.grey),
                              ),

                            ..._feedbacks.map(
                              (f) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          f.userResponse.fullName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          DateFormat(
                                            'dd/MM/yyyy HH:mm',
                                          ).format(f.createdAt),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          Icons.star,
                                          color:
                                              i < f.star
                                                  ? Colors.amber
                                                  : Colors.grey[300],
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(f.content),
                                  ],
                                ),
                              ),
                            ),

                            // You might also like
                            // const Text(
                            //   'You Might Also Like:',
                            //   style: TextStyle(
                            //     fontSize: 18,
                            //     fontWeight: FontWeight.w600,
                            //     color: Colors.black87,
                            //   ),
                            // ),
                            // const SizedBox(height: 16),

                            // Related products
                            // SizedBox(
                            //   height: 120,
                            //   child: ListView.builder(
                            //     scrollDirection: Axis.horizontal,
                            //     itemCount: 3,
                            //     itemBuilder: (context, index) {
                            //       return Container(
                            //         width: 100,
                            //         margin: const EdgeInsets.only(right: 16),
                            //         decoration: BoxDecoration(
                            //           color: Colors.white,
                            //           borderRadius: BorderRadius.circular(16),
                            //           boxShadow: [
                            //             BoxShadow(
                            //               color: Colors.black.withOpacity(0.05),
                            //               blurRadius: 8,
                            //               offset: const Offset(0, 2),
                            //             ),
                            //           ],
                            //         ),
                            //         child: ClipRRect(
                            //           borderRadius: BorderRadius.circular(16),
                            //           child: Image.network(
                            //             getImageUrl(_product!.thumbnail),
                            //             fit: BoxFit.cover,
                            //             errorBuilder: (
                            //               context,
                            //               error,
                            //               stackTrace,
                            //             ) {
                            //               return const Icon(
                            //                 Icons.local_florist,
                            //                 size: 40,
                            //               );
                            //             },
                            //           ),
                            //         ),
                            //       );
                            //     },
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
