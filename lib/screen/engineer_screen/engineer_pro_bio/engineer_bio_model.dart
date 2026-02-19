import 'package:flutter/widgets.dart';

class EngineerBioModel {
  final int id;
  final String engineer;
  final String projectName;
  final String category;
  final String cent;
  final String squareFeet;
  final String expectedAmount;
  final String additionalAmount;
  final String totalAmount;
  final List<String> additionalFeatures;
  final String timeDuration;
  final String propertyImage; // <-- property_image
  final List<WorkProofImage> images;

  EngineerBioModel({
    required this.id,
    required this.engineer,
    required this.projectName,
    required this.category,
    required this.cent,
    required this.squareFeet,
    required this.expectedAmount,
    required this.additionalAmount,
    required this.totalAmount,
    required this.additionalFeatures,
    required this.timeDuration,
    required this.propertyImage,
    required this.images,
  });

  factory EngineerBioModel.fromJson(Map<String, dynamic> json) {
    var imageList = (json['images'] as List?) ?? [];
    List<WorkProofImage> images = imageList
        .map((i) => WorkProofImage.fromJson(i))
        .toList();

    var featureList = (json['additional_features'] as List?) ?? [];
    List<String> features = featureList.map((i) => i.toString()).toList();

    return EngineerBioModel(
       id: json['id'] ?? 0,
      engineer: json['engineer'].toString(), // backend sends int, your UI probably expects String
      projectName: json['project_name'] ?? '',
      category: json['category'].toString(),
      cent: json['cent'] ?? '',
      squareFeet: json['squarefeet'] ?? '',
      expectedAmount: json['expected_amount'] ?? '',
      additionalAmount: json['additional_amount'] ?? '',
      totalAmount: json['total_amount'] ?? '',
      additionalFeatures: (json['additional_features'] as List?)?.map((e) => e.toString()).toList() ?? [],
      timeDuration: json['time_duration'] ?? '',
      propertyImage: json['property_image'] ?? '',
      images: images,
    );
  }
}

class WorkProofImage {
  final int id;
  final String image;

  WorkProofImage({required this.id, required this.image});

  factory WorkProofImage.fromJson(Map<String, dynamic> json) {
    return WorkProofImage(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
    );
  }
}

// Extra classes for completeness (unchanged)
class Feature {
  String name;
  IconData iconData;
  bool isSelected;
  Feature({
    required this.name,
    required this.iconData,
    this.isSelected = false,
  });
}

class House {
  final String? image; // asset path or network URL
  final String? fileImagePath; // picked image file path
  House({this.image, this.fileImagePath});
}
