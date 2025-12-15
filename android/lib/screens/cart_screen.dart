import 'package:android/app_config.dart';
import 'package:android/models/product.dart';
import 'package:android/providers/cart_provider.dart';
import 'package:android/screens/checkout_screen.dart';
import 'package:android/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCartProducts();
  }

  Future<void> _loadCartProducts() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final productIds = cart.productIds;

    if (productIds.isEmpty) {
      setState(() {
        _products = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final productService = ProductService();
      List<Product> loadedProducts = [];

      for (int id in productIds) {
        final product = await productService.getProductById(id);
        loadedProducts.add(product);
      }

      setState(() {
        _products = loadedProducts;
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

  double _calculateTotal() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    double total = 0;
    for (var product in _products) {
      final qty = cart.getQuantity(product.id);
      total += product.price * qty;
    }
    return total;
  }

  String _getImageUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty)
      return 'https://via.placeholder.com/100';
    return '${AppConfig.baseUrl}/products/images/$fileName';
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final itemCount = cart.itemCount;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (itemCount == 0) {
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
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Color(0xFF4A7C59),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Expanded(child:
                          Center(child:
                          Text(
                            'Giỏ hàng của bạn',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A7C59),
                              fontFamily: 'Cursive',
                            ),
                          ),
                          ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyCart(),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 1,
      //   foregroundColor: const Color(0xFF4A7C59),
      //   title: const Text(
      //     'Giỏ hàng của bạn',
      //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      //   ),
      //   centerTitle: true,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.delete_sweep, color: Colors.red),
      //       onPressed: () {
      //         showDialog(
      //           context: context,
      //           builder:
      //               (ctx) => AlertDialog(
      //                 title: const Text('Xóa toàn bộ?'),
      //                 content: const Text(
      //                   'Bạn có chắc muốn xóa tất cả sản phẩm?',
      //                 ),
      //                 actions: [
      //                   TextButton(
      //                     onPressed: () => Navigator.pop(ctx),
      //                     child: const Text('Hủy'),
      //                   ),
      //                   TextButton(
      //                     onPressed: () {
      //                       cart.clear();
      //                       Navigator.pop(ctx);
      //                       _loadCartProducts(); // Reload để cập nhật UI
      //                     },
      //                     child: const Text(
      //                       'Xóa',
      //                       style: TextStyle(color: Colors.red),
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //         );
      //       },
      //     ),
      //     Padding(
      //       padding: const EdgeInsets.only(right: 16),
      //       child: Center(
      //         child: Container(
      //           padding: const EdgeInsets.symmetric(
      //             horizontal: 12,
      //             vertical: 6,
      //           ),
      //           decoration: BoxDecoration(
      //             color: const Color(0xFF4A7C59).withOpacity(0.1),
      //             borderRadius: BorderRadius.circular(20),
      //           ),
      //           child: Text(
      //             '$itemCount SP',
      //             style: const TextStyle(
      //               fontWeight: FontWeight.bold,
      //               color: Color(0xFF4A7C59),
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
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
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xFF4A7C59),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        Text(
                          'Giỏ hàng của bạn',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A7C59),
                            fontFamily: 'Cursive',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_sweep,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (ctx) => AlertDialog(
                                    title: const Text('Xóa toàn bộ?'),
                                    content: const Text(
                                      'Bạn có chắc muốn xóa tất cả sản phẩm?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          cart.clear();
                                          Navigator.pop(ctx);
                                          _loadCartProducts();
                                        },
                                        child: const Text(
                                          'Xóa',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 0),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A7C59).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$itemCount SP',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A7C59),
                                ),
                              ),
                            ),
                          ),
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
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        final quantity = cart.getQuantity(product.id);

                        return Dismissible(
                          key: Key(product.id.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          onDismissed: (_) {
                            cart.removeItem(product.id);
                            _loadCartProducts(); // Reload để cập nhật danh sách
                          },
                          child: Card(
                            color: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      _getImageUrl(product.thumbnail),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.local_florist,
                                              size: 50,
                                            ),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          NumberFormat.currency(
                                            locale: 'vi_VN',
                                            symbol: 'đ',
                                          ).format(product.price),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4A7C59),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            _buildQuantityButton(
                                              () => cart.decreaseQuantity(
                                                product.id,
                                              ),
                                              Icons.remove,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                              child: Text(
                                                '$quantity',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            _buildQuantityButton(
                                              () => cart.increaseQuantity(
                                                product.id,
                                              ),
                                              Icons.add,
                                              isAdd: true,
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                cart.removeItem(product.id);
                                                _loadCartProducts();
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
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
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomCheckout(context, cart),
    );
  }

  Widget _buildQuantityButton(
    VoidCallback onPressed,
    IconData icon, {
    bool isAdd = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isAdd ? const Color(0xFF4A7C59) : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isAdd ? Colors.white : Colors.black87,
          size: 20,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          const Text(
            'Giỏ hàng trống',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Hãy chọn những bó hoa yêu thích nhé!',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white,),
            label: const Text('Quay lại mua sắm', style: TextStyle(color: Colors.white,)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A7C59),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckout(BuildContext context, CartProvider cart) {
    final total = _calculateTotal();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  NumberFormat.currency(
                    locale: 'vi_VN',
                    symbol: 'đ',
                  ).format(total),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A7C59),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D6B4A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'TIẾN HÀNH THANH TOÁN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
