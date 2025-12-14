import 'package:flutter/material.dart';

class CartItem {
  final int productId;
  final String productName;
  final double price;
  final String thumbnail;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.thumbnail,
    this.quantity = 1,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  void addItem({
    required int productId,
    required String productName,
    required double price,
    required String thumbnail,
  }) {
    final existingIndex = _items.indexWhere((item) => item.productId == productId);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(
        productId: productId,
        productName: productName,
        price: price,
        thumbnail: thumbnail,
      ));
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void increaseQuantity(int productId) {
    final item = _items.firstWhere((item) => item.productId == productId);
    item.quantity++;
    notifyListeners();
  }

  void decreaseQuantity(int productId) {
    final item = _items.firstWhere((item) => item.productId == productId);
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      removeItem(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}