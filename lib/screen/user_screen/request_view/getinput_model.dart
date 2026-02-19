class GetPropertyInputModel {
  final int id;
  final int userId;
  final int category;
  final double cent;
  final double sqft;
  final double expectedAmount;
  final DateTime createdAt;

  GetPropertyInputModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.cent,
    required this.sqft,
    required this.expectedAmount,
    required this.createdAt,
  });

  factory GetPropertyInputModel.fromJson(Map<String, dynamic> json) {
    return GetPropertyInputModel(
      id: json['id'],
      userId: json['user_id'],
      category: json['category'],
      cent: (json['cent'] as num).toDouble(),
      sqft: (json['sqft'] as num).toDouble(),
      expectedAmount: double.parse(json['expected_amount']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'cent': cent,
      'sqft': sqft,
      'expected_amount': expectedAmount.toStringAsFixed(2),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
