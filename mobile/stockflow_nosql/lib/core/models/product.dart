class Product {
  final String id;
  final String name;
  final String sku;
  final String categoryName;
  final double unitPrice;
  final bool isActive;
  final int currentBalance;
  final String? location;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.categoryName,
    required this.unitPrice,
    required this.isActive,
    required this.currentBalance,
    this.location,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        sku: json['sku'] as String,
        categoryName: json['categoryName'] as String? ?? 'Unassigned category',
        unitPrice: (json['unitPrice'] as num).toDouble(),
        isActive: json['isActive'] as bool? ?? false,
        currentBalance: (json['currentBalance'] as num?)?.toInt() ?? 0,
        location: json['location'] as String?,
      );
}
