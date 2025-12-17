class PaymentDto{
  final double amount;
  final String language;
  
  PaymentDto({
    required this.amount,
    required this.language,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'language': language,
    };
  }
}