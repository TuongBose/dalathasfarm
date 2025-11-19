class FeedbackDto {
  final int userId;
  final String content;
  final int star;
  final int productId;

  FeedbackDto({
    required this.userId,
    required this.content,
    required this.star,
    required this.productId,
  });

  Map<String, dynamic> toJson() {
    return {
        'userId': userId,
        'content': content,
        'star': star,
        'productId': productId, 
    };
  }
}
