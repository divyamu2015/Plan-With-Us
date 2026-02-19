class EngineeringRegModel {
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

  EngineeringRegModel({
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

  factory EngineeringRegModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return EngineeringRegModel(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      profileImage: data['profile_image'] ?? '',
      idProof: data['id_proof'] ?? '',
      status: data['status'] ?? '',
      userType: data['user_type'] ?? '',
      available: data['available'] ?? false,
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
