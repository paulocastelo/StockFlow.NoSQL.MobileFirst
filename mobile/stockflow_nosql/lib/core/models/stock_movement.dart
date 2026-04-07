class StockMovement {
  final String id;
  final String productId;
  final int type;
  final int quantity;
  final String? reason;
  final String? performedByUserId;
  final String occurredAtUtc;

  StockMovement({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    this.reason,
    this.performedByUserId,
    required this.occurredAtUtc,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) => StockMovement(
        id: json['id'] as String,
        productId: json['productId'] as String,
        type: json['type'] as int,
        quantity: json['quantity'] as int,
        reason: json['reason'] as String?,
        performedByUserId: json['performedByUserId'] as String?,
        occurredAtUtc: json['occurredAtUtc'] as String,
      );
}
