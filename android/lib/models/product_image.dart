class ProductImage {
    final int productId;
    final String name;

    ProductImage({
        required this.productId,
        required this.name,
    });

    factory ProductImage.fromJson(Map<String, dynamic> json) {
        return ProductImage(
            productId: json['productId'],
            name: json['name'],
        );
    }
}