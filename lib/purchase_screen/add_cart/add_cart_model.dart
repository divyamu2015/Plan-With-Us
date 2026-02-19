class CartItem {
  final int id;
  final String productName;
  final String productImage;   // Added field
  final String categoryName;
   int quantity;
   double totalPrice;
  final String status;
  final String createdAt;

  CartItem({
    required this.id,
    required this.productName,
    required this.productImage,   // Updated constructor
    required this.categoryName,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productName: json['product_name'],
      productImage: json['product_image'] ?? "",  // Parse new field, fallback to empty
      categoryName: json['category_name'],
      quantity: json['quantity'],
    totalPrice: (json['total_price'] is String)
          ? double.tryParse(json['total_price']) ?? 0.0
          : (json['total_price'] ?? 0.0).toDouble(),
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}
