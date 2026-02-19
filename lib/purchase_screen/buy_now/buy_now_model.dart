class ProductBooking {
  final int id;
  final String userName;
  final String productName;
  final String categoryName;
  final int quantity;
  final double totalPrice;
  final String status;
  final String bookingDate;

  ProductBooking({
    required this.id,
    required this.userName,
    required this.productName,
    required this.categoryName,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.bookingDate,
  });

  factory ProductBooking.fromJson(Map<String, dynamic> json) {
    return ProductBooking(
      id: json['id'],
      userName: json['user_name'] ?? "",
      productName: json['product_name'] ?? "",
      categoryName: json['category_name'] ?? "",
      quantity: json['quantity'] ?? 0,
      totalPrice: (json['total_price'] is String)
          ? double.tryParse(json['total_price']) ?? 0.0
          : (json['total_price'] ?? 0.0).toDouble(),
      status: json['status'] ?? "",
      bookingDate: json['booking_date'] ?? "",
    );
  }
}
