class ProductDetail {
  final int id;
  final String name;
  final String image;
  final String price;
  final int quantity;
  final String description;
  final String category;

  ProductDetail({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.description,
    required this.category,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      price: json['price'],
      quantity: json['quantity'],
      description: json['description'],
      category: json['category'],
    );
  }
}
