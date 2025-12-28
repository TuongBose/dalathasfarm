// ===================== ORDER SCREEN (UPDATED) =====================
import 'package:android/app_config.dart';
import 'package:android/models/order_status.dart';
import 'package:android/responses/order_response.dart';
import 'package:android/screens/product_screen.dart';
import 'package:android/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/occasion.dart';
import '../providers/cart_provider.dart';
import '../services/category_service.dart';
import '../services/occasion_service.dart';
import 'cart_screen.dart';
import 'login_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderResponse> _allOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  final OrderService _orderService = OrderService();
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  final List<String> _tabs = [
    'Tất cả',
    'Chờ xác nhận',
    'Đang xử lý',
    'Đang giao',
    'Đã giao',
    'Đã hủy',
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
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _checkLoginAndLoadOrders();
  }

  Future<void> _checkLoginAndLoadOrders() async {
    if (!AppConfig.isLogin || AppConfig.currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }
    await _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = AppConfig.currentUser!.id;
      final orders = await _orderService.getOrdersByUserId(userId);
      setState(() {
        _allOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải đơn hàng. Vui lòng thử lại.';
        _isLoading = false;
      });
    }
  }

  List<OrderResponse> _getFilteredOrders(int tabIndex) {
    if (tabIndex == 0) return _allOrders;

    final statusMap = {
      1: 'pending',
      2: 'processing',
      3: 'shipping',
      4: 'delivered',
      5: 'cancelled',
    };

    final targetStatus = statusMap[tabIndex];
    return _allOrders
        .where((order) => order.status.toLowerCase() == targetStatus)
        .toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      body: SafeArea(
        child: Column(
          children: [
            Padding(
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
                        'Đơn hàng',
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
            Expanded(
              child:
              !AppConfig.isLogin
                  ? _buildNotLoggedInView()
                  : _buildOrderListView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Bạn chưa đăng nhập',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Đăng nhập để theo dõi và quản lý\nđơn hàng của bạn',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7C59),
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Đăng nhập ngay',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderListView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadOrders,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7C59),
              ),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF4A7C59),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF4A7C59),
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(_tabs.length, (index) {
              final orders = _getFilteredOrders(index);

              if (orders.isEmpty) {
                return _buildEmptyState(index);
              }

              return RefreshIndicator(
                onRefresh: _loadOrders,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, i) => _buildOrderCard(orders[i]),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(int tabIndex) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            tabIndex == 0
                ? 'Bạn chưa có đơn hàng nào'
                : 'Không có đơn hàng ${_tabs[tabIndex].toLowerCase()}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy khám phá và đặt hàng ngay!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderResponse order) {
    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(order: order),
            ),
          );

          if (result == true) {
            _loadOrders(); // Refresh lại danh sách đơn hàng
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mã đơn hàng ${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
              const Divider(height: 24),

              // Order info
              _buildInfoRow(
                Icons.calendar_today,
                'Ngày đặt hàng',
                DateFormat('dd-MM-yyyy').format(order.orderDate),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.local_shipping_outlined,
                'Phương thức giao hàng',
                order.shippingMethod == 'Ship' ? 'Giao hàng tận nơi' : 'Lấy tại cửa hàng',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.shopping_bag_outlined,
                'Số sản phẩm',
                '${order.orderDetailResponses.length} sản phẩm',
              ),
              const SizedBox(height: 16),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng tiền:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    currencyFormat.format(order.totalMoney),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A7C59),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(order: order),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18, color: Colors.red,),
                  label: const Text('Xem chi tiết'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4A7C59),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = OrderStatus.getStatusColor(status);
    String displayName = OrderStatus.getDisplayName(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        displayName,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class OrderDetailScreen extends StatefulWidget {
  final OrderResponse order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  bool _isCancelling = false;

  String _getImageUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty) {
      return 'https://via.placeholder.com/100';
    }
    return '${AppConfig.baseUrl}/products/images/$fileName';
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(amount);
  }

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy đơn hàng?', style: TextStyle(color: Colors.red)),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này?\nHành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Không')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hủy đơn', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isCancelling = true);

    try {
      await _orderService.cancelOrder(widget.order.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy đơn hàng thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hủy đơn hàng thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'vi_VN');
    final bool canCancel = widget.order.status.toLowerCase() == 'pending';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mã đơn hàng ${widget.order.id}',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                OrderStatus.getDisplayName(widget.order.status).toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFFF8F00),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header info
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ngày đặt hàng: ${DateFormat('dd-MM-yyyy').format(widget.order.orderDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Products section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD4AF37),
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Sản phẩm đã chọn',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...widget.order.orderDetailResponses.map((detail) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _getImageUrl(detail.productResponse.thumbnail),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  detail.productResponse.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${detail.quantity} × ${_formatCurrency(detail.price)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatCurrency(detail.totalMoney),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Customer info section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD4AF37),
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Thông tin nhận hàng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow('Người nhận:', widget.order.fullName),
                  const SizedBox(height: 12),
                  _buildDetailRow('Số điện thoại:', widget.order.phoneNumber),
                  const SizedBox(height: 12),
                  _buildDetailRow('Địa chỉ:', widget.order.address),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Ngày nhận hàng:',
                    DateFormat('dd-MM-yyyy').format(widget.order.shippingDate),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Phương thức thanh toán:',
                    widget.order.paymentMethod == 'Cash'
                        ? 'Tiền mặt khi nhận hàng'
                        : 'Chuyển khoản ngân hàng',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Phương thức giao hàng:',
                    widget.order.shippingMethod == 'Ship' ? 'Giao hàng tận nơi' : 'Pickup',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Total section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'TỔNG CỘNG',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatCurrency(widget.order.totalMoney),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A7C59),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (canCancel)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                color: Colors.white,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isCancelling ? null : _cancelOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isCancelling
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text(
                      'HỦY ĐƠN HÀNG',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}