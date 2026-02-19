class HouseSearchModel {
  final String message;
  final List<MatchedWork> matchedWorks;

  HouseSearchModel({required this.message, required this.matchedWorks});

  factory HouseSearchModel.fromJson(Map<String, dynamic> json) {
    return HouseSearchModel(
      message: json['message'] ?? '',
      matchedWorks: (json['matched_works'] as List<dynamic>)
          .map((work) => MatchedWork.fromJson(work))
          .toList(),
    );
  }
}

class MatchedWork {
  final int id;
  final int engineerId;
  final String engineer;
  final String projectName;
  final String category;
  final double cent;
  final double squarefeet;
  final double expectedAmount;
  final double additionalAmount;
  final double totalAmount;
  final List<String> additionalFeatures;
  final String timeDuration;
  final String propertyImage;
  final List<String> images;

  MatchedWork({
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

  factory MatchedWork.fromJson(Map<String, dynamic> json) {
    return MatchedWork(
      id: json['id'] ?? 0,
      engineerId: json['engineer_id'] ?? 0,
      engineer: json['engineer'] ?? '',
      projectName: json['project_name'] ?? '',
      category: "${json['category'] ?? ''}",
      // cent: json['cent'] ?? '',
      // squarefeet: json['squarefeet'] ?? '',
      // expectedAmount: json['expected_amount'] ?? '',
      // additionalAmount: json['additional_amount'] ?? '',
      // totalAmount: json['total_amount'] ?? '',
      cent:
          double.tryParse('${json['cent']}') ??
          0.0, // always parse from string!
      squarefeet: double.tryParse('${json['squarefeet']}') ?? 0.0,
      expectedAmount: double.tryParse('${json['expected_amount']}') ?? 0.0,
      additionalAmount: double.tryParse('${json['additional_amount']}') ?? 0.0,
      totalAmount: double.tryParse('${json['total_amount']}') ?? 0.0,

      additionalFeatures: (json['additional_features'] as List<dynamic>)
          .map((f) => f.toString())
          .toList(),
      timeDuration: json['time_duration'] ?? '',
      propertyImage: json['property_image'] ?? '',
      images: (json['images'] as List<dynamic>)
          .map((img) => img.toString())
          .toList(),
    );
  }
}
