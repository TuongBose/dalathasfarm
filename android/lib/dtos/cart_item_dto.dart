class CartItemDto {
  final int productId;
  final int quantity;

  CartItemDto({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {'productId': productId, 'quantity': quantity};
  }
}
