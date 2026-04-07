class StockBalance {
  final String productId;
  final int currentBalance;

  StockBalance({required this.productId, required this.currentBalance});

  factory StockBalance.fromJson(Map<String, dynamic> json) => StockBalance(
        productId: json['productId'] as String,
        currentBalance: json['currentBalance'] as int,
      );
}
