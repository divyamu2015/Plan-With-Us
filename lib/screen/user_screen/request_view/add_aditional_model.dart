class AddAdditionalDetails {
  final int id;
  final String cent;
  final String sqft;
  final String expectedAmount;
  final List<String> features;
  final String address;
  final String startDate;
  final String endDate;
  final String suggestion;
  final String status;
  final String createdAt;
  final int user;
  final int engineer;
  final int userRequest;

  AddAdditionalDetails({
    required this.id,
    required this.cent,
    required this.sqft,
    required this.expectedAmount,
    required this.features,
    required this.address,
    required this.startDate,
    required this.endDate,
    required this.suggestion,
    required this.status,
    required this.createdAt,
    required this.user,
    required this.engineer,
    required this.userRequest,
  });

  factory AddAdditionalDetails.fromJson(Map<String, dynamic> json) {
    var featureList = (json['features'] as List?) ?? [];
    List<String> features = featureList.map((i) => i.toString()).toList();

    return AddAdditionalDetails(
      id: json['id'] ?? 0,
      cent: json['cent']?.toString() ?? '',
      sqft: json['sqft']?.toString() ?? '',
      expectedAmount: json['expected_amount']?.toString() ?? '',
      features: (json['features'] as List?)?.map((e) => e.toString()).toList() ?? [],
      address: json['address'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      suggestion: json['suggestion'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      user: json['user'] ?? 0,
      engineer: json['engineer'] ?? 0,
      userRequest: json['user_request'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cent': cent,
      'sqft': sqft,
      'expected_amount': expectedAmount,
      'features': features,
      'address': address,
      'start_date': startDate,
      'end_date': endDate,
      'suggestion': suggestion,
      'status': status,
      'created_at': createdAt,
      'user': user,
      'engineer': engineer,
      'user_request': userRequest,
    };
  }
}
