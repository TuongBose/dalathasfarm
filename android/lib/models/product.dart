import 'package:android/models/category.dart';
import 'package:android/models/product_image.dart';
import 'package:decimal/decimal.dart';

class Product {
    final int id;
    final String name;
    final double price;
    final String description;
    final String components;
    final int stockQuantity;
    final int categoryId;
    final String thumbnail;
    List<ProductImage>? productImages;

    Product({
        required this.id,
        required this.name,
        required this.price,
        required this.description,
        required this.components,
        required this.stockQuantity,
        required this.categoryId,
        required this.thumbnail,
        this.productImages,
    });

    factory Product.fromJson(Map<String, dynamic> json) {
        return Product(
            id: json['id'],
            name: json['name'],
            price: json['price'],
            description: json['description'],
            components: json['components'],
            stockQuantity: json['stockQuantity'],
            categoryId: json['categoryId'],
            thumbnail: json['thumbnail'],
            productImages: json['productImageResponses'] != null
                ? (json['productImageResponses'] as List)
                .map((imageJson) => ProductImage.fromJson(imageJson))
                .toList()
                : [],
        );
    }
}