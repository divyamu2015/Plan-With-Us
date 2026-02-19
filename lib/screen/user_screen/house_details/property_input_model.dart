class PropertyDetailModel {
  final String message;
  final int? requestId;
  final List<MatchedWork> matchedWorks;

  PropertyDetailModel({
    required this.message,
    this.requestId,
    required this.matchedWorks,
  });

  factory PropertyDetailModel.fromJson(Map<String, dynamic> json) {
    return PropertyDetailModel(
      message: json['message'] ?? '',
      requestId: json['request_id'],
      matchedWorks: json['matched_works'] != null
        ? (json['matched_works'] as List)
            .map((mw) => MatchedWork.fromJson(mw))
            .toList()
        : [],
    );
  }
}

class MatchedWork {
  final int id;
  final String engineer;
  final int engineerId;
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

  MatchedWork({
    required this.id,
    required this.engineer,
    required this.engineerId,
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

  factory MatchedWork.fromJson(Map<String, dynamic> json) {
    return MatchedWork(
      id: json['id'] ?? 0,
      engineer: json['engineer'] ?? '',
      engineerId: json['engineer_id'] ?? 0,
      projectName: json['project_name'] ?? '',
      category: json['category'] ?? '',
      cent: json['cent'] ?? '',
      squarefeet: json['squarefeet'] ?? '',
      expectedAmount: json['expected_amount'] ?? '',
      additionalAmount: json['additional_amount'] ?? '',
      totalAmount: json['total_amount'] ?? '',
      additionalFeatures: (json['additional_features'] as List?)?.map((e) => e.toString()).toList() ?? [],
      timeDuration: json['time_duration'] ?? '',
      propertyImage: json['property_image'] ?? '',
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
