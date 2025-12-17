import 'dart:convert';

import 'package:android/app_config.dart';
import 'package:android/dtos/payment_dto.dart';
import 'package:android/models/product.dart';
import 'package:android/screens/payment_webview.dart';
import 'package:android/services/product_service.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../dtos/cart_item_dto.dart';
import '../dtos/order_dto.dart';
import '../models/address.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import '../services/payment_service.dart';
import 'default_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Form fields
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  final _couponController = TextEditingController();

  String _firstName = '';
  String _lastName = '';
  String _phoneNumber = '';
  String _addressDetail = '';
  String _note = '';
  String _couponCode = '';

  String _shippingMethod = 'Ship';
  String _paymentMethod = 'Cash';
  DateTime? _shippingDate;
  Province? _selectedProvince;
  District? _selectedDistrict;
  Ward? _selectedWard;

  List<Province> _provinces = [];
  List<District> _districts = [];
  List<Ward> _wards = [];

  List<Product> _products = [];
  bool _isLoading = true;
  double _totalAmount = 0;
  double _couponDiscount = 0;
  bool _couponApplied = false;

  @override
  void initState() {
    super.initState();
    _loadAddressData();
    _loadCartProducts();
    _setMinShippingDate();
  }

  void _setMinShippingDate() {
    final now = DateTime.now();
    if (now.hour >= 12) {
      _shippingDate = now.add(const Duration(days: 1));
    } else {
      _shippingDate = now;
    }
  }

  Future<void> _loadAddressData() async {
    try {
      final String response = await rootBundle.loadString(        'assets/openapi.json',      );
      final List<dynamic> data = json.decode(response);
      _provinces = data.map((e) => Province.fromJson(e)).toList();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu địa chỉ: $e')));
      }
    }
  }

  Future<void> _loadCartProducts() async {
    setState(() => _isLoading = true);

    try {
      final cart = Provider.of<CartProvider>(context, listen: false);
      final productIds = cart.productIds;

      if (productIds.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final productService = ProductService();
      List<Product> loadedProducts = [];

      for (int id in productIds) {
        final product = await productService.getProductById(id);
        loadedProducts.add(product);
      }

      if (mounted) {
        setState(() {
          _products = loadedProducts;
          _isLoading = false;
          _calculateTotal();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải sản phẩm: $e')));
      }
    }
  }

  void _calculateTotal() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    double total = 0;
    for (var product in _products) {
      final qty = cart.getQuantity(product.id);
      total += product.price * qty;
    }
    if (mounted) {
      setState(() {
        _totalAmount = total - _couponDiscount;
      });
    }
  }

  // void _updateQuantity(int index, int change) {
  //   setState(() {
  //     final newQuantity = _cartProducts[index].quantity + change;
  //     if (newQuantity > 0 && newQuantity <= _cartProducts[index].product.stockQuantity) {
  //       _cartProducts[index].quantity = newQuantity;
  //       _calculateTotal();
  //     }
  //   });
  // }

  void _updateQuantity(int index, int change) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final productId = _products[index].id;

    if (change > 0) {
      cart.increaseQuantity(productId);
    } else if (change < 0) {
      cart.decreaseQuantity(productId);
    }

    if (mounted) {
      setState(() {
        _calculateTotal();
      });
    }
  }

  void _removeItem(int index) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final productId = _products[index].id;

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có muốn xóa sản phẩm này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  cart.removeItem(productId);
                  setState(() {
                    _products.removeAt(index);
                    _calculateTotal();
                  });
                },
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _applyCoupon() {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã giảm giá')),
      );
      return;
    }

    if (_couponApplied) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã áp dụng mã giảm giá')));
      return;
    }

    // Simulate API call to validate coupon
    setState(() {
      _couponCode = code;
      _couponDiscount = 50000; // Demo
      _couponApplied = true;
      _calculateTotal();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Áp dụng mã "$code" thành công! Giảm ${_formatCurrency(_couponDiscount)}',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeCoupon() {
    setState(() {
      _couponController.clear();
      _couponCode = '';
      _couponDiscount = 0;
      _couponApplied = false;
      _calculateTotal();
    });
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    if (_products.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Giỏ hàng trống')));
      return;
    }

    _formKey.currentState!.save();

    final cart = Provider.of<CartProvider>(context, listen: false);
    final cartItemsDto =
        cart.cartMap.entries
            .map((e) => CartItemDto(productId: e.key, quantity: e.value))
            .toList();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[50],
        title: const Text('Xác nhận đặt hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Họ tên: ${'$_lastName $_firstName'.trim()}', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Số điện thoại: +84 $_phoneNumber'),
              const SizedBox(height: 8),
              Text('Địa chỉ: ${_shippingMethod == 'Ship'
              ? '$_addressDetail, ${_selectedWard?.name}, ${_selectedDistrict?.name}, ${_selectedProvince?.name}'
                  : 'Lấy tại cửa hàng'}'),
              const SizedBox(height: 8),
              Text('Ngày nhận: ${DateFormat('dd/MM/yyyy').format(_shippingDate!)}'),
              const SizedBox(height: 8),
              Text('Phương thức thanh toán: ${_paymentMethod == 'Cash' ? 'Thanh toán khi nhận hàng (COD)' : 'Thanh toán VNPAY'}'),
              const SizedBox(height: 8),
              Text('Ghi chú: ${_note.isEmpty ? 'Không có' : _note}'),
              const Divider(height: 20),
              Text('Tổng tiền: ${_formatCurrency(_totalAmount)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A7C59))),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), // Hủy
            child: const Text('Hủy', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true), // Xác nhận
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A7C59)),
            child: const Text('Xác nhận đặt hàng', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    // Nếu người dùng bấm Hủy → không làm gì
    if (confirm != true) return;

    // Người dùng xác nhận → đặt hàng thật
    setState(() => _isLoading = true);

    final order = OrderDto(
      userId: 1,
      fullName: '$_lastName $_firstName'.trim(),
      email: '',
      phoneNumber: _phoneNumber,
      address:
          _shippingMethod == 'Ship'
              ? '$_addressDetail, ${_selectedWard?.name}, ${_selectedDistrict?.name}, ${_selectedProvince?.name}'
              : 'Lấy tại cửa hàng',
      note: _note,
      totalPrice: Decimal.parse(_totalAmount.toString()),
      paymentMethod: _paymentMethod,
      status: '',
      platform: 'Mobile',
      shippingMethod: _shippingMethod,
      shippingDate: _shippingDate!,
      couponCode: _couponApplied ? _couponCode : null,
      cartItems: cartItemsDto,
    );

    setState(() => _isLoading = true);
    try {
      final orderService = OrderService();

      if (_paymentMethod == 'Cash') {
        await orderService.placeOrder(order);
        cart.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt hàng thành công!'), backgroundColor: Colors.green),
        );
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const DefaultScreen()), (route) => false);
        return;
      }else {
        final paymentService = PaymentService();
        final paymentUrl = await paymentService.createPaymentUrl(
            PaymentDto(amount: _totalAmount, language: 'vn'));
        final uri = Uri.parse(paymentUrl);
        final vnpTxnRef = uri.queryParameters['vnp_TxnRef'];
        order.vnpTxnRef = vnpTxnRef;
        await orderService.placeOrder(order);

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PaymentWebView(
                    paymentUrl: paymentUrl,
                    paymentMethod: _paymentMethod,
                    totalPrice: _totalAmount.toInt(),
                  ),
            ),
          );
        }
      }

      // Thành công
      // cart.clear(); // Xóa giỏ hàng
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Đặt hàng thành công!'), backgroundColor: Colors.green),
      //   );
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder:
      //           (context) => const DefaultScreen(),
      //     ),
      //   );
      // }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đặt hàng thất bại: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getImageUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty) {
      return 'https://via.placeholder.com/100';
    }
    return '${AppConfig.baseUrl}/products/images/$fileName';
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Thanh toán', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cart Items
                    _buildCartItemsSection(),
                    const SizedBox(height: 24),

                    // Shipping Method
                    _buildShippingMethodSection(),
                    const SizedBox(height: 24),

                    // Customer Info
                    if (_shippingMethod == 'Ship')
                      _buildShippingInfoSection()
                    else
                      _buildPickupInfoSection(),
                    const SizedBox(height: 24),

                    // Order Summary
                    _buildOrderSummarySection(),
                  ],
                ),
              ),
            ),

            // Bottom Action
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemsSection() {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sản phẩm đã thêm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A7C59),
          ),
        ),
        const SizedBox(height: 12),
        ..._products.map((product) {
          final quantity = cart.getQuantity(product.id);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _getImageUrl(product.thumbnail),
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(product.price),
                          style: const TextStyle(
                            color: Color(0xFF4A7C59),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'x$quantity',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        // Row(
                        //   children: [
                        //     Container(
                        //       decoration: BoxDecoration(
                        //         border: Border.all(color: Colors.grey[300]!),
                        //         borderRadius: BorderRadius.circular(8),
                        //       ),
                        //       child: Row(
                        //         children: [
                        //           IconButton(
                        //             icon: const Icon(Icons.remove, size: 16),
                        //             onPressed: () => _updateQuantity(index, -1),
                        //             padding: const EdgeInsets.all(4),
                        //             constraints: const BoxConstraints(
                        //               minWidth: 32,
                        //               minHeight: 32,
                        //             ),
                        //           ),
                        //           Text(
                        //             '${item.quantity}',
                        //             style: const TextStyle(
                        //               fontWeight: FontWeight.bold,
                        //               fontSize: 14,
                        //             ),
                        //           ),
                        //           IconButton(
                        //             icon: const Icon(Icons.add, size: 16),
                        //             onPressed: () => _updateQuantity(index, 1),
                        //             padding: const EdgeInsets.all(4),
                        //             constraints: const BoxConstraints(
                        //               minWidth: 32,
                        //               minHeight: 32,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //     const Spacer(),
                        //     IconButton(
                        //       icon: const Icon(Icons.delete_outline, color: Colors.red),
                        //       onPressed: () => _removeItem(index),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildShippingMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phương thức nhận hàng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A7C59),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _shippingMethod = 'Ship'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        _shippingMethod == 'Ship'
                            ? const Color(0xFF4A7C59).withOpacity(0.1)
                            : Colors.white,
                    border: Border.all(
                      color:
                          _shippingMethod == 'Ship'
                              ? const Color(0xFF4A7C59)
                              : Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.local_shipping,
                        color:
                            _shippingMethod == 'Ship'
                                ? const Color(0xFF4A7C59)
                                : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Giao hàng',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _shippingMethod = 'Pickup'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        _shippingMethod == 'Pickup'
                            ? const Color(0xFF4A7C59).withOpacity(0.1)
                            : Colors.white,
                    border: Border.all(
                      color:
                          _shippingMethod == 'Pickup'
                              ? const Color(0xFF4A7C59)
                              : Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.store,
                        color:
                            _shippingMethod == 'Pickup'
                                ? const Color(0xFF4A7C59)
                                : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Lấy tại cửa hàng',
                        style: TextStyle(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShippingInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin giao hàng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A7C59),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Họ *',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value?.trim().isEmpty ?? true ? 'Nhập họ' : null,
                      onSaved: (value) => _lastName = value ?? '',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Tên *',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value?.trim().isEmpty ?? true ? 'Nhập tên' : null,
                      onSaved: (value) => _firstName = value ?? '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại *',
                  border: OutlineInputBorder(),
                  prefixText: '+84 ',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) return 'Nhập SĐT';
                  if (!RegExp(r'^\d{9,11}$').hasMatch(value!))
                    return 'SĐT 9-11 số';
                  return null;
                },
                onSaved: (value) => _phoneNumber = value ?? '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Province>(
                value: _selectedProvince,
                hint: const Text('Tỉnh/Thành phố *'),
                items:
                    _provinces
                        .map(
                          (p) =>
                              DropdownMenuItem(value: p, child: Text(p.name)),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProvince = value;
                    _districts = value?.districts ?? [];
                    _selectedDistrict = null;
                    _wards = [];
                    _selectedWard = null;
                  });
                },
                validator:
                    (value) => value == null ? 'Vui lòng chọn tỉnh' : null,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<District>(
                value: _selectedDistrict,
                hint: const Text('Quận/Huyện *'),
                items:
                    _districts
                        .map(
                          (d) =>
                              DropdownMenuItem(value: d, child: Text(d.name)),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDistrict = value;
                    _wards = value?.wards ?? [];
                    _selectedWard = null;
                  });
                },
                validator:
                    (value) => value == null ? 'Vui lòng chọn quận' : null,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Ward>(
                value: _selectedWard,
                hint: const Text('Phường/Xã *'),
                items:
                    _wards
                        .map(
                          (w) =>
                              DropdownMenuItem(value: w, child: Text(w.name)),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() => _selectedWard = value);
                },
                validator:
                    (value) => value == null ? 'Vui lòng chọn phường' : null,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ chi tiết *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập địa chỉ chi tiết';
                  }
                  final trimmed = value.trim();
                  if (trimmed.length < 5) {
                    return 'Địa chỉ phải có ít nhất 5 ký tự';
                  }
                  if (RegExp(r'^\d+$').hasMatch(trimmed)) {
                    return 'Địa chỉ không thể chỉ là số';
                  }
                  if (trimmed.replaceAll(' ', '').length < 5) {
                    return 'Địa chỉ không hợp lệ';
                  }
                  return null;
                },
                onSaved: (value) => _addressDetail = value?.trim() ?? '',
              ),
              const SizedBox(height: 16),
              _buildDatePicker(),
              const SizedBox(height: 16),
              _buildPaymentMethodDropdown(),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onSaved: (value) => _note = value ?? '',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPickupInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin đặt hàng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A7C59),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Họ *',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value?.trim().isEmpty ?? true ? 'Nhập họ' : null,
                      onSaved: (value) => _lastName = value ?? '',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Tên *',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value?.trim().isEmpty ?? true ? 'Nhập tên' : null,
                      onSaved: (value) => _firstName = value ?? '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại *',
                  border: OutlineInputBorder(),
                  prefixText: '+84 ',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) return 'Nhập SĐT';
                  if (!RegExp(r'^\d{9,11}$').hasMatch(value!))
                    return 'SĐT 9-11 số';
                  return null;
                },
                onSaved: (value) => _phoneNumber = value ?? '',
              ),
              // const SizedBox(height: 16),
              // DropdownButtonFormField<Province>(
              //   value: _selectedProvince,
              //   hint: const Text('Tỉnh/Thành phố *'),
              //   items:
              //       _provinces
              //           .map(
              //             (p) =>
              //                 DropdownMenuItem(value: p, child: Text(p.name)),
              //           )
              //           .toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       _selectedProvince = value;
              //       _districts = value?.districts ?? [];
              //       _selectedDistrict = null;
              //       _wards = [];
              //       _selectedWard = null;
              //     });
              //   },
              //   validator:
              //       (value) => value == null ? 'Vui lòng chọn tỉnh' : null,
              //   decoration: const InputDecoration(border: OutlineInputBorder()),
              // ),
              // const SizedBox(height: 16),
              // DropdownButtonFormField<District>(
              //   value: _selectedDistrict,
              //   hint: const Text('Quận/Huyện *'),
              //   items:
              //       _districts
              //           .map(
              //             (d) =>
              //                 DropdownMenuItem(value: d, child: Text(d.name)),
              //           )
              //           .toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       _selectedDistrict = value;
              //       _wards = value?.wards ?? [];
              //       _selectedWard = null;
              //     });
              //   },
              //   validator:
              //       (value) => value == null ? 'Vui lòng chọn quận' : null,
              //   decoration: const InputDecoration(border: OutlineInputBorder()),
              // ),
              // const SizedBox(height: 16),
              // DropdownButtonFormField<Ward>(
              //   value: _selectedWard,
              //   hint: const Text('Phường/Xã *'),
              //   items:
              //       _wards
              //           .map(
              //             (w) =>
              //                 DropdownMenuItem(value: w, child: Text(w.name)),
              //           )
              //           .toList(),
              //   onChanged: (value) {
              //     setState(() => _selectedWard = value);
              //   },
              //   validator:
              //       (value) => value == null ? 'Vui lòng chọn phường' : null,
              //   decoration: const InputDecoration(border: OutlineInputBorder()),
              // ),
              // const SizedBox(height: 16),
              // TextFormField(
              //   decoration: const InputDecoration(
              //     labelText: 'Địa chỉ chi tiết *',
              //     border: OutlineInputBorder(),
              //   ),
              //   maxLines: 2,
              //   validator: (value) {
              //     if (value == null || value.trim().isEmpty) {
              //       return 'Vui lòng nhập địa chỉ chi tiết';
              //     }
              //     final trimmed = value.trim();
              //     if (trimmed.length < 5) {
              //       return 'Địa chỉ phải có ít nhất 5 ký tự';
              //     }
              //     if (RegExp(r'^\d+$').hasMatch(trimmed)) {
              //       return 'Địa chỉ không thể chỉ là số';
              //     }
              //     if (trimmed.replaceAll(' ', '').length < 5) {
              //       return 'Địa chỉ không hợp lệ';
              //     }
              //     return null;
              //   },
              //   onSaved: (value) => _addressDetail = value?.trim() ?? '',
              // ),
              const SizedBox(height: 16),
              _buildDatePicker(),
              const SizedBox(height: 16),
              _buildPaymentMethodDropdown(),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onSaved: (value) => _note = value ?? '',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _shippingDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 180)),
        );
        if (picked != null) {
          setState(() => _shippingDate = picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Ngày nhận hàng *',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          _shippingDate != null
              ? DateFormat('dd/MM/yyyy').format(_shippingDate!)
              : 'Chọn ngày',
          style: TextStyle(
            color: _shippingDate != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return DropdownButtonFormField<String>(
      value: _paymentMethod,
      decoration: const InputDecoration(
        labelText: 'Phương thức thanh toán *',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: 'Cash',
          child: Text('Thanh toán khi nhận hàng'),
        ),
        DropdownMenuItem(
          value: 'BankTransfer',
          child: Text('Thanh toán VNPAY'),
        ),
      ],
      onChanged: (value) => setState(() => _paymentMethod = value!),
    );
  }

  Widget _buildOrderSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tóm tắt đơn hàng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A7C59),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng tiền hàng'),
                  Text(
                    _formatCurrency(_totalAmount + _couponDiscount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (_couponDiscount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Giảm giá',
                      style: TextStyle(color: Colors.green),
                    ),
                    Text(
                      '-${_formatCurrency(_couponDiscount)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thành tiền',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _formatCurrency(_totalAmount),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A7C59),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Mã giảm giá',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) => _couponCode = value,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _applyCoupon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A7C59),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'ÁP DỤNG',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              if (_couponApplied) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Mã "$_couponCode" đã áp dụng',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: _removeCoupon,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D5C47),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'ĐẶT HÀNG',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
