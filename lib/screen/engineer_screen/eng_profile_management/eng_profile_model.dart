class EngiProManagModel {
  int id;
  String name;
  String email;
  String password;
  String phone;
  String address;
  String profileImage;
  String idProof;
  String status;
  String userType;
  bool available;

  EngiProManagModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
    required this.profileImage,
    required this.idProof,
    required this.status,
    required this.userType,
    required this.available,
  });

  factory EngiProManagModel.fromJson(Map<String, dynamic> json) {
    return EngiProManagModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      profileImage: json['profile_image'] ?? '',
      idProof: json['id_proof'] ?? '',
      status: json['status'] ?? '',
      userType: json['user_type'] ?? '',
      available: json['available'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'profile_image': profileImage,
      'id_proof': idProof,
      'status': status,
      'user_type': userType,
      'available': available,
    };
  }
}
