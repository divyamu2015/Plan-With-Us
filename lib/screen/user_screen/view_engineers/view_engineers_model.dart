class EngineerProfileModel {
  final int id;
  final int engineerId;
  final String engineer;
  final String projectName;
  final String category;
  final String cent;
  final String squarefeet;
  final String expectedAmount;
  final String additionalAmount;
  final String totalAmount;
  final List<String> additionalFeatures;
  final String timeDuration;
  final String propertyImage;
  final List<String> images;

  EngineerProfileModel({
    required this.id,
    required this.engineerId,
    required this.engineer,
    required this.projectName,
    required this.category,
    required this.cent,
    required this.squarefeet,
    required this.expectedAmount,
    required this.additionalAmount,
    required this.totalAmount,
    required this.additionalFeatures,
    required this.timeDuration,
    required this.propertyImage,
    required this.images,
  });

  factory EngineerProfileModel.fromJson(Map<String, dynamic> json) {
    return EngineerProfileModel(
      id: json['id'] ?? 0,
      engineerId: json['engineer_id'] ?? 0,
      engineer: json['engineer'] ?? '',
      projectName: json['project_name'] ?? '',
      category: json['category'] ?? '',
      cent: json['cent'] ?? '',
      squarefeet: json['squarefeet'] ?? '',
      expectedAmount: json['expected_amount'] ?? '',
      additionalAmount: json['additional_amount'] ?? '',
      totalAmount: json['total_amount'] ?? '',
      additionalFeatures: List<String>.from(json['additional_features'] ?? []),
      timeDuration: json['time_duration'] ?? '',
      propertyImage: json['property_image'] ?? '',
      images: List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'engineer': engineer,
      'project_name': projectName,
      'category': category,
      'cent': cent,
      'squarefeet': squarefeet,
      'expected_amount': expectedAmount,
      'additional_amount': additionalAmount,
      'total_amount': totalAmount,
      'additional_features': additionalFeatures,
      'time_duration': timeDuration,
      'property_image': propertyImage,
      'images': images,
    };
  }
}
