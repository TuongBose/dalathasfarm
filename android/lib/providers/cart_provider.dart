import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  // Chỉ lưu productId -> quantity
  final Map<int, int> _cartMap = {};

  Map<int, int> get cartMap => Map.unmodifiable(_cartMap);

  int get itemCount => _cartMap.values.fold(0, (sum, qty) => sum + qty);

  // Tổng tiền sẽ tính ở nơi hiển thị (Checkout/Cart) sau khi load product detail
  // Vì ở đây không lưu price

  void addItem(int productId, {int quantity = 1}) {
    _cartMap.update(productId, (existing) => existing + quantity, ifAbsent: () => quantity);
    notifyListeners();
  }

  void removeItem(int productId) {
    _cartMap.remove(productId);
    notifyListeners();
  }

  void increaseQuantity(int productId) {
    if (_cartMap.containsKey(productId)) {
      _cartMap[productId] = _cartMap[productId]! + 1;
      notifyListeners();
    }
  }

  void decreaseQuantity(int productId) {
    if (_cartMap.containsKey(productId)) {
      if (_cartMap[productId]! > 1) {
        _cartMap[productId] = _cartMap[productId]! - 1;
      } else {
        removeItem(productId);
      }
      notifyListeners();
    }
  }

  void clear() {
    _cartMap.clear();
    notifyListeners();
  }

  // Helper: lấy danh sách productId
  List<int> get productIds => _cartMap.keys.toList();

  // Helper: lấy quantity của 1 sản phẩm
  int getQuantity(int productId) => _cartMap[productId] ?? 0;
}