class GetPropertyInputModel {
  final int id;
  final String name;
  final String password;
  final String email;
  final String phone;
  final String address;
  final String userType;

  GetPropertyInputModel({
    required this.id,
    required this.name,
    required this.password,
    required this.email,
    required this.phone,
    required this.address,
    required this.userType,
  });

  factory GetPropertyInputModel.fromJson(Map<String, dynamic> json) {
    return GetPropertyInputModel(
      id: json['id'],
      name: json['name'],
      password: json['password'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      userType: json['user_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'password': password,
      'email': email,
      'phone': phone,
      'address': address,
      'user_type': userType,
    };
  }
}
