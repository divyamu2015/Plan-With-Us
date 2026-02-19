class EngineerLoginModel {
  String message;
  int engineerId;
  String name;
  String email;
  String status;
  bool available;

  EngineerLoginModel({
    required this.message,
    required this.engineerId,
    required this.name,
    required this.email,
    required this.status,
    required this.available,
  });

  factory EngineerLoginModel.fromJson(Map<String, dynamic> json) {
    return EngineerLoginModel(
      message: json['message'] ?? '',
      engineerId: json['engineer_id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? '',
      available: json['available'] ?? false,
    );
  }
}
